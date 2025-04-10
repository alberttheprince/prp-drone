function lerp(x1, x2, t) 
    return x1 + (x2 - x1) * t
end

function math.clamp(value, minClamp, maxClamp)
	return math.min(maxClamp, math.max(value, minClamp))
end

function SetEntityRotationVelocity(entity, x, y, z)
	return Citizen.InvokeNative(0x2887A125, entity, x, y, z)
end

aspectRatio = GetAspectRatio()

function DrawGameText(x, y, text, r, g, b, a, scale)
	SetTextFont(13)
	SetTextProportional(1)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(tostring(text))
	DrawText(x, y)
end

function DrawRectOutline(x, y, width, height, thickness, r, g, b, a)
	local tx = thickness/aspectRatio
	local ty = thickness

	-- top
	DrawRect(x, y - height/2 + ty/2, width - tx*2, ty, r, g, b, a)

	-- bottom
	DrawRect(x, y + height/2 - ty/2, width - tx*2, ty, r, g, b, a)

	-- left
	DrawRect(x - width/2 + tx/2, y, tx, height, r, g, b, a)

	-- right
	DrawRect(x + width/2 - tx/2, y, tx, height, r, g, b, a)
end

function RenderAltitudeMeter(z)
	DrawRectOutline(0.0725, 0.5, 0.025, 0.25, 0.001, 0, 0, 0, 255)
	DrawRect(0.0725, 0.5, 0.025, 0.25, 0, 0, 0, 128)
	for i=1,20 do
		local scale = ((i+z) % 20.0) / 20.0
		local a = math.floor(((0.5-math.abs(scale-0.5))*2.0)*128)
		local y = 0.375+(scale*0.25)
		DrawRect(0.0725, y, i % 10 == 0 and 0.02 or 0.01, 0.005, 255, 255, 255, a)
	end
	DrawGameText(0.0725, 0.63, string.format("%.2f", z), 255, 255, 255, 255, 0.25)
end

function RenderPitchMeter(pitch)
	DrawRectOutline(0.925, 0.5, 0.025, 0.25, 0.001, 0, 0, 0, 255)
	DrawRect(0.925, 0.5, 0.025, 0.25, 0, 0, 0, 128)
	for i=0,20-1 do
		local scale = ((pitch+(i/20)*90) % 90) / 90
		local a = math.floor(((0.5-math.abs(scale-0.5))*2.0)*128)
		local y = 0.375+(scale*0.25)
		DrawRect(0.925, y, i % 10 == 0 and 0.02 or 0.01, 0.005, 255, 255, 255, a)
	end
	DrawGameText(0.925, 0.63, string.format("%.2f", pitch), 255, 255, 255, 255, 0.25)
end

function RenderCompassRibbon(heading)
	DrawRectOutline(0.5, 0.1, 0.5, 0.03, 0.001, 0, 0, 0, 255)
	DrawRect(0.5, 0.1, 0.5, 0.03, 0, 0, 0, 128)
	for i=0,40-1 do
		local scale = ((heading+(i/40)*180) % 180) / 180
		local a = math.floor(((0.5-math.abs(scale-0.5))*2.0)*128)
		local x = 0.25+(scale*0.5)
		DrawRect(x, 0.1, 0.0025, i % 10 == 0 and 0.025 or 0.0125, 255, 255, 255, a)
	end
	DrawGameText(0.5, 0.065, string.format("%.2f", (180-heading)%360), 255, 255, 255, 255, 0.25)
end

function bleep()
	CreateThread(function()
		local id = GetSoundId()
		PlaySoundFrontend(id, "Out_of_Bounds", "MP_MISSION_COUNTDOWN_SOUNDSET", 0, 0)
		-- PlaySoundFrontend(id, "OOB_Timer_Dynamic", "GTAO_FM_Events_Soundset", 0, 0)
		Wait(100)
		StopSound(id)
		ReleaseSoundId(id)
	end)
end

function RenderDroneHud()

	local border = true
	
	-- oob warning
	if oob or returning then
		local b = (returning and (GetGameTimer() % 100 > 50)) or (not returning and (GetGameTimer() % 500 > 250))
		DrawGameText(0.5, 0.25, returning and "SIGNAL CRITICAL" or "SIGNAL LOW", 255, b and 255 or 0, b and 255 or 0, 255, 1.0)
	end

	-- exiting drone
	if exiting > 0.0 then
		local disp_exiting = ((exiting*10)^2) / (10^2)
		DrawGameText(0.5, 0.3, "EXITING", 255, 0, 0, math.floor(disp_exiting * 255), 0.75)
		DrawRect(0.5 - (0.2 * 0.5) + (0.2 * disp_exiting * 0.5), 0.375, 0.2 * disp_exiting, 0.025, 255, 0, 0, 255)
		DrawRectOutline(0.5, 0.375, 0.2, 0.025, 0.005, 0, 0, 0, 255)
	end

	-- black border
	if (not returning and oob and GetGameTimer() % 500 > 250) or (returning and GetGameTimer() % 100 > 50) then
		if not playedbleep then
			playedbleep = true
			bleep()
		end
		DrawRectOutline(0.5, 0.5, 1.01, 1.1, 0.1, 192, 0, 0, 128)
	else
		if playedbleep then
			playedbleep = false
		end
		DrawRectOutline(0.5, 0.5, 1.01, 1.1, 0.1, 0, 0, 0, 128)
	end
	
	-- thin gray border
	DrawRectOutline(0.5, 0.5, 0.9, 0.9, 0.005, 128, 128, 128, 255)

	-- gray lines
	DrawRect(0.5, 0.025, 0.005/aspectRatio, 0.05, 128, 128, 128, 255)
	DrawRect(0.5, 0.975, 0.005/aspectRatio, 0.05, 128, 128, 128, 255)
	DrawRect(0.025, 0.5, 0.05, 0.005/aspectRatio, 128, 128, 128, 255)
	DrawRect(0.975, 0.5, 0.05, 0.005/aspectRatio, 128, 128, 128, 255)

	-- altitude meter
	RenderAltitudeMeter(GetEntityCoords(NetToObj(object)).z)
	
	-- pitch meter
	RenderPitchMeter(pitch)

	-- compass ribbon
	RenderCompassRibbon(heading)

	-- speedo
	local vel = GetEntityVelocity(NetToObj(object))
	local speedscale = math.min(#vel/22, 1.0)
	DrawRectOutline(0.5, 0.9, 0.25, 0.03, 0.001, 0, 0, 0, 255)
	DrawRect(0.5, 0.9, 0.25, 0.03, 0, 0, 0, 64)
	DrawRect((0.5-0.25/2) + ((0.5-0.25/2) - 0.25) * speedscale, 0.9, 0.25*speedscale*0.99, 0.03*0.99, 64, 128, 255, 128)
	DrawGameText(0.5, 0.9225, string.format("%.2f/%.2f", boostSpeed*speedscale, speed), 255, 255, 255, 255, 0.25)
end

function IsController()
	return not IsInputDisabled(2)
end

function rand()
	return 1.0 - (math.random() * 2.0)
end

fadetime = 500
heading = 0

maxDistance = 100.0
baseSpeed = 1.0
boostSpeed = 8.0
speed = 0

baseFov = 50.0
zoomFov = 20.0

dir = vec(0,0,0)
flightVel = vec(0,0,0)
turbulence = vec(0,0,0)
turbulenceTarget = vec(0,0,0)
headingTarget = 0
pitchTarget = 0

lastvel = vec(0,0,0)
lastbounce = 0

flying = false
oob = false
return_start = 0

exiting = 0

function StartDrone(args)
	CreateThread(function()
		if not flying then
			DoScreenFadeOut(fadetime)
			Wait(fadetime)
		
			-- local model = `ch_prop_casino_drone_02a`
			local model = args[1] or "xs_prop_arena_drone_02"
			-- local model = "rcbandito"
			RequestModel(model)
			repeat Wait(0) until HasModelLoaded(model)
			
			SetPlayerControl(PlayerId(), false)

			local spawnPos = GetEntityCoords(PlayerPedId()) + vector3(0.0, 0.0, 3.0)
			local spawnHeading = GetEntityHeading(PlayerPedId()) + 180.0

			object = CreateObject(model, spawnPos, true, true, false)
			SetEntityHasGravity(object, false)
			SetEntityHeading(object, spawnHeading)
			heading = GetEntityHeading(object)
			headingTarget = heading
			SetFocusEntity(object)

			object = ObjToNet(object)

			blip = AddBlipForEntity(NetToObj(object))
			SetBlipSprite(blip, 627)
			
			-- radius = AddBlipForRadius(spawnPos, maxDistance)
			-- SetBlipAlpha(radius, 64)
			-- SetBlipColour(radius, 3)

			id = GetSoundId()
			PlaySoundFromEntity(id, "Flight_Loop", NetToObj(object), "DLC_BTL_Drone_Sounds", true, 0)
			--SetVariableOnSound(id, "DroneRotationalSpeed", 1.0)

			cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
			SetCamCoord(cam, 10.5, 13.6, 75.3)
			SetCamRot(cam, 0.0, 0.0, 180.0)
			SetCamFov(cam, baseFov)
			--ShakeCam(cam, "HAND_SHAKE", 0.19)
			RenderScriptCams(true, false, fadetime, true, true)
			--AttachCamToEntity(cam, NetToObj(object), 0.0, 0.0, 0.0, false)
			--PointCamAtEntity(cam, NetToObj(object), 0.0, 0.0, 0.0, 1)
			
			flying = true
			thirdperson = true
			pitch = 0
			speed = 0
			fov = baseFov
			
			DoScreenFadeIn(fadetime)
			
			while flying do Wait(0)
				DisableInputGroup(0)
				
				RenderDroneHud()
				
				local leftX = GetDisabledControlUnboundNormal(2, 218) -- INPUT_SCRIPT_LEFT_AXIS_X
				local leftY = GetDisabledControlUnboundNormal(2, 219) -- INPUT_SCRIPT_LEFT_AXIS_Y
				local rightX = GetDisabledControlUnboundNormal(2, 220) -- INPUT_SCRIPT_RIGHT_AXIS_X
				local rightY = GetDisabledControlUnboundNormal(2, 221) -- INPUT_SCRIPT_RIGHT_AXIS_Y

				local up = GetDisabledControlUnboundNormal(2, 22) -- INPUT_JUMP
				local down = GetDisabledControlUnboundNormal(2, 36) -- INPUT_DUCK
				
				if IsController() then
					up = GetDisabledControlUnboundNormal(2, 229) -- INPUT_SCRIPT_RT
					down = GetDisabledControlUnboundNormal(2, 228) -- INPUT_SCRIPT_LT
				end
				
				if IsDisabledControlJustPressed(2, 23) --[[ INPUT_ENTER ]] then
					thirdperson = not thirdperson
				end
				
				if IsDisabledControlPressed(2, 202) --[[ INPUT_FRONTEND_CANCEL ]] then
					exiting += GetFrameTime()
					if exiting >= 1.0 then
						flying = false
					end
				else
					exiting = 0
				end

				-- speed = baseSpeed
				local boosting = false
				
				if IsController() then
					boosting = IsDisabledControlPressed(2, 44) -- INPUT_COVER
				else
					boosting = IsDisabledControlPressed(2, 21) -- INPUT_SPRINT
				end
				
				speed = lerp(speed, boosting and boostSpeed or baseSpeed, 1.0 * GetFrameTime())
				
				if IsDisabledControlPressed(2, 38) --[[ INPUT_PICKUP ]] then
					if fov > zoomFov then
						fov -= 100.0 * GetFrameTime()
					end
				else --[[ INPUT_PICKUP ]]
					if fov < baseFov then
						fov += 100.0 * GetFrameTime()
					end
				end
				
				-- local heading = GetEntityHeading(NetToObj(object))
				
				if IsController() then
					headingTarget += rightX * -2.0 * (100.0*GetFrameTime())
					-- pitchTarget = math.clamp(pitchTarget - rightY * 2.0 * (100.0*GetFrameTime()), -90.0, 15.0)
				else
					headingTarget += rightX * -2.0
				end
				
				heading = lerp(heading, headingTarget, 10.0 * GetFrameTime())
				-- pitch = lerp(pitch, pitchTarget, 10.0 * GetFrameTime())
				
				-- heading += rightX * -2.0 * (100.0*GetFrameTime())
				pitch = math.clamp(pitch - rightY * 2.0 * (100.0*GetFrameTime()), -90.0, 15.0)
				
				local x = (math.cos(math.rad(heading)) * leftX) + (math.sin(math.rad(heading)) * leftY)
				local y = (math.cos(math.rad(heading)) * leftY) - (math.sin(math.rad(heading)) * leftX)
				local z = up - down
				
				-- dir = vec(x, y, z)
				dir = lerp(dir, vec(x, y, z), 10.0 * GetFrameTime())
				
				if math.random() < 0.1 then
					turbulenceTarget = vec(rand(), rand(), rand() * 0.25) * 0.05 -- * (GetWindSpeed() / 100.0)
					turbulenceTarget += GetWindDirection() * (0.5*math.random()) * (GetWindSpeed() / 100.0)
					-- turbulenceTarget = GetWindDirection() * (GetWindSpeed() / 100.0)
				end
				
				turbulence = lerp(turbulence, turbulenceTarget, 5.0 * GetFrameTime())
				
				local vel = GetEntitySpeedVector(NetToObj(object), true)
				
				flightVel = vec(0,0,0)
				
				if not returning then
					flightVel = vector3(-dir.x * speed, dir.y * speed, z)
				end
				flightVel += turbulence
				
				-- SetEntityVelocity(NetToObj(object), x, y, z)
				
				local currentvel = GetEntityVelocity(NetToObj(object))
				local gforce = lastvel - currentvel
				
				if #gforce > 5.0 then
					-- if #gforce < 6.0 then
						-- print("G Force is over 6")
					-- end
					if GetGameTimer() > lastbounce + 100 then
						lastbounce = GetGameTimer()
						flightVel = gforce * -1.0
						dir *= vec(-1.0, -1.0, 1.0)
						print(flightVel)
					end
				end
				
				ApplyForceToEntityCenterOfMass(NetToObj(object), 1, flightVel, false, false, true, false)
				SetEntityRotation(NetToObj(object), -vel.y, vel.x, heading)
				SetVariableOnSound(id, "DroneRotationalSpeed", math.abs(rightX))
				
				local playerpos = GetEntityCoords(PlayerPedId())
				local entpos = GetEntityCoords(NetToObj(object))
				local d = norm(playerpos - entpos)
				
				local dist = #(playerpos - entpos)
				local scale = math.min(1.0, math.max(0.0, dist-(maxDistance-10.0))/10.0)
				-- DrawSphere(playerpos.x, playerpos.y, playerpos.z, maxDistance, 255, 0, 0, scale/4)
				
				-- DrawMarker(
					-- 28, 
					-- playerpos, 
					-- 0.0, 0.0, 0.0,
					-- 0.0, 0.0, 0.0,
					-- maxDistance, maxDistance, maxDistance,
					-- 255, 0, 0, math.floor(scale * 64),
					-- false,
					-- false,
					-- 0,
					-- false)
					
				oob = dist > maxDistance
				
				if not returning and dist > maxDistance + 10.0 then
					returning = true
					return_start = GetGameTimer()
				elseif returning and dist < maxDistance - 10.0 then
					returning = false
				end
				
				if returning then
					ApplyForceToEntityCenterOfMass(NetToObj(object), 1, d, false, false, true, false)					
				end
				
				-- fallback for failing to return in-bounds
				if dist > (maxDistance*1.5) or (returning and GetGameTimer() > return_start + 10000) then
					-- print("over max distance")
					-- AddExplosion(entpos.x, entpos.y, entpos.z, 0, 1.0, true, false, true)
					Wait(500)
					DoScreenFadeOut(500)
					Wait(500)
					local d = norm(entpos - playerpos)
					local pos = playerpos + (d*maxDistance*0.25)
					SetEntityCoords(NetToObj(object), pos.x, pos.y, playerpos.z+3.0)
					DoScreenFadeIn(500)
				end

				-- SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(NetToObj(object), 0.0, -0.1, -0.1))
				--SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(NetToObj(object), 0.0, 1.0, 0.0))
				
				if thirdperson then
					local pos = GetEntityCoords(NetToObj(object))
					local campos = pos + vector3(
						math.cos(math.rad(pitch)) * math.sin(math.rad(-headingTarget)) * 1.5, 
						math.cos(math.rad(pitch)) * math.cos(math.rad(-headingTarget)) * 1.5, 
						math.sin(math.rad(-pitch)) + 0.25)
					SetCamCoord(cam, campos)
					SetCamRot(cam, pitch, 0.0, headingTarget+180.0)
					LockMinimapAngle(math.floor(180.0 + headingTarget) % 360)
				else
					SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(NetToObj(object), 0.0, -0.1, -0.1))
					SetCamRot(cam, pitch, -vel.x*0.25, heading+180.0)
					LockMinimapAngle(math.floor(180.0 + heading) % 360)
				end
				-- SetCamRot(cam, pitch, 0.0, GetEntityRotation(NetToObj(object)).z+180.0)
				SetCamFov(cam, fov)
				
				SetBlipSquaredRotation(blip, heading)
				-- SetBlipCoords(radius, playerpos)

				LockMinimapPosition(GetEntityCoords(NetToObj(object)).x, GetEntityCoords(NetToObj(object)).y)
				
				lastvel = currentvel
			end
			
			DoScreenFadeOut(fadetime)
			Wait(fadetime)

			SetPlayerControl(PlayerId(), true)
			RenderScriptCams(false, false, fadetime, true, true)
			DeleteObject(NetToObj(object))
			DestroyCam(cam)
			RemoveBlip(blip)
			-- RemoveBlip(radius)
			SetFocusEntity(PlayerPedId())
			StopSound(id)
			
			UnlockMinimapAngle()
			UnlockMinimapPosition()
			
			DoScreenFadeIn(fadetime)
			Wait(fadetime)
			
		end
	end)
end)

function StopDrone()
    flying = false
end

function ToggleDrone(args)
    if flying then
        StopDrone()
    else
        StartDrone(args)
    end
end

exports('toggleDrone', ToggleDrone)

---- RegisterCommand("drone", function(source, args)
--     StartDrone(args)
-- end)

-- RegisterCommand("stopdrone", function()
--     StopDrone()
-- end)
