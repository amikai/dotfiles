hs.loadSpoon("SpoonInstall")

local function moveToTargetScreen(win, target_screen)
    local was_full_screen = win:isFullScreen()

    if was_full_screen then
        win:setFullScreen(false)
        hs.timer.doAfter(0.6, function()
            if win:id() then
                win:moveToScreen(target_screen, true, true, 0)
                hs.timer.doAfter(0.3, function() win:setFullScreen(true) end)
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
                ["text"] = name,
                ["subText"] = string.format("resolution: %dx%d", frame.w, frame.h),
                ["id"] = sc:id()
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

hs.hotkey.bind({ "option" }, "S", moveFocusedWindowToScreen)
