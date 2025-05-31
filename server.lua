ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local restrictedJobs = {
    "dealer",
    "police",
    "ambulance"
}

local tipPrice = 50000
local playerCooldowns = {}

local function isRestrictedJob(job)
    for _, v in pairs(restrictedJobs) do
        if v == job then
            return true
        end
    end
    return false
end

RegisterNetEvent("npcTips:tryBuyTip")
AddEventHandler("npcTips:tryBuyTip", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then return end

    local job = xPlayer.job.name

    if isRestrictedJob(job) then
        TriggerClientEvent("npcTips:showNotify", _source, "Du solltest hier nicht sein, verschwinde!", false)
        return
    end

    local now = os.time()

    if playerCooldowns[_source] and playerCooldowns[_source] > now then
        local secondsLeft = playerCooldowns[_source] - now
        local minutes = math.floor(secondsLeft / 60)
        local seconds = secondsLeft % 60
        local timeString = string.format("%d:%02d Minuten", minutes, seconds)
        TriggerClientEvent("npcTips:showNotify", _source, "Du musst noch warten: "..timeString, false)
        return
    end

    if xPlayer.getMoney() >= tipPrice then
        xPlayer.removeMoney(tipPrice)
        TriggerClientEvent("npcTips:showNotify", _source, "haha Hier Bist du falsch du musst richtung berge hier hast du einen marker in der nähe sollte der schwarzmarkt sein!", true)
        playerCooldowns[_source] = now + 5 * 60 -- 5 Minuten Cooldown
    else
        TriggerClientEvent("npcTips:showNotify", _source, "Du hast nicht genug Geld für den Tipp.", false)
    end
end)
