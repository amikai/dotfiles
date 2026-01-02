hs.loadSpoon("SpoonInstall")

-- use karabiner to map this hyper key
local hyper = { "cmd", "alt", "ctrl", "shift" }

local function moveToTargetScreen(win, target_screen)
    local was_full_screen = win:isFullScreen()

    if was_full_screen then
        win:setFullScreen(false)
        hs.timer.doAfter(0.7, function()
            if win:id() then
                win:moveToScreen(target_screen, true, true, 0)
                hs.timer.doAfter(0.4, function() win:setFullScreen(true) end)
                win:focus()
            end
        end)
    else
        win:moveToScreen(target_screen, true, true, 0)
    end
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



local function swapFocusedBetween(screenA, screenB)
    if not screenA or not screenB then return end

    local winA = hs.window.filter.new():setScreens(screenA:id()):getWindows()[1]
    local winB = hs.window.filter.new():setScreens(screenB:id()):getWindows()[1]

    if not winA and not winB then
        return
    end

    local fullA = winA and winA:isFullScreen() or false
    local fullB = winB and winB:isFullScreen() or false

    if fullA then winA:setFullScreen(false) end
    if fullB then winB:setFullScreen(false) end

    hs.timer.doAfter(0.7, function()
        if winA then winA:moveToScreen(screenB, false, true, 0) end
        if winB then winB:moveToScreen(screenA, false, true, 0) end

        hs.timer.doAfter(0.3, function()
            if fullA and winA then winA:setFullScreen(true) end
            if fullB and winB then winB:setFullScreen(true) end

            if winA then winA:focus() end
            hs.alert.show("✅ SWAP FINISH")
        end)
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
