local last = {}

lib.callback.register('p07fpause:info', function(src)
    if (last[src] or 0) > GetGameTimer() then return false end
    last[src] = GetGameTimer() + 500
    return { online = #GetPlayers(), max = GetConvarInt('sv_maxclients', 48) }
end)

RegisterNetEvent('p07fpause:quit', function()
    local src = source
    if SvConfig.webhook ~= '' then
        PerformHttpRequest(SvConfig.webhook, function() end, 'POST', json.encode({
            username = SvConfig.botName,
            embeds = { { title = 'Left the server', description = ('**%s** quit from the pause menu'):format(GetPlayerName(src) or src), color = 9807270, timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ') } },
        }), { ['Content-Type'] = 'application/json' })
    end
    DropPlayer(src, 'See you soon.')
end)

AddEventHandler('playerDropped', function() last[source] = nil end)
