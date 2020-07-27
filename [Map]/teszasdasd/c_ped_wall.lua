-- 
-- c_ped_wall.lua
--

-- the efect settings
local colorizePed = {1, 0.5, 0, 1} -- rgba colors 
local specularPower = 1.3
local effectMaxDistance = 50
local isPostAura = true

-- don't touch
local scx, scy = guiGetScreenSize ()
local effectOn = nil
local myRT = nil
local myShader = nil
local isMRTEnabled = false
local wallShader = {}
local PWTimerUpdate = 110
local actKey = 'o'

-----------------------------------------------------------------------------------
-- enable/disable
-----------------------------------------------------------------------------------
function enablePedWall(isMRT)
	if isMRT and isPostAura then 
		myRT = dxCreateRenderTarget(scx, scy, true)
		myShader = dxCreateShader("fx/post_edge.fx")
		if not myRT or not myShader then 
			outputChatBox('PedWall: Out of memory!',255,0,0)
			isMRTEnabled = false
			return
		else
			outputDebugString('PedWall: Enabled MRT variant')
			dxSetShaderValue(myShader, "sTex0", myRT)
			dxSetShaderValue(myShader, "sRes", scx, scy)
			isMRTEnabled = true
		end
	else
		outputDebugString('PedWall: Enabled non MRT variant')
		isMRTEnabled = false
	end
	pwEffectEnabled = true
	enablePedWallTimer(isMRTEnabled)
	outputChatBox('PedWall turned on',255,128,0)
	outputChatBox('Press '..actKey..' for x-ray vision',255,128,0)
end

function disablePedWall()
	pwEffectEnabled = false
	disablePedWallTimer()
	if isElement(myRT) then
		destroyElement(myRT)
	end
	outputChatBox('PedWall turned off',255,128,0)
end


-----------------------------------------------------------------------------------
-- create/destroy per player
-----------------------------------------------------------------------------------
function createWallEffectForPlayer(thisPlayer, isMRT)
    if not wallShader[thisPlayer] then
		if isMRT then 
			wallShader[thisPlayer] = dxCreateShader("fx/ped_wall_mrt.fx", 1, 0, true, "ped")
		else
			wallShader[thisPlayer] = dxCreateShader("fx/ped_wall.fx", 1, 0, true, "ped")
		end
		if not wallShader[thisPlayer] then return false
		else
			if myRT then
				dxSetShaderValue (wallShader[thisPlayer], "secondRT", myRT)
			end
			dxSetShaderValue(wallShader[thisPlayer], "sColorizePed",colorizePed)
			dxSetShaderValue(wallShader[thisPlayer], "sSpecularPower",specularPower)
			engineApplyShaderToWorldTexture ( wallShader[thisPlayer], "*" , thisPlayer )
			engineRemoveShaderFromWorldTexture(wallShader[thisPlayer],"muzzle_texture*", thisPlayer)
			if not isMRT then
				if getElementAlpha(thisPlayer)==255 then setElementAlpha(thisPlayer, 254) end
			end
		return true
		end
    end
end

function destroyShaderForPlayer(thisPlayer)
    if wallShader[thisPlayer] then
		engineRemoveShaderFromWorldTexture(wallShader[thisPlayer], "*" , thisPlayer)
		destroyElement(wallShader[thisPlayer])
		wallShader[thisPlayer] = nil
	end
end

function enablePedWallTimer(isMRT)
	if PWenTimer then 
		return 
	end
	PWenTimer = setTimer(	function()
		if getKeyState( actKey ) == true and pwEffectEnabled then 
			effectOn = true
		else 
			effectOn = false			
		end
		for index,thisPlayer in ipairs(getElementsByType("player")) do
			if isElementStreamedIn(thisPlayer) and thisPlayer~=localPlayer then
				local hx,hy,hz = getElementPosition(thisPlayer)            
				local cx,cy,cz = getCameraMatrix()
				local dist = getDistanceBetweenPoints3D(cx,cy,cz,hx,hy,hz)
				local isItClear = isLineOfSightClear (cx,cy,cz, hx,hy, hz, true, false, false, true, false, true, false, thisPlayer)
				if (dist<effectMaxDistance ) and not isItClear and effectOn then 
					createWallEffectForPlayer(thisPlayer, isMRT)
				end 
				if (dist>effectMaxDistance ) or  isItClear or not effectOn then 
					destroyShaderForPlayer(thisPlayer) 
				end
			end
			if not isElementStreamedIn(thisPlayer) then destroyShaderForPlayer(thisPlayer) end
		end
	end
	,PWTimerUpdate,0 )
end

function disablePedWallTimer()
	if PWenTimer then
		for index,thisPlayer in ipairs(getElementsByType("player")) do
			destroyShaderForPlayer(thisPlayer)
		end
		killTimer( PWenTimer )
		PWenTimer = nil		
	end
end

-----------------------------------------------------------------------------------
-- onClientPreRender
-----------------------------------------------------------------------------------
addEventHandler( "onClientPreRender", root,
    function()
		if not pwEffectEnabled or not isMRTEnabled or not effectOn then return end
		-- Clear secondary render target
		dxSetRenderTarget( myRT, true )
		dxSetRenderTarget()
    end
, true, "high" )


-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
		if not pwEffectEnabled or not isMRTEnabled or not effectOn then return end
		-- Show contents of secondary render target
		dxDrawImage( 0, 0, scx, scy, myShader )
    end
)
