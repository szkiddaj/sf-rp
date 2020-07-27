--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchPedWall", root, true )
--
--	To switch off:
--			triggerEvent( "switchPedWall", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
--		Auto switch on at start
--------------------------------

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
	function()
		local isMRT = false
		if dxGetStatus().VideoCardNumRenderTargets > 1 then 
			isMRT = true 
			outputDebugString('pedWall: MRT in shaders enabled') 
		end
		triggerEvent("switchPedWall", resourceRoot, true, isMRT) -- default on
		addCommandHandler("sPedWall",
			function()
				triggerEvent("switchPedWall", resourceRoot, not pwEffectEnabled, isMRT)
			end
		)
	end
)

--------------------------------
-- Switch effect on or off
--------------------------------
function switchPedWall(pwOn, isMRT)
	outputDebugString("switchPedWall: " .. tostring(pwOn)..' MRT: '..tostring(isMRT))
	if pwOn then
		enablePedWall(isMRT)
	else
		disablePedWall()
	end
end

addEvent("switchPedWall", true)
addEventHandler("switchPedWall", resourceRoot, switchPedWall)
