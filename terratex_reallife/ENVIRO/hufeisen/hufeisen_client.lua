addEvent("spawnHufeisen", true)
local hufeisen = {}
local hufeisenOnMap = 40
colshapedata = {}
pickuocolshapedata = {}

function spawnHufeisen_func()
    for theKey, theHufeisen in ipairs(hufeisen) do
        if (isElement(theHufeisen)) then
            destroyElement(theHufeisen)
        end
    end
    for theKey, thecolshape in pairs(colshapedata) do
        if (isElement(theKey)) then
            destroyElement(theKey)
        end
    end
    hufeisen = {}
    pickuocolshapedata = {}
    local pickup = false
    if (isPlayerLoggedIn(getLocalPlayer())) then
        if (isGoldBoosterActive(getLocalPlayer(), "HufeisenBooster")) then
            hufeisenOnMap = math.round(hufeisenOnMap * 1.50)
        end
        for n = 0, hufeisenOnMap, 1 do
            local x = math.random(0, 5600) - 2800
            local y = math.random(0, 5600) - 2800
            local z = 0

            local hit, nx, ny, z = processLineOfSight(x, y, 700, x, y, -10)

            if (hit) then
                pickup = createPickup(x, y, z, 3, 954)
            else
                pickup = createPickup(x, y, 0, 3, 954)
            end
            local colshaper = createColCircle(x, y, 70)
            colshapedata[colshaper] = pickup
            addEventHandler("onClientColShapeHit", colshaper, setpickuphigher_hufeisen)
            table.insert(hufeisen, pickup)
            pickuocolshapedata[pickup] = colshape
            addEventHandler("onClientPickupHit", pickup, findHufeisen)
            --outputDebugString(tostring(n))
        end
    else
        setTimer(spawnHufeisen_func, 5000, 1)
    end
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), spawnHufeisen_func)

function setpickuphigher_hufeisen()
    --outputChatBox("hit")
    local pickup = colshapedata[source]
    if (isElement(pickup)) then
        local x, y, z = getElementPosition(pickup)
        local mx, my, mz = getElementPosition(getLocalPlayer())
        hit, nx, ny, z = processLineOfSight(x, y, 700, x, y, -10, true, false, false)
        if (hit) then
            setElementPosition(pickup, x, y, z + 1)
        else
            setElementPosition(pickup, x, y, 0)
        end
        if (isElementWithinColShape(getLocalPlayer(), source)) then
            colsahpe = true
            syncHufeisen(source)
        end
    end
end

local muteHufeisen = false
function muteHufeisen_func()
    muteHufeisen = not (muteHufeisen)
    if (muteHufeisen) then
        outputChatBox("Hufeisenton ausgeschaltet")
    else
        outputChatBox("Hufeisenton angeschaltet")
    end
end
addCommandHandler("mutehufeisen", muteHufeisen_func, false, false)

function startCheckHufeisenTimer()
    if (getElementData(getLocalPlayer(), "Hufeisenhelfer")) then
        if ((tonumber(getElementData(getLocalPlayer(), "Hufeisenhelfer")) > 0)) then
            if (isInAnyHufeisenCol()) then
                if (not (muteHufeisen)) then
                    playSound("FILES/SOUNDS/Windows_Battery_Critical.wav")
                end
            end
        end
    end
    setTimer(startCheckHufeisenTimer, 500, 1)
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), startCheckHufeisenTimer)

function syncHufeisen(thecolshape)
    if (isElement(thecolshape) and isElement(colshapedata[thecolshape])) then
        local pickup = colshapedata[thecolshape]
        local x, y, z = getElementPosition(pickup)
        local mx, my, mz = getElementPosition(getLocalPlayer())
        local hit, nx, ny, z = processLineOfSight(x, y, 700, x, y, -10, true, false, false)
        if (hit) then
            setElementPosition(pickup, x, y, z + 1)
        else
            setElementPosition(pickup, x, y, 0)
        end
    end
end

function isInAnyHufeisenCol()
    local colsahpe = false
    for theKey, theColShape in pairs(colshapedata) do
        if (isElement(theKey) and isElement(theColShape)) then
            if (isElementWithinColShape(getLocalPlayer(), theKey)) then
                colsahpe = true
                syncHufeisen(theKey)
            end
        end
    end

    return colsahpe
end

function findHufeisen(thePlayer)
    if (thePlayer == getLocalPlayer()) then
        triggerServerEvent("foundHufeisen_func", getLocalPlayer())
        if (isElement(source)) then
            destroyElement(source)
        end
        if (isElement(pickuocolshapedata[source])) then
            destroyElement(pickuocolshapedata[source])
        end
        if (pickuocolshapedata[source]) then
            colshapedata[pickuocolshapedata[source]] = false
        end
    end
end
