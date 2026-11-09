hs.loadSpoon("SpoonInstall")

-- use karabiner to map this hyper key
local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Native fullscreen lives in its own Space and macOS animates in and out of
-- it. Hammerspoon has no "animation finished" callback, so poll for the state
-- we need instead of guessing how many seconds the animation takes.
local function waitFor(label, isReady, onReady)
    if isReady() then return onReady() end

    local started = hs.timer.secondsSinceEpoch()
    local poller, deadline
    poller = hs.timer.waitUntil(isReady, function()
        deadline:stop()
        print(string.format("[relocate] %s took %.2fs", label, hs.timer.secondsSinceEpoch() - started))
        onReady()
    end, 0.05)
    deadline = hs.timer.doAfter(3, function()
        poller:stop()
        hs.alert.show("timed out waiting for " .. label)
    end)
end

local function isAlive(win)
    return win:id() ~= nil
end

local function isOnUserSpace(win)
    if win:isFullScreen() then return false end

    local spaces = hs.spaces.windowSpaces(win)
    if not spaces or #spaces == 0 then return false end
    for _, space in ipairs(spaces) do
        if hs.spaces.spaceType(space) ~= "user" then return false end
    end

    local screen = win:screen()
    local active = screen and hs.spaces.activeSpaceOnScreen(screen)
    return active ~= nil and hs.spaces.spaceType(active) == "user"
end

local function isSettledOn(win, screen)
    local lastFrame
    return function()
        local current = win:screen()
        if not current or current:id() ~= screen:id() then
            lastFrame = nil
            return false
        end
        local frame = win:frame()
        local settled = lastFrame ~= nil and lastFrame:equals(frame)
        lastFrame = frame
        return settled
    end
end

-- moves: list of { win = hs.window, to = hs.screen }
local function relocate(moves, noResize, onDone)
    local function forEachAlive(fn)
        for _, m in ipairs(moves) do
            if isAlive(m.win) then fn(m) end
        end
    end
    local function allAlive(check)
        return function()
            for _, m in ipairs(moves) do
                if isAlive(m.win) and not check(m) then return false end
            end
            return true
        end
    end

    forEachAlive(function(m)
        m.wasFull = m.win:isFullScreen()
        if m.wasFull then m.win:setFullScreen(false) end
    end)

    waitFor("fullscreen exit", allAlive(function(m) return not m.wasFull or isOnUserSpace(m.win) end), function()
        forEachAlive(function(m)
            m.win:moveToScreen(m.to, noResize, true, 0)
            m.isSettled = isSettledOn(m.win, m.to)
        end)

        waitFor("move", allAlive(function(m) return not m.wasFull or m.isSettled() end), function()
            forEachAlive(function(m)
                if m.wasFull then m.win:setFullScreen(true) end
            end)
            if onDone then onDone() end
        end)
    end)
end

local function moveToTargetScreen(win, target_screen)
    relocate({ { win = win, to = target_screen } }, true, function()
        if isAlive(win) then win:focus() end
    end)
end

local function moveToNext()
    local cur_win = hs.window.focusedWindow()
    local next_screen = cur_win:screen():next()
    moveToTargetScreen(cur_win, next_screen)
end


local function moveFocusedWindowToScreen()
    local cur_win = hs.window.focusedWindow()

    -- no foucus window
    if not cur_win then
        return
    end

    -- only one screen
    local screens = hs.screen.allScreens()
    if #screens == 1 then
        return
    elseif #screens == 2 then
        local target_screen = cur_win:screen():next()
        moveToTargetScreen(cur_win, target_screen)
        return
    end


    local current_screen = cur_win:screen()
    local menuChoices = {}

    for i, sc in ipairs(screens) do
        if sc:id() ~= current_screen:id() then
            local name = sc:name() or "Unknown"
            local frame = sc:frame()

            table.insert(menuChoices, {
                text = name,
                subText = string.format("resolution: %dx%d", frame.w, frame.h),
                id = sc:id()
            })
        end
    end


    local chooser = hs.chooser.new(function(choice)
        if not choice then return end

        local target_screen = hs.screen.find(choice.id)
        if not target_screen then return end
        moveToTargetScreen(cur_win, target_screen)
    end)

    chooser:choices(menuChoices)
    chooser:placeholderText("choose target screen")
    chooser:rows(#menuChoices)
    chooser:show()
end



-- A fresh filter registers watchers on every running app each time getWindows()
-- is called, which costs seconds per hotkey press. Keep one filter active for
-- the whole session so lookups read its cached window list.
local windowFilter = hs.window.filter.new():keepActive()

local function lastFocusedWindowOn(screen)
    for _, win in ipairs(windowFilter:getWindows()) do
        local winScreen = win:screen()
        if winScreen and winScreen:id() == screen:id() then return win end
    end
end

local function swapFocusedBetween(screenA, screenB)
    if not screenA or not screenB then return end

    local winA = lastFocusedWindowOn(screenA)
    local winB = lastFocusedWindowOn(screenB)

    local moves = {}
    if winA then table.insert(moves, { win = winA, to = screenB }) end
    if winB then table.insert(moves, { win = winB, to = screenA }) end
    if #moves == 0 then return end

    relocate(moves, false, function()
        if winA and isAlive(winA) then winA:focus() end
        hs.alert.show("✅ SWAP FINISH")
    end)
end

local function smartSwapFocused()
    local win = hs.window.focusedWindow()
    if not win then
        return
    end

    local currentScreen = win:screen()
    local allScreens = hs.screen.allScreens()

    if #allScreens < 2 then
        return
    end

    if #allScreens == 2 then
        -- Only two screens: Swap current screen with the "other" one
        local otherScreen = currentScreen:next()
        swapFocusedBetween(currentScreen, otherScreen)
    else
        -- More than two: Ask which target screen to swap with
        local choices = {}
        for _, sc in ipairs(allScreens) do
            if sc:id() ~= currentScreen:id() then
                local frame = sc:frame()
                table.insert(choices, {
                    text = sc:name() or "Unknown",

                    subText = string.format("resolution: %dx%d", frame.w, frame.h),
                    id = sc:id()
                })
            end
        end

        hs.chooser.new(function(choice)
            if choice then
                local targetScreen = hs.screen.find(choice.id)
                swapFocusedBetween(currentScreen, targetScreen)
            end
        end):choices(choices):placeholderText("choose target screen"):show()
    end
end

hs.hotkey.bind(hyper, "w", moveFocusedWindowToScreen)
hs.hotkey.bind(hyper, "e", smartSwapFocused)
