-- KrunchLoader
-- ---------------------------
-- by Krunch
-- A custom Map Loader for Trailmappers
-- Includes code from the Trailmappers Loader by Ridicolas & Jess2005
-- This mod is a work in progress (WIP) and may contain bugs
-- Use of this mod is entirely at your OWN RISK
-- Find help & report bugs at the TM Discord modding channel @ http://discord.gg/trailmakers
-- Read the "ReadMe.txt" file that accompanies this mod for more information
-- Support me & send feedback by visiting: http://ko-fi.com/krunchcreates
-- ------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------

-- How to use Physics Materials 
-- ----------------------------

-- Add a physics material to a custom object by applying a specially named texture to it in TrailMappers. Use the following naming format:

-- mtl_MaterialName_texturename.png (or .jpg)

-- mtl = Material prefix  << allows the code to find objects with special physics materials
-- _MaterialName_ = physics material name  << the script will 'extract' the physics material name from between the underscores

-- Examples:
-- mtl_Grass_mainterrain.png << started with a texture called "mainterrain.png"
-- mtl_Sand_sandyzones.png << started with a texture called "sandyzones.png"
-- mtl_IceSlippery_shinysmooth.jpg << started with a texture called "shinysmooth.jpg"

-- to create a "Grass" physics material for all objects using a texture called mainterrain.png the texture name should look like this:
-- add the material prefix ("mtl") to the name followed by the Physics Material Name from the list below

-- mtl_Grass_mainterrain.png

-- Physics Material Names (Case Sensitive!)
-- ----------------------------------------
-- Metal
-- Sand
-- Stone
-- Gravel
-- Grass
-- Mud
-- Lava
-- Asphalt << default physics material 
-- Snow
-- Wood
-- YellowSand
-- WitheredGrass
-- IceSlippery
-- Tundra
-- SnowHard
-- GrassYellow
-- --------------------------
-- ------------------------------------------------------------------------------------------

tm.physics.AddTexture("data_static\\map_icon.png", "icon")

local useTabMap = false
local file = tm.os.ReadAllText_Static("tabMapTex.jpg")

if #file > 10000 then
    tm.physics.AddTexture("data_static\\tabMapTex.jpg", "TabMapTex")
    tm.physics.AddMesh("data_static\\tabMapMesh.obj", "TabMapMesh")
    useTabMap = true
end

--- BASIC LOADER VARIABLES
local needToSpawn
local startAmount
local message = ""
local name = ""
local customThings = {}
local wait = 0

--- CUSTOM LOADER VARIABLES
local modVer = "2026.0.6"
local UILoadPercent = 0
local homeSpawnpointName = "Home"
local spawnpointInfo
local spawnPointTable = {}
local homeSpawnPointTable = {}
local takeBlueprintToSpawn = true
local SP_ID = 1 -- Spawn Point ID (starts at 1)
local fastTravelEnabled = false
local SPProtectionEnabled = true
local colOn = "<color=#5f5>"
local colOff = "<color=#fd0>"
local modDelta = 60
local slowDelta = 12
local playerDataTable = {}
local getMap = tm.physics.GetMapName()
local levelHeight = 0
if getMap == "WLD_TestZone" then
    levelHeight = 300
elseif getMap == "WLD_TheMoon" then
    levelHeight = 0
else
    levelHeight = 200
end
local TZWind = false
local windBox
local WBIDtable = {}
local simpleWater = false
local tempPos = tm.vector3.Create(0,0,0)
local nameBoxSpawnTable = {}
local NB_ID = 0 -- NameBox ID
local BB_ID = 0 -- BuildBox ID
local buildBoxBan = true -- if true then build boxes are banned areas for building, otherwise builder boxes are the only areas that allow building
local UIbuilderMsg = "<size=12><color=#bfb><b>Build Zone - Builder unlocked"
local tabMapPos = tm.vector3.Create(0, 1000, 0)
local tabMapCam1Pos = tm.vector3.Create(0, 1000.415, 0)
local tabMapCam1Rot = tm.vector3.Create(0, -1, 0)
local AerialCamMessage
local AerialCamMessage2
if useTabMap then
    local tabMap = tm.physics.SpawnCustomObject(tabMapPos, "TabMapMesh", "TabMapTex")
	tabMap.SetIsTrigger(true)
end
local playerJoinMessage = {
    "has pizza on their shirt",
    "has arrived in style",
    "feels the need for speed",
    "tends to leave a trail",
    "reads instruction manuals",
    "types with an accent",
    "likes to make trailers",
    "can hear colors"
    }
local fastTravelMessage = {
    "Were you lost?",
    "Melvin never Fast Travels",
    "Slow Travel is underappreciated",
    "You can run but you can't hide",
    "Did you bring your toothbrush?",
    }
local pos = {}
local rot = {}
local connectedPlayers = {}

--- KEYBINDS
--- certain special keys require double square brackets instead of quotation marks (eg the \ key should be [[\]])
--- quotation keys require the use of an alternative quotation character type (eg "'" or '"')
--- single square brackets around a number key denote a number pad key (eg. "[1]" is number pad 1, "1" is keyboard 1)
local keyStraight = "up"
local keyLeft = "left"
local keyRight = "right"
local keyAlt = "down"
local keyBuilder = "b"

--- sound effects
-- BLCK_PRP_TailPropeller_Stop -> faintish downward cymbol hit
local SFX_activate = "UI_BLDR_Config_InputAssigned"
local SFX_deactivate = "UI_BLDR_Config_InputCleared"
local SFX_ding = "Build_CookBookr_StepCorrect"
local SFX_bigClick = "UI_Mission_Deliver_BTN_Click"
local SFX_mapLoaded = "UI_Pioneers_TrailmakersLevelUp_LevelGained"
local SFX_genericButton = "UI_Builder_Click"
local SFX_genericButton2 = "AVI_NPC_Intercom_Typing_Terry" 
local SFX_positive = "Block_Flamethrower_OutOfAmmo_Oneshot"
local SFX_negative = "UI_Generic_ErrorPopup"
local SFX_negativeStrong = "Build_UndoBuildOperation_fail"
local SFX_spawnWarp = "PLYR_Space_WorldWrap"
------------------------------------------------------------

tm.os.SetModTargetDeltaTime(1/modDelta)

function onPlayerJoined(player)
    
    local playerName = string.sub(tm.players.GetPlayerName(player.playerId), 1, 30)
    tm.os.Log(playerName)
    tm.os.Log("just joined with ID: "..player.playerId)
    
    playerDataTable[player.playerId] = {
        updateTick = 0,
        refreshUI = false,
        windBoxID = nil,
        doWindForce = false,
        wBoxCount = 0,
        nBoxCount = 0,
        bBoxCount = 0,
        isLoading = true,
        plrInBuildMode = false,
        spawnTimeStamp = 99999999,
        getPos = false,
        loadJoin = false,
        lateJoin = false,
        UIbuilderMsg = UIbuilderMsg,
        inMenu = "UILoading",
        spawnPoint = false,
        spawnPointPos = nil,
        spawnPointRot = nil,
        inTabMap1 = false,
        inTabMap2 = false,
        inAerialCam1 = false,
        inAerialCam2 = false,
        atArea = "",
        fastTraveled = false,
        ftTimestamp = 99999999,
        isBlocked = false,
        isInBuilderBox = false,
		joinMessage = "",
		joinMessage2 = "",
        }
    
    --- hotkeys
    tm.input.RegisterFunctionToKeyDownCallback(player.playerId, "onKeyBuilder", keyBuilder)
    tm.input.RegisterFunctionToKeyDownCallback(player.playerId, "onTabMap", "tab")
    tm.input.RegisterFunctionToKeyDownCallback(player.playerId, "onAerialCam", "[0]")
    ---
    
    if player.playerId == 0 then
        tm.players.SetBuilderEnabled(player.playerId, false)
        loadMap(player.playerId)
        doSpawnPoints(player.playerId)
        UILoading(player.playerId)
    else
        if tm.players.GetPlayerTransform(player.playerId) ~= nil then
            playerDataTable[player.playerId].getPos = true
            doSpawnPoints(player.playerId)
            tm.os.Log("successfully got player location for player "..tostring(player.playerId))
        else 
            playerDataTable[player.playerId].getPos = false
            tm.os.Log("can't yet get player location for player "..tostring(player.playerId))
        end
        
        if UILoadPercent == 100 then
            tm.players.SetBuilderEnabled(player.playerId, true)
            playerDataTable[player.playerId].lateJoin = true
            UIMain(player.playerId)
        else
            UILoading(player.playerId)
            tm.players.SetBuilderEnabled(player.playerId, false)
            playerDataTable[player.playerId].loadJoin = true
        end
    end
	
	connectedPlayers[player.playerId] = tostring(tm.players.GetPlayerName(player.playerId))

	playerDataTable[player.playerId].joinMessage = tm.playerUI.AddSubtleMessageForAllPlayers(tm.players.GetPlayerName(player.playerId), "is joining the server", 30, "icon")
	
    tm.players.AddCamera(player.playerId, tabMapCam1Pos, tabMapCam1Rot, 9)
end

function onPlayerLeft(player)
    
    if player.playerId ~= nil then
        local plrName = connectedPlayers[player.playerId]
        if plrName == nil then
            plrName = "Player #" .. tostring(player.playerId+1)
        end
		tm.playerUI.AddSubtleMessageForPlayer(0, plrName.." left the server!", nil, 8, "TCP_Base_icon")
	end
end
tm.players.OnPlayerLeft.add(onPlayerLeft)

function tableToVector(table) 
    return tm.vector3.Create(table.x, table.y, table.z)
end

function rotationToDirection(rotation) -- adapted from FiveM-Lua-Snippets/RotationToDirection.lua
    
    -- convert rotation angles from degrees to radians
    local rety = math.rad(rotation.y) -- Yaw
    local retx = math.rad(rotation.x) -- Pitch

    -- calculate the absolute value of the cosine of the pitch
    local absx = math.abs(math.cos(retx))

    -- calculate and return the direction vector
    return tm.vector3.Create(
        math.sin(rety) * absx, -- X component
        -math.sin(retx),       -- Y component (vertical)
        math.cos(rety) * absx  -- Z component
    )
end

function doSpawnPoints(playerId)
    
    -- initialise home spawnpoint
    local hsp1Pos = tableToVector(spawnpointInfo.P)
    local hsp1Rot = tableToVector(spawnpointInfo.R)
    local hsp1spId = "sp1"
    
    -- check if we have player specific home spawnpoint locations
    local next = next
	if next(homeSpawnPointTable) or #homeSpawnPointTable then
        fastTravelEnabled = true
        tm.os.Log("adding player specific home spawnpoint locations")
        if playerId ~= 0 then
            for k,v in pairs(homeSpawnPointTable) do
                if k == tostring(playerId) then
                    hsp1Pos = tableToVector(v.pos)
                    hsp1Rot = rotationToDirection(v.rot)
                    hsp1spId = "sp1-"..tostring(playerId)
                end
            end
        end
	end
    
    hsp1Pos.y = hsp1Pos.y + levelHeight -- adjust Trailmappers spawnpoint height
    
    -- create & assign the home spawnpoint
    tm.players.SetSpawnPoint(playerId, hsp1spId, hsp1Pos, hsp1Rot)
    tm.players.SetPlayerSpawnLocation(playerId, hsp1spId)
    
    -- on joining map teleport all players into the sky above their home spawnpoint locations
    local hsp1PosLoading = tm.vector3.Create(hsp1Pos.x,hsp1Pos.y+5000,hsp1Pos.z)
    tm.players.SetSpawnPoint(playerId, "loading", hsp1PosLoading, hsp1Rot)
    tm.players.TeleportPlayerToSpawnPoint(playerId, "loading", false)
    
    -- setup extra spawnpoints
    local count = 0
    tm.os.Log("Adding custom SpawnPoints")
	local next = next
	if next(spawnPointTable) or #spawnPointTable then
		for k,v in pairs(spawnPointTable) do
			count = count + 1
			local spPos = tableToVector(v.pos)
			spPos.y = spPos.y + levelHeight
			local spRot = rotationToDirection(v.rot)
			local spId = "sp"..tostring(v.id)
			tm.players.SetSpawnPoint(playerId, spId, spPos, spRot)

			_G[spId] = function(callbackData)
				local playerId = callbackData.playerId
				local playerData = playerDataTable[playerId]
				if tm.players.GetPlayerIsInBuildMode(playerId) then
					playAudioFX(playerId, SFX_negative)
					return
				end
				playerData.fastTraveled = true
				playerData.atArea = ""
				playerData.nBoxCount = 0
				playerData.nBoxCount2 = 0
				local spPosHF = tm.vector3.Create(callbackData.data[1].x, callbackData.data[1].y, callbackData.data[1].z)
				spPosHF.y = spPosHF.y + levelHeight
				if isSpawnpointOccupied(playerId, spPosHF, callbackData.data[2]) then
					tm.playerUI.AddSubtleMessageForPlayer(playerId, "Can't Fast Travel", "Spawnpoint is occupied", 5, "icon")
					return
				end
				tm.players.SetPlayerSpawnLocation(playerId, tostring(spId))
				local takeVehicle = false
				if takeBlueprintToSpawn then
					takeVehicle = true
				end
				tm.players.TeleportPlayerToSpawnPoint(playerId, spId, takeVehicle)
				playAudioFX(playerId, SFX_spawnWarp)
				UIMain(playerId)
				tm.playerUI.AddSubtleMessageForPlayer(playerId, callbackData.value, onPlayerFastTravelMessage(playerId), 5, "icon")
			end
		end
	else
		tm.os.Log("no custom spawnpoints found")
	end
end

function isSpawnpointOccupied(playerId, spPos, spRotY)
    
	if not SPProtectionEnabled then return false end
    local playerList = tm.players.CurrentPlayers()
    local objectOnSP = false
    spRotY = tonumber(spRotY)
	local spPos = spPos
    
    -- player proximity check
    for key, player in pairs(playerList) do
        if playerId ~= player.playerId then
            local plrPos = tm.players.GetPlayerTransform(player.playerId).GetPosition()
            if tm.vector3.Distance(spPos, plrPos) < 4 then -- a player is near the target spawnpoint
				playAudioFX(playerId, SFX_negative)
                return true
            end
        end
    end
    
    -- vehicle raycast check
    local spRotYRad = math.rad(spRotY)
    local offsetF = tm.vector3.Create(0, 0, 0)
    offsetF.x = math.sin(spRotYRad) * 5
    offsetF.y = 0.5
    offsetF.z = math.cos(spRotYRad) * 5
    local offsetB = tm.vector3.Create(0, 0, 0)
    offsetB.x = -math.sin(spRotYRad) * 5
    offsetF.y = 0.5
    offsetB.z = -math.cos(spRotYRad) * 5
    local offsetL = tm.vector3.Create(0, 0, 0)
    offsetL.x = -math.cos(spRotYRad) * 5
    offsetF.y = 0.5
    offsetL.z = math.sin(spRotYRad) * 5
    local offsetR = tm.vector3.Create(0, 0, 0)
    offsetR.x = math.cos(spRotYRad) * 5
    offsetF.y = 0.5
    offsetR.z = -math.sin(spRotYRad) * 5
    
    local rayOriginF = spPos + offsetF
    local rayOriginB = spPos + offsetB
    local rayOriginL = spPos + offsetL
    local rayOriginR = spPos + offsetR
	
	local SPD = rotationToDirection(tm.vector3.Create(0, spRotY ,0)) -- Spawn Point Direction
    
    local rayFromFront = tm.vector3.Create(SPD.x*-1,SPD.y,SPD.z*-1) -- from front direction for the ray cast tm.vector3.Create(SPD.x-1,SPD.y,1-SPD.z)
	local rayFromBack = SPD -- from rear direction for the ray cast
	local rayFromLeft = tm.vector3.Create(SPD.z,SPD.y,SPD.x*-1) -- from left direction for the ray cast
	local rayFromRight = tm.vector3.Create(SPD.z*-1,SPD.y,SPD.x) -- from right direction for the ray cast
	
    local hitPos = tm.vector3.Create()
    local raylength = 4.5
   
    local hitSomethingF = tm.physics.Raycast(rayOriginF, rayFromFront, hitPos, raylength, true)
    local hitSomethingB = tm.physics.Raycast(rayOriginB, rayFromBack, hitPos, raylength, true)
    local hitSomethingL = tm.physics.Raycast(rayOriginL, rayFromLeft, hitPos, raylength, true)
    local hitSomethingR = tm.physics.Raycast(rayOriginR, rayFromRight, hitPos, raylength, true)
    if hitSomethingF or hitSomethingB or hitSomethingR or hitSomethingL then
        objectOnSP = true
	else
		rayOriginF.y = rayOriginF.y + 1
		rayOriginB.y = rayOriginF.y + 1
		rayOriginL.y = rayOriginF.y + 1
		rayOriginR.y = rayOriginF.y + 1
		local hitSomethingF = tm.physics.Raycast(rayOriginF, rayFromFront, hitPos, raylength, true)
		local hitSomethingB = tm.physics.Raycast(rayOriginB, rayFromBack, hitPos, raylength, true)
		local hitSomethingL = tm.physics.Raycast(rayOriginL, rayFromLeft, hitPos, raylength, true)
		local hitSomethingR = tm.physics.Raycast(rayOriginR, rayFromRight, hitPos, raylength, true)
		if hitSomethingF or hitSomethingB or hitSomethingR or hitSomethingL then
			objectOnSP = true
		else
			rayOriginF.y = rayOriginF.y + 1
			rayOriginB.y = rayOriginF.y + 1
			rayOriginL.y = rayOriginF.y + 1
			rayOriginR.y = rayOriginF.y + 1
			local hitSomethingF = tm.physics.Raycast(rayOriginF, rayFromFront, hitPos, raylength, true)
			local hitSomethingB = tm.physics.Raycast(rayOriginB, rayFromBack, hitPos, raylength, true)
			local hitSomethingL = tm.physics.Raycast(rayOriginL, rayFromLeft, hitPos, raylength, true)
			local hitSomethingR = tm.physics.Raycast(rayOriginR, rayFromRight, hitPos, raylength, true)
			if hitSomethingF or hitSomethingB or hitSomethingR or hitSomethingL then
				objectOnSP = true
			end
		end
    end
	
    if objectOnSP then
        playAudioFX(playerId, SFX_negative)
        return true
    else
        return false
    end
end

function onClearAllStructures() -- used when map starts loading

    playAudioFX(0, SFX_genericButton)
    local playerList = tm.players.CurrentPlayers()
    for key, player in pairs(playerList) do
        if not tm.players.GetPlayerIsInBuildMode(player.playerId) then
            local structures = tm.players.GetPlayerStructures(player.playerId)
            for _,structure in pairs(structures) do
                structure.Dispose()
            end
        end
    end
end

function onButtonReduceStructures(callbackData)
    
    onReduceStructures(callbackData.playerId)
end

function onReduceStructures(playerId) -- improves performance by disposing of structures that can build up after repairing builds

    playAudioFX(0, SFX_genericButton)
    local playerList = tm.players.CurrentPlayers()
    for key, player in pairs(playerList) do
        if not tm.players.GetPlayerIsInBuildMode(player.playerId) then
            local structures = tm.players.GetPlayerStructures(player.playerId)
            local plrPos = tm.players.GetPlayerTransform(player.playerId).GetPosition()
            for _,structure in pairs(structures) do
                if tm.vector3.Distance(structure.GetPosition(), plrPos) > 50 then -- delete any of the player's structures that are not close to the player
                    structure.Dispose()
                end
            end
        end
    end
end

function loadMap(playerId)
    
    onClearAllStructures()
    
    local file = tm.os.ReadAllText_Static("Map")
    local list = json.parse(file)
    local objects = list.ObjectList
    needToSpawn = objects
    startAmount = #objects
    spawnpointInfo =  list.SpawnpointInfo
    name = list.Name
    wait = 40
    
    --- extract extra SpawnPoints info from map file and add to spawnPointTable --- 
    local next = next
	if next(homeSpawnPointTable) == nil or #homeSpawnPointTable == 0 then
        for key,value in pairs(objects) do
            if string.match(value.N, "SpawnPoint") then
                tm.os.Log("Found a SpawnPoint object")
                local tempName = string.gsub(value.I.CustomTexture, ".Custom Models.SpawnPoint_", "")
                tempName = tempName:gsub(".png", "")
                if tempName:match("ID_") then
                    tm.os.Log("ID Name: "..tempName)
                    local plrSPID = tempName:sub(-1) -- get last character of string to be used as spawnpoint player ID
                    local finalName = tempName:gsub("ID_", "")
                    homeSpawnPointTable[plrSPID] = {
                        pos = tableToVector(value.P),
                        rot = tableToVector(value.R),
                    }
                    tm.os.Log("plrSPID: "..plrSPID)
                else
					tm.os.Log("Name: "..tempName)
					local tempID = tonumber(tempName:sub(1, 2)) -- get 1st and 2nd characters only - eg "02"
					local fullName = tempName
					tm.os.Log("Name: "..tempName)
					if tempID ~= nil then
						tempID = tempID + 1 -- make sure the Home spawnpoint is always 1st in the list
						fullName = fullName:sub(4) -- exclude the ordering number (first 3 characters) - eg "02_Main Station Platform 1 & 2 N" --> "Main Station Platform 1 & 2 N"
						SP_ID = tempID
					else
						SP_ID = SP_ID + 100
					end
					tm.os.Log("SP_ID: "..SP_ID)
					tm.os.Log("Name: "..fullName)
                    spawnPointTable[SP_ID] = {
                        name = fullName,
                        tex = value.I.CustomTexture,
                        pos = tableToVector(value.P),
                        rot = tableToVector(value.R),
                        id = SP_ID,
                    }
                end
            end
        end
    else
        tm.os.Log("spawnPointTable already built - skipping")
    end

    if NB_ID == 0 then -- proceed if the NameBoxes haven't already been loaded
        for key,value in pairs(objects) do
            if string.match(value.N, "NameBox") then
                tm.os.Log("Found a NameBox object")
                local tempName = string.gsub(value.I.CustomTexture, ".Custom Models.NameBox_", "")
                tempName = string.gsub(tempName, ".png", "")
                tm.os.Log("NameBox Name: "..tempName)
                NB_ID = NB_ID + 1
                local fName = tostring(NB_ID).."enter"
                local fNameExit = tostring(NB_ID).."exit"
                local TBpos = tableToVector(value.P)
                TBpos.y = TBpos.y + levelHeight
                local TBobject = tm.physics.SpawnBoxTrigger(TBpos, tableToVector(value.S))
                TBobject.SetIsVisible(false)
                TBobject.GetTransform().SetRotation(tableToVector(value.R))
                tm.physics.RegisterFunctionToCollisionEnterCallback(TBobject, fName)
                tm.physics.RegisterFunctionToCollisionExitCallback(TBobject, fNameExit)
                
                _G[fName] = function(playerId)
					if tm.players.GetPlayerTransform(playerId) ~= nil then
						local playerData = playerDataTable[playerId]
						if playerData ~= nil then
							if playerData.fastTraveled == false then
								playerData.atArea = tempName
								tm.playerUI.ShowIntrusiveMessageForPlayer(playerId, tempName, nil, 3)
							else -- account for TM double triggering bug
								if playerData.atArea ~= tempName and playerData.nBoxCount == 0 then
									playerData.atArea = tempName
									tm.playerUI.ShowIntrusiveMessageForPlayer(playerId, tempName, nil, 3)
									playerData.nBoxCount = playerData.nBoxCount + 1
								else
									playerData.nBoxCount = playerData.nBoxCount - 1
								end
							end
							tm.os.Log("player Fast Traveled: "..tostring(playerData.fastTraveled))
						end
					end
                end
                
                _G[fNameExit] = function(playerId)
                    local playerData = playerDataTable[playerId]
                    if not playerData.fastTraveled then
                        playerData.atArea = ""
                        playerData.nBoxCount = 0
                        playerData.ftTimestamp = 99999999
                    elseif playerData.nBoxCount == 0 then
                        playerData.atArea = ""
                        playerData.nBoxCount = 0
                        playerData.ftTimestamp = tm.os.GetTime()
                    end
                end
            end
        end
    else
       tm.os.Log("NameBox's already built - skipping")
    end

    if BB_ID == 0 then -- proceed if the builderboxes haven't already been loaded
        tm.os.Log("checking for BuilderBox objects")
        for key,value in pairs(objects) do
            if string.match(value.N, "BuilderBox") then
                tm.os.Log("Found a BuilderBox object")
                BB_ID = BB_ID + 1
                local BBpos = tableToVector(value.P)
                BBpos.y = BBpos.y + levelHeight
                local BBobject = tm.physics.SpawnBoxTrigger(BBpos, tableToVector(value.S))
                BBobject.SetIsVisible(false)
                BBobject.GetTransform().SetRotation(tableToVector(value.R))
                tm.physics.RegisterFunctionToCollisionEnterCallback(BBobject, "onEnterBuilderBox")
                tm.physics.RegisterFunctionToCollisionExitCallback(BBobject, "onExitBuilderBox")
            end
        end
    else
       tm.os.Log("BuilderBox's already built - skipping")
    end
	------------------------------------------------------------
end 

function update()

    if needToSpawn ~= nil and #needToSpawn ~= 0 then
        
        if message == ""  then
            if wait >= 0  then
                wait = wait - 1
                message = tm.playerUI.AddSubtleMessageForAllPlayers("Loading\n" .. name, "0%", 99999999, "icon")
                return
            end
        end

        local spawnIndex = 1
        for i=1,10 do
            if i%5==0  then
                UILoadPercent = math.ceil((1-(#needToSpawn/startAmount))*100)
                tm.playerUI.SubtleMessageUpdateMessageForAll(message, tostring(UILoadPercent).."%")
                local playerList = tm.players.CurrentPlayers()
            end

            local object = needToSpawn[spawnIndex]
            local info = nil
            local pos = nil
            local spawn
			local material = "Asphalt"
            
            if object == nil  then
                if spawnIndex == 1  then
                    needToSpawn = nil
                    return
                else
                    spawnIndex = 1
                    goto continue
                end
            end
            
            --- Bypass spawing of these objects -----
            if string.match(object.N, "SpawnPoint") or string.match(object.N, "NameBox") or string.match(object.N, "BuilderBox") then
                table.remove(needToSpawn,spawnIndex)
                goto continue
            end
            -----------------------------------------

            pos = tableToVector(object.P)
            pos.y = pos.y + levelHeight
            
            info = object.I

            if info.CustomModel and wait > 0 then
                spawnIndex = spawnIndex + 1
                goto continue
            end

            if object.I.CustomModel then
                
                if table.tableContains(customThings,object.N) == false then
                    table.insert(customThings, object.N)
                    tm.physics.AddMesh(object.N, object.N)
                    wait = 14
                    goto continue
                end
                
                if object.I.CustomTexture ~= "" then
                    if table.tableContains(customThings,object.I.CustomTexture) == false then
                        table.insert(customThings, object.I.CustomTexture)
                        tm.physics.AddTexture(object.I.CustomTexture, object.I.CustomTexture) 
                        wait = 14
                        goto continue
                    end
					
					--- extract physics materials ------------------------------
					local tempStr = object.I.CustomTexture
					_,_,tempStr = string.find(tempStr, "_([%w%s]+)_")
					if tempStr ~= nil then
						material = tempStr
					end
					------------------------------------------------------------

                    if not info.IsStatic then
                        spawn = tm.physics.SpawnCustomObjectRigidbody(pos, object.N, object.I.CustomTexture, object.I.CustomWeight == 0, object.I.CustomWeight, material)
                    elseif info.CanCollide then
                        spawn = tm.physics.SpawnCustomObjectConcave(pos, object.N, object.I.CustomTexture, material)
                    else
                        spawn = tm.physics.SpawnCustomObject(pos, object.N, object.I.CustomTexture, material)
                    end
                else
                    if not info.IsStatic then
                        spawn = tm.physics.SpawnCustomObjectRigidbody(pos, object.N, object.I.CustomTexture, object.I.CustomWeight == 0, object.I.CustomWeight, material)
                    elseif info.CanCollide then
                        spawn = tm.physics.SpawnCustomObjectConcave(pos, object.N, nil, material)
                    else
                        spawn = tm.physics.SpawnCustomObject(pos, object.N, nil, material)
                    end
                end
            else
                if string.match(object.N,"Container") or string.match(object.N,"Tire") then
                    if object.I.IsStatic then
                        spawn = tm.physics.SpawnObject(pos,object.N)
                    else
                        spawn = tm.physics.SpawnObject(pos,object.N .. "_Dynamic")
                    end
                else
                    spawn = tm.physics.SpawnObject(pos,object.N)
                end
            end

            if spawn == nil then
                goto continue
            end

            spawn.GetTransform().SetRotation(tableToVector(object.R))
            spawn.GetTransform().SetScale(tableToVector(object.S))
            if object.S.x==1 then
                spawn.GetTransform().SetScale(tm.vector3.Create(1.00001,object.S.y,object.S.z))
            end
            
            spawn.SetIsVisible(info.IsVisible)
            spawn.SetIsStatic(info.IsStatic)
            
            if not info.CanCollide then
                spawn.SetIsTrigger(true)
            end

            table.remove(needToSpawn,spawnIndex)
            
            ::continue::
        end 
        wait = wait - 1

        -------------------------------------------------------------
        local loadColor = "<color=#fd0>"
        if UILoadPercent == 100 then
            loadColor = "<color=#bfb>"
        end
        
        local playerList = tm.players.CurrentPlayers()
        for key, player in pairs(playerList) do
            tm.playerUI.SetUIValue(player.playerId, "LoadingPercentLabel", "<b>"..loadColor..tostring(UILoadPercent).."%</color></b>")
        end
        ------------------------------------------------------------
        
    elseif message ~= "" then
        ------------------------------------------------------------
        UILoadPercent = 100
        local playerList = tm.players.CurrentPlayers()
        for key, player in pairs(playerList) do
            tm.playerUI.SetUIValue(player.playerId, "LoadingPercentLabel", "<b><color=#bfb>100%</color></b>")
            tm.players.SetBuilderEnabled(player.playerId, true)
            playAudioFX(player.playerId, SFX_mapLoaded)
            UIMain(player.playerId)
            onSP1(player.playerId)
			tm.os.Log("Map finished loading - playerId: " ..tostring(player.playerId))
        end
        ------------------------------------------------------------
        
        tm.playerUI.SubtleMessageUpdateMessageForAll(message, "<color=green>100%</color>")
        tm.playerUI.RemoveSubtleMessageForAll(message)
        tm.playerUI.AddSubtleMessageForAllPlayers(name, "loaded successfully!", 5, "icon")
        message = ""
        --loadExtraTextures()
    end
    
    ------------------------------------------------------------
    local playerList = tm.players.CurrentPlayers()
    for key, player in pairs(playerList) do
        playerUpdate(player.playerId)
    end
    ------------------------------------------------------------
end

function playerUpdate(playerId)

    local playerData = playerDataTable[playerId]
    playerData.updateTick = playerData.updateTick + 1
	
	--- joined while map was loading
	if playerData.loadJoin and UILoadPercent == 100 then
		playerData.loadJoin = false
		UIMain(playerId)
		tm.os.Log("joined while map was loading - playerId: " ..tostring(playerId))
	end
	
	--- late join
	if playerData.lateJoin and playerData.getPos and UILoadPercent == 100 then
		playerData.getPos = true
		playerData.lateJoin = false
		playerData.joinStamp = tm.os.GetTime()
		UIMain(playerId)
		onSP1(playerId)
		-- do secondary join message (for late joiners)
		tm.playerUI.RemoveSubtleMessageForAll(playerData.joinMessage)
		playerData.joinMessage2 = tm.playerUI.AddSubtleMessageForAllPlayers(tm.players.GetPlayerName(playerId), onPlayerJoinMessage(playerId), 10, "icon")
		tm.os.Log("late join - playerId: " ..tostring(playerId))
	end
	
	--- can get position now
	if playerId ~= 0 and playerData.getPos == false and tm.players.GetPlayerTransform(playerId) ~= nil then
		playerData.getPos = true
		doSpawnPoints(playerId)
		tm.os.Log("can get position now - playerId: " ..tostring(playerId))
	end
        
    --- slow player updates -------------------------------------
    if playerData.updateTick >= (modDelta / slowDelta) then 
        playerData.updateTick = 0
        
        if tm.players.GetPlayerIsInBuildMode(playerId) then
            playerData.plrInBuildMode = true
        end
        
        if playerData.plrInBuildMode and not tm.players.GetPlayerIsInBuildMode(playerId) then
            playerData.plrInBuildMode = false
            playerData.refreshUI = true
        end
        
        if TZWind then
            if playerData.doWindForce then
                local WBID = playerData.windBoxID
                local direction = WBIDtable[WBID].WBdirection
                onWindForce(playerId, direction)
            end
        end
        
        if simpleWater then
            if getMap == "WLD_TestZone" then
                simpleWater(playerId)
            end
        end
		
		------------------------------------------------------------
        --- insert uiloading updates here
		------------------------------------------------------------
        
        if playerData.fastTraveled and tm.os.GetTime() - playerData.ftTimestamp > 0.5 then
            playerData.fastTraveled = false
        end
        tm.playerUI.SetUIValue(playerId, "UIlocationMsg", playerData.atArea)
    
        if playerData.refreshUI then
            if UILoadPercent == 100 then
                if playerData.inMenu == "UIPersonalSpawnPoint" then
                    UIPersonalSpawnPoint(playerId)
                else
                    UIMain(playerId)
                end
            else
                UILoading(playerId)
            end
            playerData.nBoxCount = 0
            playerData.refreshUI = false
        end
        
        
    end
    --- end of slow player updates ---------------------------------
    
	------------------------------------------------------------
    -- if playerData.doAnim then
        -- if playerData.frameCount > 35 then playerData.frameCount = 1 end
        -- loadingAni(playerId)
    -- end
	------------------------------------------------------------
end

function table.tableContains(table,value)
    for k,v in pairs(table) do
        if value==v then
            return true
        end
    end
    return false
end

function UILoading(playerId)

    tm.playerUI.ClearUI(playerId)
    tm.playerUI.AddUILabel(playerId, "LoadingMapLabel", "...loading...")
    tm.playerUI.AddUILabel(playerId, "LoadingPercentLabel", "<b>0%")
    tm.playerUI.AddUILabel(playerId, "LoadingText", "<i>loading may take some time")
    tm.playerUI.AddUILabel(playerId, "LoadingFooter", "<i>Builder disabled while loading")
end

------------------------------------------------------------
-- function loadingAni(playerId)
    
    -- tm.playerUI.SetUIValue(playerId, "LoadingAni", loadingAnimFrames[math.floor(playerDataTable[playerId].frameCount)])
    -- playerDataTable[playerId].frameCount = playerDataTable[playerId].frameCount + 0.05
-- end
------------------------------------------------------------

function onButtonUIMain(callbackData)

    local playerId = callbackData.playerId
    playAudioFX(playerId, SFX_genericButton)
    UIMain(playerId)
end

function UIMain(playerId)

    local playerData = playerDataTable[playerId]
    playerData.inMenu = "UIMain"
    tm.playerUI.ClearUI(playerId)
    -- tm.playerUI.AddUIButton(playerId, "HelpfulInfoBtn", "<b>► <b>Information Desk</b> ◄", onButtonHelp)
    if playerId == 0 then
        tm.playerUI.AddUIButton(0, "HostSettings", "<b><color=#ffb>► Host Settings ◄", onButtonUISettings)
    else
        tm.playerUI.AddUILabel(playerId, "MainMenuHdr", "═══════ <b>Options</b> ═══════")
    end
    if fastTravelEnabled then
        tm.playerUI.AddUIButton(playerId, "FastTravelBtn", "<b>► Fast Travel ◄", onButtonFastTravel)
    else
        tm.playerUI.AddUIButton(playerId, "SP1", "<b>► Respawn to Home ◄", onButtonSP1)
    end
    tm.playerUI.AddUIButton(playerId, "SetPersonalSpawnPointBtn", "<b>► Set your PSP ◄", onButtonPersonalSpawnPoint)
    if playerData.spawnPoint then
        tm.playerUI.AddUIButton(playerId, "SpawnAtPSPBtn", "<b><color=#bfb>► Spawn at PSP ◄", onButtonSpawnAtPersonalSpawnPoint)
    else
        tm.playerUI.AddUILabel(playerId, "SpawnAtPSPMsg", "<b><color=#ccc>▷ Spawn at PSP ◁")
    end
    if BB_ID > 0 or NB_ID > 0 or useTabMap then
        tm.playerUI.AddUILabel(playerId, "Spacer", "──────────────────────")
    end
    if useTabMap then
        tm.playerUI.AddUILabel(playerId, "UItabMapMsg", "<i>Press Tab for map view")
    end
    if BB_ID > 0 then
        tm.playerUI.AddUILabel(playerId, "UIbuilderMsg", playerData.UIbuilderMsg)
    end
    if NB_ID > 0 then
        tm.playerUI.AddUILabel(playerId, "UIlocationMsg", "")
    end
end

function onButtonUISettings(callbackData)

    local playerId = callbackData.playerId
    playAudioFX(playerId, SFX_genericButton)
    UISettings(playerId)
end

function UISettings(playerId)
    
    local playerData = playerDataTable[playerId]
    playerData.inMenu = "UISettings"
    tm.playerUI.ClearUI(playerId)
    local mainTitle = "════ <b>HOST SETTINGS</b> ════"
    local perfTitle = "─── <b>Server Performance</b> ───"
    if tm.os.IsSingleplayer() then
        mainTitle = "════ <b>SETTINGS</b> ════"
        perfTitle = "─── <b>Game Performance</b> ───"
    end
    
    tm.playerUI.AddUIButton(playerId, "backToMain", "<b>◄ Exit ►", onButtonUIMain)
    tm.playerUI.AddUILabel(playerId, "SettingsHdr", mainTitle)
	
	local next = next
	if next(homeSpawnPointTable) or #homeSpawnPointTable then
        if fastTravelEnabled then
            tm.playerUI.AddUIButton(playerId, "ToggleFastTravel", "<size=12><b>Fast Travel "..colOn.."[ON]", onButtonToggleFastTravel)
        else 
            tm.playerUI.AddUIButton(playerId, "ToggleFastTravel", "<size=12><b>Fast Travel "..colOff.."[OFF]", onButtonToggleFastTravel)
        end
    end
	
	if SPProtectionEnabled then
		tm.playerUI.AddUIButton(playerId, "ToggleSPProtection", "<size=12><b>Spawn Point Protection "..colOn.."[ON]", onButtonToggleSPProtection)
	else 
		tm.playerUI.AddUIButton(playerId, "ToggleSPProtection", "<size=12><b>Spawn Point Protection "..colOff.."[OFF]", onButtonToggleSPProtection)
	end
	
    tm.playerUI.AddUILabel(playerId, "perfTitleHdr", perfTitle)
    tm.playerUI.AddUIButton(playerId, "RemoveExcessStructuresBtn", "<size=12><b>Remove Excess Blueprints", onButtonReduceStructures)
    tm.playerUI.AddUIButton(playerId, "RemoveALLStructuresBtn", "<size=12><b><color=#fd0>Remove ALL Blueprints!", onClearAllStructures)
    if not tm.os.IsSingleplayer() then
        tm.playerUI.AddUILabel(playerId, "TitleConnectedPlayers", "── <b>Player Build Status</b> ──")
		tm.playerUI.AddUILabel(playerId, "BuildStatusKey1", "<b><color=#bfb>●</color> = Allowed")
		tm.playerUI.AddUILabel(playerId, "BuildStatusKey2", "<b><color=#fd0>●</color> = Blocked")
		
        local playerList = tm.players.CurrentPlayers()
        if #playerList > 1 then
            for key, player in pairs(playerList) do -- create a toggle button for each connected player
                if player.playerId ~= 0 then -- exclude host
                    local playerData = playerDataTable[player.playerId]
                    local playerName = string.sub(tm.players.GetPlayerName(player.playerId), 1, 26) -- truncate end of player names longer than specified number of characters
                    local playerStatus = "<size=11><color=#bfb><b>"
                    if playerData.isBlocked then playerStatus = "<size=11><color=#fd0><b>" end
                    tm.playerUI.AddUIButton(0, tostring(player.playerId), playerStatus..playerName, onButtonTogglePlayerStatus)
                end
            end
        else
            tm.playerUI.AddUILabel(playerId, "NoConnectedPlayersLbl", "-- no connected players --")
        end
    end
    tm.playerUI.AddUILabel(playerId, "Spacer", "──────────────────────")
end

function onButtonToggleSPProtection(callbackData) -- allows host to disable/enable the use of spawnpoint protection

    local playerId = callbackData.playerId
    if SPProtectionEnabled then
        SPProtectionEnabled = false
        tm.playerUI.SetUIValue(playerId, "ToggleSPProtection", "<size=12><b>Spawn Point Protection "..colOff.."[OFF]")
        playAudioFX(playerId, SFX_deactivate)
    else
        SPProtectionEnabled = true
        tm.playerUI.SetUIValue(playerId, "ToggleSPProtection", "<size=12><b>Spawn Point Protection "..colOn.."[ON]")
        playAudioFX(playerId, SFX_activate)
    end
end

function onButtonToggleFastTravel(callbackData) -- allows host to disable/enable the use of spawnpoints

    local playerId = callbackData.playerId
    if fastTravelEnabled then
        fastTravelEnabled = false
        tm.playerUI.SetUIValue(playerId, "ToggleFastTravel", "<size=12><b>Fast Travel "..colOff.."[OFF]")
        playAudioFX(playerId, SFX_deactivate)
        local sp1spId = "sp1"
        if playerId ~= 0 then
            sp1spId = "sp1"..tostring(playerId)
        end
        tm.players.SetPlayerSpawnLocation(playerId, sp1spId)
    else
        fastTravelEnabled = true
        tm.playerUI.SetUIValue(playerId, "ToggleFastTravel", "<size=12><b>Fast Travel "..colOn.."[ON]")
        playAudioFX(playerId, SFX_activate)
    end
    local playerList = tm.players.CurrentPlayers()
    for key, player in pairs(playerList) do
        if player.playerId ~= 0 then
            if playerDataTable[player.playerId].inMenu == "UIMain" then
                UIMain(player.playerId)
            end
        end
    end
end

function onButtonFastTravel(callbackData)
    
    local playerId = callbackData.playerId
    playAudioFX(playerId, SFX_genericButton)
    UIFastTravel(playerId)
end

function UIFastTravel(playerId)
    
    local playerData = playerDataTable[playerId]
    if tm.players.GetPlayerIsInBuildMode(playerId) then
        playAudioFX(playerId, SFX_negative)
        return
    end
    playerData.inMenu = "UIFastTravel"
    tm.playerUI.ClearUI(playerId)
    tm.playerUI.AddUIButton(playerId, "backToMain", "<b>◄ Exit ►", onButtonUIMain)
    tm.playerUI.AddUILabel(playerId, "FastTravelHdr", "═════ <b>FAST TRAVEL</b> ═════")
    if fastTravelEnabled and not hardMode then
        tm.playerUI.AddUIButton(playerId, "SP1", "<b>"..homeSpawnpointName.."", onButtonSP1)
		
		for _, k in ipairs(reOrderTable(spawnPointTable)) do
			local v = spawnPointTable[k]
            if v ~= nil then
                local name = v.name
                local ID = "sp"..tostring(v.id)
                local spPos = v.pos
                local spRot = tableToVector(v.rot)
                local spRotY = spRot.y
				local spData = { spPos, spRotY }
				tm.playerUI.AddUIButton(playerId, name, "<b>"..name.."", _G[ID], spData)
            end
        end
    end
    tm.playerUI.AddUILabel(playerId, "Spacer", "──────────────────────")
end

function onButtonPersonalSpawnPoint(callbackData)
    
    UIPersonalSpawnPoint(callbackData.playerId)
end

function UIPersonalSpawnPoint(playerId)
    
    local playerData = playerDataTable[playerId]
    playAudioFX(playerId, SFX_genericButton)
    if tm.players.GetPlayerIsInBuildMode(playerId) then
        playAudioFX(playerId, SFX_negative)
        return
    end
    playerData.inMenu = "UISpawnPoint"
    tm.playerUI.ClearUI(playerId)
    tm.playerUI.AddUIButton(playerId, "backToMain", "<b>◄ Exit ►", onButtonUIMain)
    tm.playerUI.AddUILabel(playerId, "PersonalSpawnPointHdr", "<size=12>═ <b>PERSONAL SPAWN POINT</b> ═")
    tm.playerUI.AddUILabel(playerId, "PersonalSpawnPointInfo", "Here you can create your ")
    tm.playerUI.AddUILabel(playerId, "PersonalSpawnPointInfo", "personal spawn point (PSP)")
    tm.playerUI.AddUILabel(playerId, "PersonalSpawnPointInfo", "at your current location")
    tm.playerUI.AddUILabel(playerId, "Spacer", "──────────────────────")
    tm.playerUI.AddUIButton(playerId, "MakeSpawnPointBtn", "<b><color=#9ff>► Set PSP Now! ◄", onButtonCreateSpawnPoint)
    tm.playerUI.AddUILabel(playerId, "PersonalSpawnPointInfo", "<i><color=#ffb>overwrites any previous PSP</color>")
    tm.playerUI.AddUILabel(playerId, "Spacer", "──────────────────────")
end

function onButtonHelp(callbackData)
    
    local playerId = callbackData.playerId
    UIHelp(playerId)
end

function UIHelp(playerId)
    
    local playerData = playerDataTable[playerId]
    playerData.inMenu = "UIHelp"
    playAudioFX(playerId, SFX_genericButton)
    tm.playerUI.ClearUI(playerId)
    tm.playerUI.AddUIButton(playerId, "backToMain", "<b>◄ Exit ►", onButtonUIMain)
    tm.playerUI.AddUILabel(playerId, "FastTravelHdr", "══ <b>Information Desk</b> ══")
    tm.playerUI.AddUILabel(playerId, "LoadingText", "<b>Please read the map description")
    tm.playerUI.AddUILabel(playerId, "LoadingText", "<b>on the workshop for more info")
    tm.playerUI.AddUILabel(playerId, "Spacer", "──────────────────────")
end

function onButtonTogglePlayerStatus(callbackData)

    local playerId = callbackData.playerId
    local thisPlrId = tonumber(callbackData.id)
    local thisPlrData = playerDataTable[thisPlrId]
    local playerData = playerDataTable[playerId]
    local subHeader = "Your Building Status:"
    local subMessage = ""
    
    if thisPlrData.isBlocked then
        thisPlrData.isBlocked = false
        subMessage = "<color=#bfb>ALLOWED!</color>"
        if not thisPlrData.isInBuilderBox then
            tm.players.SetBuilderEnabled(thisPlrId, true)
        end
    else
        thisPlrData.isBlocked = true
        subMessage = "<color=#fd0>BLOCKED!</color>"
        tm.players.SetBuilderEnabled(thisPlrId, false)
    end
    playAudioFX(playerId, SFX_bigClick)
    local playerList = tm.players.CurrentPlayers()
    for key, player in pairs(playerList) do
        if player.playerId ~= 0 then
            if playerDataTable[player.playerId].inMenu ~= "UIMain" then
                UIMain(player.playerId)
            end
        end
    end
    UISettings(playerId)
    tm.playerUI.AddSubtleMessageForPlayer(thisPlrId, subHeader, subMessage, 4, "icon")
end

function onButtonSP1(callbackData)

    local playerId = callbackData.playerId
    onSP1(playerId)
end

function onSP1(playerId)
    
    local playerData = playerDataTable[playerId]
    if tm.players.GetPlayerIsInBuildMode(playerId) then
        playAudioFX(playerId, SFX_negative)
        return
    end
    playerData.fastTraveled = true
    playerData.nBoxCount = 0
    playerData.nBoxCount2 = 0
    local SPID = ""
    local sp1Pos = tableToVector(spawnpointInfo.P)
    sp1Pos.y = sp1Pos.y + levelHeight
    local sp1Rot = tableToVector(spawnpointInfo.R)
    if playerId ~= 0 then
        if homeSpawnPointTable[tostring(playerId)] ~= nil then
            SPID = tostring(playerId)
            sp1Pos = tableToVector(homeSpawnPointTable[SPID].pos)
			sp1Pos.y = sp1Pos.y + levelHeight
            sp1Rot = rotationToDirection(homeSpawnPointTable[SPID].rot)
			SPID = "-"..tostring(playerId)
        end
    end
    if isSpawnpointOccupied(playerId, sp1Pos, sp1Rot.y) then
        tm.playerUI.AddSubtleMessageForPlayer(playerId, "Spawn prevented!", "Spawnpoint is occupied", 5, "icon")
        return
    end
    local takeVehicle = false
    if takeBlueprintToSpawn then
        takeVehicle = true
    end
    tm.players.SetPlayerSpawnLocation(playerId, "sp1"..SPID)
    tm.players.TeleportPlayerToSpawnPoint(playerId, "sp1"..SPID, takeVehicle)
    playAudioFX(playerId, SFX_spawnWarp)
    UIMain(playerId)
    tm.playerUI.AddSubtleMessageForPlayer(playerId, homeSpawnpointName, onPlayerFastTravelMessage(playerId), 10, "icon")
end

-- function loadExtraTextures()
	
    -- --tm.physics.AddTexture(".Custom Models.TrackSwitchLeft_on.png", "TrackSwitchLeft_on")
    -- return
-- end

function onKeyBuilder(playerId)
    
    if tm.players.GetBuilderEnabled(playerId) then
        return
    else
        local playerData = playerDataTable[playerId]
        local buildTitle = "No Building Yet"
        local buildMessage = "The Builder is locked"
        if playerData.isBlocked then
            buildTitle = "No Building"
            buildMessage = "You have been blocked"
        elseif UILoadPercent == 100 then
            buildTitle = "No-Build Zone"
        end
        tm.playerUI.AddSubtleMessageForPlayer(playerId, buildTitle, buildMessage, 3, "icon")
    end
end

function playAudioFX(playerId, soundFx)
    
    local modGameObject = tm.players.GetPlayerGameObject(playerId)
    tm.audio.PlayAudioAtGameobject(soundFx, modGameObject)
end

function stringToBool(stringBool)
    
    if stringBool == nil or stringBool == "" then
        stringBool = nil
        return
    end
    if stringBool == "true" then
        stringBool = true
    elseif stringBool == "false" then
        stringBool = false
    end
    return stringBool
end

function onPlayerJoinMessage(playerId)
    
    math.randomseed(tm.os.GetTime()+playerId)
    local playerData = playerDataTable[playerId]
    local tI = #playerJoinMessage
    local msgIndex = math.random(1, tI)
    local msg = playerJoinMessage[msgIndex]
    return msg
end

function onPlayerFastTravelMessage(playerId)
    
    math.randomseed(tm.os.GetTime()+playerId)
    local playerData = playerDataTable[playerId]
    local tI = #fastTravelMessage
    local msgIndex = math.random(1, tI)
    local msg = fastTravelMessage[msgIndex]
    return msg
end

function onButtonCreateSpawnPoint(callbackData)
    
    local playerId = (callbackData.playerId)
    onCreateSpawnPoint(playerId)
end
    
function onCreateSpawnPoint(playerId)
    
    local playerData = playerDataTable[playerId]
    if tm.players.GetPlayerIsInBuildMode(playerId) then
        playAudioFX(playerId, SFX_negative)
        return
    end
    playAudioFX(playerId, SFX_bigClick)
    local playerPos = tm.players.GetPlayerTransform(playerId).GetPosition()
	playerPos.y = playerPos.y + 0.5
    local playerRot = tm.players.GetPlayerTransform(playerId).GetRotation()
    local pspRot = rotationToDirection(playerRot)
    local PSP_ID = "psp"..tostring(playerId)
    tm.players.SetSpawnPoint(playerId, PSP_ID, playerPos, pspRot)
    playerData.spawnPoint = true
    playerData.spawnPointPos = playerPos
    playerData.spawnPointRot = pspRot
    UIMain(playerId)
    tm.playerUI.AddSubtleMessageForPlayer(playerId, "Spawn Point Saved!", nil, 5, "icon")
end

function onButtonSpawnAtPersonalSpawnPoint(callbackData)
    
    onSpawnAtPersonalSpawnPoint(callbackData.playerId)
end

function onSpawnAtPersonalSpawnPoint(playerId)
    
    local playerData = playerDataTable[playerId]
    if tm.players.GetPlayerIsInBuildMode(playerId) then
        playAudioFX(playerId, SFX_negative)
        return
    end
    playerData.atArea = ""
    playerData.nBoxCount = 0
    playerData.nBoxCount2 = 0
    local playerPos = tm.players.GetPlayerTransform(playerId).GetPosition()
    local pspPos = playerData.spawnPointPos
    local pspRot = playerData.spawnPointRot
    if isSpawnpointOccupied(playerId, pspPos, pspRot.y) then
        tm.playerUI.AddSubtleMessageForPlayer(playerId, "Can't spawn", "Spawnpoint is occupied", 5, "icon")
        return
    end
    tm.players.SetPlayerSpawnLocation(playerId, tostring(spId))
    playerData.fastTraveled = true
    local PSP_ID = "psp"..tostring(playerId)
    playAudioFX(playerId, SFX_spawnWarp)
    tm.players.TeleportPlayerToSpawnPoint(playerId, PSP_ID, true)
    tm.playerUI.AddSubtleMessageForPlayer(playerId, "Spawned at PSP", nil, 10, "icon")
end

function onButtonTabMap(callbackData)
    
    onTabMap(callbackData.playerId)
end

function onTabMap(playerId)
    
    if not getMap == "WLD_TestZone" then
        return
    end
    if useTabMap then
        local playerData = playerDataTable[playerId]
        if playerData.inAerialCam1 or playerData.inAerialCam2 then
            return
        end
        if playerData.inTabMap1 then
            playerData.inTabMap1 = false
            tm.players.DeactivateCamera(playerId, 0)
        else
            playerData.inTabMap1 = true
            tm.players.SetCameraPosition(playerId, tabMapCam1Pos)
            tm.players.SetCameraRotation(playerId, tabMapCam1Rot)
            tm.players.ActivateCamera(playerId, 0)
        end
    end
end

function onAerialCam(playerId)
    
    local playerData = playerDataTable[playerId]
    if playerData.inTabMap1 or playerData.inTabMap2 then
        return
    end
    if playerData.inAerialCam1 then
        tm.playerUI.RemoveSubtleMessageForPlayer(playerId, AerialCamMessage)
        playerData.inAerialCam1 = false
        playerData.inAerialCam2 = true
        local AerialCam2Pos = tm.players.GetPlayerTransform(playerId).GetPosition()
        AerialCam2Pos.y = 950
        local AerialCam2Rot = tm.vector3.Create(0, -1, 0)
        tm.players.SetCameraPosition(playerId, AerialCam2Pos)
        tm.players.SetCameraRotation(playerId, AerialCam2Rot)
        AerialCamMessage2 = tm.playerUI.AddSubtleMessageForPlayer(playerId, "Aerial Cam View", "Player position", 5, "icon")
    elseif playerData.inAerialCam2 then
        tm.playerUI.RemoveSubtleMessageForPlayer(playerId, AerialCamMessage2)
        playerData.inAerialCam2 = false
        tm.players.DeactivateCamera(playerId, 0)
    else
        tm.playerUI.RemoveSubtleMessageForPlayer(playerId, AerialCamMessage)
        playerData.inAerialCam1 = true
        local AerialCam1Pos = tm.vector3.Create(0, 950, 0)
        local AerialCam1Rot = tm.vector3.Create(0, -1, 0)
        tm.players.SetCameraPosition(playerId, AerialCam1Pos)
        tm.players.SetCameraRotation(playerId, AerialCam1Rot)
        tm.players.ActivateCamera(playerId, 0)
        AerialCamMessage = tm.playerUI.AddSubtleMessageForPlayer(playerId, "Aerial Cam View", "Map Origin", 5, "icon")
    end
end

function onEnterBuilderBox(playerId)
    
    local playerData = playerDataTable[playerId]
    playerData.bBoxCount = playerData.bBoxCount + 1
    if buildBoxBan then
        playerData.UIbuilderMsg = "<size=12><color=#fdb><b>No-Build Zone - Builder locked"
        if tm.players.GetBuilderEnabled(playerId) then
            tm.players.SetBuilderEnabled(playerId, false)
        end
    else
        playerData.UIbuilderMsg = "<size=12><color=#bfb><b>Build Zone - Builder unlocked"
        if not tm.players.GetBuilderEnabled(playerId) then
            if not playerData.isBlocked then
                tm.players.SetBuilderEnabled(playerId, true)
            end
        end
    end
    playerData.isInBuilderBox = true
    tm.playerUI.SetUIValue(playerId, "UIbuilderMsg", playerData.UIbuilderMsg)
end

function onExitBuilderBox(playerId)
    
    local playerData = playerDataTable[playerId]
    playerData.bBoxCount = playerData.bBoxCount - 1
    if playerData.bBoxCount < 1 then
        if buildBoxBan then
            if not tm.players.GetBuilderEnabled(playerId) then           
            playerData.UIbuilderMsg = "<size=12><color=#bfb><b>Build Zone - Builder unlocked"
                if not playerData.isBlocked then
                    tm.players.SetBuilderEnabled(playerId, true)
                end
                playerData.isInBuilderBox = false
            end
        else
            if tm.players.GetBuilderEnabled(playerId) then
                playerData.UIbuilderMsg = "UIbuilderMsg", "<size=12><color=#fdb><b>No-Build Zone - Builder locked"
                tm.players.SetBuilderEnabled(playerId, false)
            end
        end
        playerData.bBoxCount = 0
        playerData.isInBuilderBox = false
    end
    tm.playerUI.SetUIValue(playerId, "UIbuilderMsg", playerData.UIbuilderMsg)
end

function reOrderTable(theTable)
	
	local tkeys = {}
	for k in pairs(theTable) do
		table.insert(tkeys, k) -- Extract keys from table
	end
	table.sort(tkeys) -- Sort keys - sorts numerically in ascending order by default
	return tkeys
end

function print(x, ...)

    local x = tostring(x)
    for _,v in ipairs({...}) do
        x = x .. " " .. tostring(v)
    end
    tm.os.Log(x)
end

tm.os.Log("KrunchLoader Version: "..modVer)
tm.players.OnPlayerJoined.add(onPlayerJoined)
------------------------------------------------------------