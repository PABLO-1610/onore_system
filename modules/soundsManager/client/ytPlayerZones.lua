--[[
  This file is part of Onore RolePlay.

  Copyright (c) Onore RolePlay - All Rights Reserved

  Unauthorized using, copying, modifying and/or distributing of this file,
  via any medium is strictly prohibited. This code is confidential.
--]]

local soundInfo = {}

local defaultInfo = {
    volume = 1.0,
    url = "",
    id = "",
    position = nil,
    distance = 0,
    playing = false,
    paused = false,
    loop = false,
}

local function getLink(name_)
    return soundInfo[name_].url
end

local function getPosition(name_)
    return soundInfo[name_].position
end

local function isLooped(name_)
    return soundInfo[name_].loop
end

local function getInfo(name_)
    return soundInfo[name_]
end

local function soundExists(name_)
    if soundInfo[name_] == nil then
        return false
    end
    return true
end

local function isPlaying(name_)
    if soundInfo[name_] == nil then return false end
    return soundInfo[name_].playing
end

local function isPaused(name_)
    return soundInfo[name_].paused
end

local function getDistance(name_)
    return soundInfo[name_].distance
end

local function getVolume(name_)
    return soundInfo[name_].volume
end

function PlayUrl(name_, url_, volume_, loop_)
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = 0,
        y = 0,
        z = 0,
        dynamic = false,
        volume = volume_,
        loop = loop_ or false,
    })

    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].volume = volume_
    soundInfo[name_].url = url_
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
end

function PlayUrlPos(name_, url_, volume_, pos, loop_)
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        dynamic = true,
        volume = volume_,
        loop = loop_ or false,
    })
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].volume = volume_
    soundInfo[name_].url = url_
    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
end

local function Distance(name_, distance_)
    SendNUIMessage({
        status = "distance",
        name = name_,
        distance = distance_,
    })
    soundInfo[name_].distance = distance_
end

local function Position(name_, pos)
    SendNUIMessage({
        status = "soundPosition",
        name = name_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
    })
    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
end

local function Destroy(name_)
    SendNUIMessage({
        status = "delete",
        name = name_
    })
    soundInfo[name_] = nil
end

local function Resume(name_)
    SendNUIMessage({
        status = "resume",
        name = name_
    })
    soundInfo[name_].playing = true
    soundInfo[name_].paused = false
end

local function Pause(name_)
    SendNUIMessage({
        status = "pause",
        name = name_
    })
    soundInfo[name_].playing = false
    soundInfo[name_].paused = true
end

local function setVolume(name_, vol)
    SendNUIMessage({
        status = "volume",
        volume = vol,
        name = name_,
    })
    soundInfo[name_].volume = vol
end

local function setVolumeMax(name_, vol)
    SendNUIMessage({
        status = "max_volume",
        volume = vol,
        name = name_,
    })
    soundInfo[name_].volume = vol
end

local NearZone = false

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        if not NearZone then
            Wait(2500)
        else
            Wait(250)
        end
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        SendNUIMessage({
            status = "position",
            x = pos.x,
            y = pos.y,
            z = pos.z
        })
    end
end)


local MusicZone = {
    {
        name = "police_radio",
        link = "https://www.youtube.com/watch?v=eqnq5XF3CJ0",
        dst = 15.0,
        starting = 35.0,
        pos = vector3(440.81, -977.01, 30.68),
        max = 0.1,
    },
    -- Mag vetement 1
    {
        name = "onore_shop_ambiance1",
        link = "https://www.youtube.com/watch?v=rS8t1q4cObI",
        dst = 15.0,
        starting = 30.0,
        pos = vector3(122.56, -1032.94, 29.27),
        max = 0.05
    },
    -- Mag vetement 2
    {
        name = "onore_shop_ambiance2",
        link = "https://www.youtube.com/watch?v=rS8t1q4cObI",
        dst = 25.0,
        starting = 30.0,
        pos = vector3(-715.92, -382.39, 34.82),
        max = 0.05
    },

    {
        name = "shop_ambient",
        link = "https://www.youtube.com/watch?v=WoxnL5dakyA&t=6s",
        dst = 10.0,
        starting = 30.0,
        pos = vector3(25.74, -1345.8, 29.49),
        max = 0.09,
    }
}

Citizen.CreateThread(function()
    Wait(2000)
    while true do
        NearZone = false
        local pPed = GetPlayerPed(-1)
        local pCoords = GetEntityCoords(pPed)
        for k,v in pairs(MusicZone) do
            local dst = GetDistanceBetweenCoords(pCoords, v.pos, true)
            if not NearZone then
                if dst < v.starting then
                    NearZone = true
                    if soundExists(v.name) then
                        Resume(v.name)
                    else
                        PlayUrlPos(v.name, v.link, v.max, v.pos, true)
                        setVolumeMax(v.name, v.max)
                        Distance(v.name, v.dst)
                    end
                else
                    if soundExists(v.name) then
                        if not isPaused(v.name) then
                            Pause(v.name)
                        end
                    end
                end
            end
        end

        if not NearZone then
            Wait(350)
        else
            Wait(50)
        end
    end
end)