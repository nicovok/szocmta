function putPlayerInPosition(timeslice)
    if isChatBoxInputActive() or isConsoleActive() then return end
    
    local cx,cy,cz,ctx,cty,ctz = getCameraMatrix()
    ctx,cty = ctx-cx,cty-cy
    timeslice = timeslice*0.1

    if getKeyState("mouse1") then timeslice = timeslice*10 end
    if getKeyState("lshift") then timeslice = timeslice*4 end
    if getKeyState("lalt") then timeslice = timeslice*0.25 end
    local mult = timeslice/math.sqrt(ctx*ctx+cty*cty)
    ctx,cty = ctx*mult,cty*mult
    if getKeyState("w") then
        abx,aby = abx+ctx,aby+cty
        local a = rotFromCam(0)
        setElementRotation(element,0,0,a)
    end
    if getKeyState("s") then
        abx,aby = abx-ctx,aby-cty
        local a = rotFromCam(180)
        setElementRotation(element,0,0,a)
    end
    if getKeyState("d") then
        abx,aby = abx+cty,aby-ctx
        local a = rotFromCam(90)
        setElementRotation(element,0,0,a)
    end
    if getKeyState("a") then
        abx,aby = abx-cty,aby+ctx
        local a = rotFromCam(-90)
        setElementRotation(element,0,0,a)
    end
    if getKeyState("space") then
        abz = abz+timeslice
    end
    if getKeyState("lctrl") then
        abz = abz-timeslice
    end

    tempPos = abx, aby, abz
    setElementPosition(element,abx,aby,abz)
end

function toggleAirBrake()
    air_brake = not air_brake or nil
    if air_brake then
        abx,aby,abz = getElementPosition(element)
        setElementFrozen(element, true)
        --setElementCollisionsEnabled(element,false)
        addEventHandler("onClientPreRender",root,putPlayerInPosition)
    else
        abx,aby,abz = nil
        setElementFrozen(element, false)
        --setElementCollisionsEnabled(element,true)
        removeEventHandler("onClientPreRender",root,putPlayerInPosition)
        element = nil
    end
end

function rotFromCam(rzOffset)
    local cx,cy,_,fx,fy = getCameraMatrix(localPlayer)
    local deltaY,deltaX = fy-cy,fx-cx
    local rotZ = math.deg(math.atan((deltaY)/(deltaX)))
    if deltaY >= 0 and deltaX <= 0 then
        rotZ = rotZ+180
    elseif deltaY <= 0 and deltaX <= 0 then
        rotZ = rotZ+180
    end
    return -rotZ+90 + rzOffset
end

addEventHandler("onClientVehicleExit", getRootElement(), function()
    if source == element then
        toggleAirBrake()
    end
end)

addCommandHandler("fly", function(cmd)
    --if (isPlayerHavePermissionTo(localPlayer, cmd)) then
        local veh = getPedOccupiedVehicle(localPlayer)
        element = veh and veh or localPlayer
        toggleAirBrake()
    --end
end)