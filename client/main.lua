-- Free pause menu: ESC and P open this menu instead of GTA's (same key handling as Project07_PauseMenu).
local open = false
local allowVanilla, allowVanillaUntil, vanillaSeen, suppressUntil = false, 0, false, 0

local function nui(action, data) SendNUIMessage({ action = action, data = data }) end

local function vanillaOpening()
    if IsPauseMenuActive() then return true end
    local s = GetPauseMenuState and GetPauseMenuState()
    return s ~= nil and s ~= 0
end

local function killVanilla()
    SetPauseMenuActive(false)
    SetFrontendActive(false)
end

local function close(handingOff)
    if not open then return end
    open = false
    SetNuiFocus(false, false)
    nui('close')
    if Config.blur then TriggerScreenblurFadeOut(300) end
    if handingOff then return end
    -- the key that closed us must not open GTA's menu right after
    suppressUntil = GetGameTimer() + 900
    CreateThread(function()
        local untilT = suppressUntil
        while GetGameTimer() < untilT and not allowVanilla do
            if vanillaOpening() then killVanilla() end
            Wait(0)
        end
    end)
end

local function show()
    if open or GetGameTimer() < suppressUntil or not LocalPlayer.state.isLoggedIn then return end
    local pd = P7H.Framework.GetPlayerData() or {}
    local info = lib.callback.await('p07fpause:info', false) or {}
    local ci = pd.charinfo or {}
    open = true
    if Config.blur then TriggerScreenblurFadeIn(300) end
    SetNuiFocus(true, true)
    nui('open', {
        server = Config.serverName,
        buttons = Config.buttons,
        player = {
            name = ((ci.firstname or '') .. ' ' .. (ci.lastname or '')):gsub('^%s+$', GetPlayerName(PlayerId())),
            job = pd.job and pd.job.label or 'Civilian',
            grade = pd.job and pd.job.grade and pd.job.grade.name or nil,
            cash = pd.money and pd.money.cash or 0,
            bank = pd.money and pd.money.bank or 0,
            id = GetPlayerServerId(PlayerId()),
        },
        online = info.online, max = info.max,
    })
end

--- hands the screen to a GTA menu (settings) for a moment
local function openVanilla(menuHash)
    close(true)
    allowVanilla, allowVanillaUntil = true, GetGameTimer() + 3000
    CreateThread(function()
        Wait(100)
        for _ = 1, 5 do
            if IsPauseMenuActive() then return end
            ActivateFrontendMenu(menuHash, false, -1)
            Wait(150)
        end
    end)
end

--- the GTA map full screen, without the pause tabs; back / ESC / P closes it
local function openMapOnly()
    close(true)
    allowVanilla, allowVanillaUntil = true, GetGameTimer() + 3000
    CreateThread(function()
        Wait(100)
        ActivateFrontendMenu(`FE_MENU_VERSION_MP_PAUSE`, false, -1)
        local limit = GetGameTimer() + 2000
        while not IsPauseMenuActive() and GetGameTimer() < limit do Wait(0) end
        Wait(150)
        PauseMenuceptionGoDeeper(0)
        while IsPauseMenuActive() do
            allowVanillaUntil = GetGameTimer() + 1000
            DisableControlAction(0, 205, true)
            DisableControlAction(0, 206, true)
            for _, control in ipairs({ 177, 199, 200, 202 }) do
                DisableControlAction(0, control, true)
                if IsDisabledControlJustPressed(0, control) then
                    SetFrontendActive(false)
                    break
                end
            end
            Wait(0)
        end
    end)
end

-- input: ESC (200) and P (199)
CreateThread(function()
    while true do
        if not LocalPlayer.state.isLoggedIn then
            Wait(500)
        elseif allowVanilla then
            if IsPauseMenuActive() then
                vanillaSeen = true
            elseif vanillaSeen or GetGameTimer() > allowVanillaUntil then
                allowVanilla, vanillaSeen = false, false
                suppressUntil = GetGameTimer() + 350
            end
            Wait(0)
        else
            DisableControlAction(0, 199, true) -- P
            DisableControlAction(0, 200, true) -- ESC
            local pressed = IsDisabledControlJustPressed(0, 199) or IsDisabledControlJustPressed(0, 200)
            local vanilla = vanillaOpening()
            if pressed or vanilla then
                local suppressed = GetGameTimer() < suppressUntil
                local otherUi = not open and IsNuiFocused()
                if vanilla then killVanilla() end
                if not suppressed and not otherUi then
                    if pressed and open then close()
                    elseif not open then CreateThread(show) end
                end
            end
            Wait(0)
        end
    end
end)

RegisterNUICallback('action', function(d, cb)
    cb(1)
    local a = d.action
    if a == 'resume' then
        close()
    elseif a == 'map' then
        openMapOnly()
    elseif a == 'settings' then
        openVanilla(`FE_MENU_VERSION_LANDING_MENU`)
    elseif a == 'quit' then
        TriggerServerEvent('p07fpause:quit')
    end
end)

RegisterNUICallback('close', function(_, cb)
    cb(1)
    close()
end)

AddEventHandler('onResourceStop', function(name)
    if name == cache.resource and open then
        SetNuiFocus(false, false)
        TriggerScreenblurFadeOut(0)
    end
end)
