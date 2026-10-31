local open = false

local function nui(action, data) SendNUIMessage({ action = action, data = data }) end

local function close()
    if not open then return end
    open = false
    SetNuiFocus(false, false)
    nui('close')
    if Config.blur then TriggerScreenblurFadeOut(300) end
end

local function show()
    if open or IsNuiFocused() or IsPauseMenuActive() or not LocalPlayer.state.isLoggedIn then return end
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

-- ESC opens this menu instead of the GTA one (P still opens the GTA map menu)
CreateThread(function()
    while true do
        if not open and LocalPlayer.state.isLoggedIn then
            DisableControlAction(0, 200, true)
            if IsDisabledControlJustReleased(0, 200) and not IsPauseMenuActive() and not IsNuiFocused() then show() end
            Wait(0)
        else
            Wait(250)
        end
    end
end)

RegisterNUICallback('action', function(d, cb)
    cb(1)
    local a = d.action
    if a == 'resume' then
        close()
    elseif a == 'map' then
        close()
        ActivateFrontendMenu(`FE_MENU_VERSION_MP_PAUSE`, false, -1)
    elseif a == 'settings' then
        close()
        ActivateFrontendMenu(`FE_MENU_VERSION_LANDING_MENU`, false, -1)
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
