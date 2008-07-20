//Conman, Xera

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_panels.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_hud.lua")
AddCSLuaFile( "ose.lua" )

include( "prop_save.lua" )
include( "shared.lua" )
include( "cl_panels.lua" )

for k,v in pairs( file.Find( "../materials/onslaught/*" ) ) do
	resource.AddFile( "materials/onslaught/" .. v )
end

local NextRound = BUILDTIME + CurTime( )
TimeLeft = NextRound - CurTime( )
local discplayers = {}
local ROUND_ID = 0

local voted = 0

local Pmeta = FindMetaTable( "Player" )
local Emeta = FindMetaTable( "Entity" )

function Emeta:Dissolve()
	if ( ValidEntity( self) && !self.Dissolving ) then
		if self:GetClass() == "sent_prop" || self:GetClass() == "sent_ladder" || self:GetClass() == "sent_ammo_dispenser" || self:GetClass() == "sent_dispenser" then      
			self.SMH = 0
		end
		
		local dissolve = ents.Create( "env_entity_dissolver" )
		dissolve:SetPos( self:GetPos() )

		self:SetName( tostring( self ) )
		dissolve:SetKeyValue( "target", self:GetName() )

		dissolve:SetKeyValue( "dissolvetype", "3" )
		dissolve:Spawn()
		dissolve:Fire( "Dissolve", "", 0 )
		dissolve:Fire( "kill", "", 1 )

		dissolve:EmitSound(Sound("weapons/physcannon/energy_sing_flyby1.wav"), 500,100)
		self:Fire( "sethealth", "0", 0 )
		self.Dissolving = true
	end
end

function Pmeta:IsStuck()
		local trc = {}
		trc.start = self:LocalToWorld(self:OBBMaxs())
		trc.endpos = self:LocalToWorld(self:OBBMins())
		trc.filter = self
		trc = util.TraceLine( trc )
		if trc.Hit then
			self.NextSpawn = CurTime() + 5
			self:Kill()
			return true
		end
	return false
end

function Pmeta:GetDefaultClass()
	for k,v in pairs(Classes) do
		if v.NAME == self:GetInfo("ose_defaultclass") then
			self:SetNetworkedInt( "class", k)
			break
		end
	end
end

function GM:PlayerInitialSpawn(ply)
	ply.LastKill = 0
	ply.Buddies = {} --I'll get round to this I swear
	ply.Died = 0
	ply:SetNetworkedInt( "kills", 0)
	ply:SetNetworkedInt( "money", STARTING_MONEY )
	ply:SetNetworkedInt( "class", 1 )
	ply:SetNetworkedInt( "rank", 1 )
	timer.Simple(2,ply.GetDefaultClass, ply)
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(ply:Nick().." has finished joining the server!")
	end
	timer.Simple(1,UpdateTime,ply)
	if discplayers[ply:SteamID()] != nil then
		ply:SetNWInt("money", discplayers[ply:SteamID()].MONEY )
		local oldobj = discplayers[ply:SteamID()].OBJECT
		for k,v in pairs(ents.FindByClass("sent_prop")) do
			if v.Owner == oldobj then
				v.Owner = ply
			end
		end
		discplayers[ply:SteamID()] = nil
	end
	
	local id = string.Replace( ply:SteamID(), ":", "." )
	if !file.Exists("onslaught_profiles/"..string.lower(id)..".txt") then
		local name = string.Replace( ply:SteamID(), ":", "." )
		local t = {id = ply:SteamID(), kills = ply:GetNWInt("kills"), rank = ply:GetNWInt("rank")}
		file.Write( "onslaught_profiles/"..name..".txt", util.TableToKeyValues(t) )
	else
		print("[ONSLAUGHT EVOLVED] Found profile for "..ply:Nick())
		local name = string.Replace( ply:SteamID(), ":", "." )
		local read = util.KeyValuesToTable( file.Read( "onslaught_profiles/"..name..".txt") )
		ply:SetNetworkedInt( "kills", read.kills)
		ply:SetNetworkedInt( "rank", read.rank)
		GAMEMODE:CheckRanks(ply)
	end
	if PHASE == "BATTLE" then
		timer.Simple(0.01, ply.KillSilent, ply)
		ply.NextSpawn = CurTime() + 5
	end
end

function UpdateTime()
	----------------------------------------------------------------
	umsg.Start("updatebattletime")
		umsg.Long(BATTLETIME)
	umsg.End()
	----------------------------------------------------------------
	umsg.Start("updatebuildtime")
			umsg.Long(BUILDTIME)
	umsg.End()
	----------------------------------------------------------------
	umsg.Start("updatetime")
		umsg.Long(TimeLeft)
		umsg.String(PHASE)
	umsg.End()
end

function GM:PlayerCanPickupWeapon(ply, wep) 
	if PHASE == "BUILD" then
		return true
	end

	for k,v in pairs(WEAPON_SET[ply:GetNetworkedInt("class")]) do
		if wep:GetClass() == v then
			return true
		end
	end

	return false
end
 
function GM:PlayerSpawn(ply)
	ply:ShouldDropWeapon(false)
	ply:UnSpectate() 
	ply:SetTeam(ply:GetNWInt("rank") + 1)
	ply:RemoveAllAmmo()
	GAMEMODE:PlayerLoadout(ply) 
	
	if PHASE == "BUILD" then
		GAMEMODE:SetPlayerSpeed(ply, 350, 500)
		ply:SetMaxHealth(100)
		ply:SetHealth(100)
	else
		local speed = Classes[ply:GetNetworkedInt("class")].SPEED
		GAMEMODE:SetPlayerSpeed(ply, speed, speed)
		GAMEMODE:RestockPlayer(ply)
		local hlth = Classes[ply:GetNetworkedInt("class")].HEALTH
		ply:SetMaxHealth(hlth)
		ply:SetHealth(hlth)
	end
	local modelname = Classes[ply:GetNetworkedInt("class",1)].MODEL
	ply:SetModel( modelname )
	if ply.CusSpawn then
		ply:SetPos(ply.CusSpawn)
		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		timer.Simple(2, ply.SetCollisionGroup,ply,COLLISION_GROUP_PLAYER)
	end
end

function GM:KillWeapons()
	for k,v in pairs( ents.GetAll( ) ) do
		if v:IsWeapon( ) then
			v:Remove( )
		end
	end
end

function GM:StartBattle()
	GAMEMODE:KillWeapons()
	print("[ONSLAUGHT] Battle phase started!")
	NextRound = CurTime() + BATTLETIME
	PHASE = "BATTLE"


	for k,v in pairs( ents.GetAll( ) ) do
		if v:IsWeapon( ) then
			v:Remove( )
		elseif v:IsNPC() || v:GetClass() == "ose_mines" then
			if ValidEntity(v:GetOwner()) && MODELS[v:GetModel()] && MODELS[v:GetModel()].PLYCLASS && v:GetOwner():GetNWInt("class") == MODELS[v:GetModel()].PLYCLASS then
			else v:Remove() end
		elseif v:GetClass() == "sent_prop" || v:GetClass() == "sent_ladder" || v:GetClass() == "sent_ammo_dispenser" || v:GetClass() == "sent_dispenser" then
			timer.Simple(k*0.05, v.Prepare, v)
		elseif v:IsPlayer() then
			v.Voted = false
			v:KillSilent()
			v.NextSpawn = CurTime() + 1
			v.FullRound = true
		end
	end


	umsg.Start("StartBattle")
	umsg.End() 
	for k,v in pairs(ents.FindByName("ose_battle")) do
		v:Fire("trigger",0,3)
	end
end

function GM:CalculateLiveBonus()
	if TimeLeft > 1 then
		for k,v in pairs(player.GetAll()) do
			local bonus = (LIVE_BONUS + (DEATH_PENALTY * v.Died)) / 2
			if bonus > 0 && v.FullRound == true then
				v:SetNetworkedInt( "money",v:GetNetworkedInt( "money") + bonus) -- if the player doesn"t die in that battle round give him some money
				v:Message("+"..bonus.." [Round Live Bonus]", Color(100,255,100,255))
			end
			v.Died = 0
		end
	else
		for k,v in pairs(player.GetAll()) do
			local bonus = LIVE_BONUS + (DEATH_PENALTY * v.Died)
			if bonus > 0 && v.FullRound == true then
				v:SetNetworkedInt( "money",v:GetNetworkedInt( "money") + bonus) -- if the player doesn"t die in that battle round give him some money
 				v:SetNWInt("kills", v:GetNWInt("kills") + math.Round(math.Clamp(bonus / 100, 1, 10)))
				v:Message("+"..bonus.." [Round Live Bonus]", Color(100,255,100,255))
			end
			v.Died = 0
		end
	end
end

function GM:StartBuild()
	print("[ONSLAUGHT] Build phase started!")
	if TimeLeft > 1 then
		for k,v in pairs(ents.FindByName("ose_lose")) do
			if ValidEntity(v) then
				v:Fire("trigger")
			end
		end
		ROUND_ID = ROUND_ID - 0.5
		BATTLETIME = BATTLETIME - 60
		if BATTLETIME < MINBATTLETIME then BATTLETIME = MINBATTLETIME end
		for k,v in pairs(player.GetAll()) do
			v:Message("Took 60 seconds from battle time!")
		end
	else
		ROUND_ID = ROUND_ID + 1
		BATTLETIME = BATTLETIME + 120
		for k,v in pairs(player.GetAll()) do
			v:Message("Added 2 minutes to battle time!")
		end
		for k,v in pairs(ents.FindByName("ose_win")) do
			if ValidEntity(v) then
				v:Fire("trigger")
			end
		end
	end
	UpdateTime()
	GAMEMODE:CalculateLiveBonus()
	PHASE = "BUILD"
	NextRound = CurTime() + BUILDTIME
	voted = 0
	for k,v in pairs( ents.GetAll( ) ) do
		if v:IsWeapon( ) then
			v:Remove( )
		elseif v:IsNPC() || v:GetClass() == "ose_mines" then
			if ValidEntity(v:GetOwner()) && MODELS[v:GetModel()] && MODELS[v:GetModel()].PLYCLASS && v:GetOwner():GetNWInt("class") == MODELS[v:GetModel()].PLYCLASS then
			else v:Remove() end
		elseif v:GetClass() == "sent_prop" || v:GetClass() == "sent_ladder" || v:GetClass() == "sent_ammo_dispenser" || v:GetClass() == "sent_dispenser" then
			v.Shealth = v.Mhealth
			v:UpdateColour()
			v:Extinguish()
			v:GetPhysicsObject():EnableMotion(false)
			v:SetMoveType(MOVETYPE_VPHYSICS)
		elseif v:IsPlayer() then
			v:Kill()
			v.NextSpawn = CurTime() + 5
		end
	end
	for k,v in pairs(ents.FindByName("ose_build")) do
		if ValidEntity(v) then
			v:Fire("trigger",0,5)
		end
	end
	
	GAMEMODE:KillWeapons()
	umsg.Start("StartBuild")
	umsg.End()
end

function Class(ply,com,args)
	local newclass = tonumber(args[1])
	if !Classes[newclass] then return end
	ply:SetNetworkedInt("class", newclass )
	if PHASE == "BATTLE" && ply:Alive() then
		ply:Kill()
		ply.NextSpawn = CurTime() + SPAWN_TIME + (#player.GetAll() * 5)
		timer.Simple(2,CheckDead)
	else
		ply:ChatPrint("You will spawn as "..Classes[newclass].NAME.." in the battle phase")
		for k,v in pairs( ents.GetAll( ) ) do
			if v:IsNPC() || v:GetClass() == "ose_mines" then
				local owner
	
				if ValidEntity(v.Owner) then owner = v.Owner elseif ValidEntity(v:GetOwner()) then owner = v:GetOwner() end
	
				if owner && owner == ply then
					if MODELS[v:GetModel()] && MODELS[v:GetModel()].PLYCLASS && v:GetOwner():GetNWInt("class") == MODELS[v:GetModel()].PLYCLASS then
					elseif MODELS[v:GetModel()] && MODELS[v:GetModel()].COST && !v.Dissolving then
						owner:SetNetworkedInt("money", owner:GetNetworkedInt("money") + MODELS[v:GetModel()].COST)
						owner:Message("+"..math.Round(MODELS[v:GetModel()].COST).." [Deleted Item]", Color(100,255,100,255))
						v:Remove()
					elseif v.SMH && v.SMH > 0 then
						owner:SetNetworkedInt("money", owner:GetNetworkedInt("money") + v.SMH)
						owner:Message("+"..math.Round(v.SMH).." [Deleted Item]", Color(100,255,100,255))
						v:Remove()
					end
				end
			end
		end
	end
end

concommand.Add("join_class", Class)

function isnumber( var )
	if var == nil then
		return false
	end
	if type( var ) == "string" then
		return tostring( tonumber( var ) ) == var
	elseif type( var ) == "number" then
		return true
	end
	return false
end

function AdminMenu(ply,com,args)
	if not ply:IsAdmin( ) then return false end
	
	local plys = player.GetAll()
	
	if args[ 1 ] == "1" then
		GAMEMODE:StartBattle()
		for k,v in pairs(plys) do
			v:ChatPrint("Admin: " .. ply:Nick() .. " skipped to battle mode!")
		end
	elseif args[ 1 ] == "2" then
		GAMEMODE:StartBuild()
		for k,v in pairs(plys) do
			v:ChatPrint("Admin: " .. ply:Nick() .. " skipped to build mode!")
		end
	elseif args[ 1 ] == "3" then
		if not isnumber( args[ 2 ] ) then
			ply:ChatPrint( "Must enter a number." )
			return
		end
		MAX_NPCS = tonumber( args[ 2 ] )
		for k,v in pairs(plys) do
			v:ChatPrint("Admin: " .. ply:Nick() .. " changed the maximum NPCs to " .. tonumber( args[ 2 ] ))
		end
	elseif args[ 1 ] == "4" then
		if not isnumber( args[ 2 ] ) then
			ply:ChatPrint( "Must enter a number." )
			return
		end
		BUILDTIME = tonumber( args[ 2 ] )
		for k,v in pairs(plys) do
			v:ChatPrint("Admin: " .. ply:Nick() .. " changed build time to " .. string.ToMinutesSeconds(tonumber(args[ 2 ])))
		end
		UpdateTime()
		umsg.Start("updatebuildtime")
			umsg.Long(BUILDTIME)
		umsg.End()
	elseif args[ 1 ] == "5" then
		if not isnumber( args[ 2 ] ) then
			ply:ChatPrint( "Must enter a number." )
			return
		end
		BATTLETIME = tonumber( args[ 2 ] )
		for k,v in pairs(plys) do
			v:ChatPrint("Admin: " .. ply:Nick() .. " changed battle time to " .. string.ToMinutesSeconds(tonumber(args[ 2 ])))
		end
		UpdateTime()
		umsg.Start("updatebattletime")
			umsg.Long(BATTLETIME)
		umsg.End()
		elseif args[ 1 ] == "6" then
		if not isnumber( args[ 2 ] ) then
			ply:ChatPrint( "Must enter a number." )
			return
		end
		SPAWN_TIME = tonumber( args[ 2 ] )
		for k,v in pairs(plys) do
			v:ChatPrint("Admin: " .. ply:Nick() .. " changed spawn time to " .. string.ToMinutesSeconds(tonumber(args[ 2 ])))
		end
		
	elseif args[ 1 ] == "select" then
		ply:Give( "swep_select" )
	elseif args[ 1 ] == "owner" then
		if isnumber( args[ 2 ] ) then
			for k,v in pairs( GAMEMODE.SaveProps ) do
				v.Owner = player.GetByID( tonumber( args[ 2 ] ) )
			end
		else
			ply:ChatPrint( "Must enter a number." )
		end
		GAMEMODE:DeselectAll( )
	elseif args[ 1 ] == "getfiles" then
		if not file.Exists( "onslaught_saves" ) then
			file.CreateDir( "onslaught_saves" )
		end
		local read = file.Find( "onslaught_saves/*.txt" )
		umsg.Start( "RecvLoadfiles", ply )
			umsg.Short( #read )
			for k,v in pairs( read ) do
				umsg.String( v )
			end
		umsg.End( )
	elseif args[1] == "map" then
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("Admin: "..ply:Nick().." changed map to ".. args[2])
			GAMEMODE:SaveAllProfiles()
			GAMEMODE:ChangeMap(args[2])
		end
	end
	
end

concommand.Add( "admin", AdminMenu )

function GM:PlayerSay( ply, txt, pub )
	if string.sub(txt,1,5) == "!help" then
		ply:ChatPrint("Available chat commands are: !give !agive !voteskip !spawn !resetspawn, !stuck")
	end
	if string.sub(txt,1,5) == "!give" then
		local args = string.Explode(" ", txt)
		if #args != 3 || tonumber(args[3]) <= 0 then
			ply:ChatPrint("Wrong Syntax! Type !give <partial player name> <amount to give>")
			return ""
		end
		if ply:GetNetworkedInt("money") <= tonumber(args[3]) then
			ply:ChatPrint("You do not have enough money to give that amount!")
			return ""
		end
		for k,v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()),string.lower(args[2])) then
				v:SetNetworkedInt("money", v:GetNetworkedInt("money") + tonumber(args[3]))
				ply:SetNetworkedInt("money", ply:GetNetworkedInt("money") - tonumber(args[3]))
				v:ChatPrint(ply:Nick().." gave you "..args[3].." money!")
				ply:ChatPrint("You succesfully gave "..v:Nick().." "..args[3].." money.")
				return txt
			end
		end
		ply:ChatPrint("Could not find the requested player!")
		return ""
	end
	if string.sub(txt,1,6) == "!agive" then
		if !ply:IsAdmin() then ply:ChatPrint("You need to be an admin to use this command!") return "" end
		local args = string.Explode(" ", txt)
		if #args != 3 || tonumber(args[3]) <= 0 then
			ply:ChatPrint("Wrong Syntax! Type !give <partial player name> <amount to give>")
			return ""
		end
		for k,v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()),string.lower(args[2])) then
				v:SetNetworkedInt("money", v:GetNetworkedInt("money") + tonumber(args[3]))
				v:ChatPrint("Admin: "..ply:Nick().." gave you "..args[3].." money!")
				ply:ChatPrint("You succesfully gave "..v:Nick().." "..args[3].." money.")
				return txt
			end
		end
		ply:ChatPrint("Could not find the requested player!")
		return ""
	end
	if string.sub(txt,1,6) == "!stuck" then
		Stuck(ply)
	end
	if string.sub(txt,1,6) == "!spawn" then
		SpawnPoint(ply)
	end
	if string.sub(txt,1,11) == "!resetspawn" then
		ResetSpawn(ply)
	end
	if string.sub(txt,1,8) == "!sellall" then
		SellAll(ply)
	end
	if string.sub(txt,1,9) == "!voteskip" then
		VoteSkip(ply)
	end
	return txt
end

function Stuck(ply,cmd,args)
	if !ply:IsStuck() then
		ply:Message("You are not stuck!")
	end
end

concommand.Add("stuck", Stuck)

function SpawnPoint(ply,cmd,args)
	if ply:GetRank() < 3 then
		ply:ChatPrint("You must be a corporal or above to use this command!")
		return
	end
	if PHASE == "BUILD" then
		if not ply:IsInWorld( ) || ply:GetMoveType() == MOVETYPE_NOCLIP then
			ply:Message("You can't make your spawnpoint here!", Color(255,100,100,255))
			return
		else
			local trc = {}
			trc.start = ply:GetPos() + Vector(0,0,5)
			trc.endpos = ply:GetPos() + ply:GetUp() * -500
			trc.filter = ply
			trc = util.TraceLine( trc ) --check if the player is standing above skybox (under the map) or a nodraw
			if trc.HitSky || trc.HitNoDraw || trc.Entity.Base == "sent_prop" || trc.Entity:GetClass() == "sent_prop" || ply:Crouching( ) then
				ply:Message("You can't make your spawnpoint here!", Color(255,100,100,255))
				return
			end
			ply.CusSpawn = ply:GetPos()
			ply:Message("Set custom spawn!")
			ply:Message("Say !resetspawn to reset your spawnpoint")
		end
	else
		ply:Message("Can't set spawn in battle phase", Color(255,100,100,255))
	end
end

concommand.Add("spawnpoint", SpawnPoint)

function ResetSpawn(ply,cmd,args)
	ply.CusSpawn = nil
	ply:Message("Reset spawnpoint!")
end

concommand.Add("resetspawn", ResetSpawn)

function SellAll(ply,cmd,args)
	if PHASE == "BATTLE" then
		ply:Message("Can't sell all in battle mode!", Color(255,100,100,255))
		return
	end
	local mon = 0
	for k,v in pairs(ents.GetAll()) do
		local owner
		if ValidEntity(v.Owner) then owner = v.Owner elseif ValidEntity(v:GetOwner()) then owner = v:GetOwner() end
		
		if owner && owner == ply then
			if MODELS[v:GetModel()] && MODELS[v:GetModel()].COST && !v.Dissolving then
				mon = mon + MODELS[v:GetModel()].COST
				v:Dissolve()
			elseif v.SMH && v.SMH > 0 then
				mon = mon + v.SMH
				v:Dissolve()
			end
		end
	end
	if(mon > 0) then
	ply:SetNWInt("money", ply:GetNWInt("money") + mon)
	ply:Message("+"..math.Round(mon).." [Sold all props]", Color(100,255,100,255))
	end
end

concommand.Add("sellall", SellAll)

function VoteSkip(ply,cmd,args)
	if PHASE == "BATTLE" then
		ply:ChatPrint("You cannot skip battle phase")
		return ""
	else
		if ply.Voted == true then
			ply:ChatPrint("You have already voted!")
			return ""
		end
		ply.Voted = true
		voted = voted + 1
		local numplayer = #player.GetAll()
		local req = math.ceil(numplayer / 1.5)
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint(ply:Nick().." voted to skip build mode!"..voted.."/"..req.." votes.")
		end
		if voted >= req then
			for k,v in pairs(player.GetAll()) do
				v:ChatPrint("Starting Build Phase in 5 seconds!")
			end
			timer.Simple(5,GAMEMODE.StartBattle,GAMEMODE)
			return txt
		end
	end
end

concommand.Add("voteskip", VoteSkip)

function GM:PlayerLoadout(ply)
	if PHASE == "BATTLE" then
		for k,v in pairs(WEAPON_SET[ply:GetNetworkedInt("class")]) do
			ply:Give(v)
		end
	elseif PHASE == "BUILD" then
		ply:Give("weapon_physgun")
		ply:Give( "swep_nocollide" )
		--ply:Give("swep_dispensermaker")
	end
end

local read = file.Find("../maps/ose_*.bsp")

local mapvotes = {}

function SendMaps(ply,cmd,args)
	umsg.Start( "sendmaps", ply )
		umsg.Short( #read )
		for k,v in pairs( read ) do
			umsg.String( v )
		end
	umsg.End( )
end

concommand.Add("getmaps", SendMaps)

local voting = false
local votingenabled = false

function Votemap(ply,cmd,args)
	if ply.mapvoted then
		ply:ChatPrint("You have already voted!")
		return
	end
	if !args[1] then return end
	if !votingenabled then
		ply:ChatPrint("You must wait "..string.ToMinutesSeconds(tostring(VOTE_ENABLE_TIME - CurTime())).." until you can vote.")
		return
	end
	if string.sub(args[1],1, -5 ) != game.GetMap() && !voting && PHASE != "BATTLE" then
		GAMEMODE:StartMapVote(ply)
	elseif string.sub(args[1],1, -5 ) == game.GetMap() && voting == false then
		ply:ChatPrint("You can't start a vote for the current map!")
		return
	elseif PHASE == "BATTLE" then
		ply:ChatPrint("You can't start a vote in battle phase!")
		return
	end
	ply.mapvoted = true
	mapvotes[args[1]] = mapvotes[args[1]] + 1
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(ply:Nick().." voted for map "..args[1]..". "..mapvotes[args[1]].." votes!")
	end
end

concommand.Add("votemap", Votemap)

function SaveProfile(ply,cmd,args)
	ply:ChatPrint("Your kill profile has been saved!")
	local name = string.Replace( ply:SteamID(), ":", "." )
	local t = {id = ply:SteamID(), kills = ply:GetNWInt("kills"), rank = ply:GetNWInt("rank")}
	file.Write( "onslaught_profiles/"..name..".txt", util.TableToKeyValues(t) )
end

concommand.Add("saveprof", SaveProfile)

function GM:StartMapVote(ply)
	for k,v in pairs(read) do
		mapvotes[v] = 0
	end
	voting = true
	for k,v in pairs(player.GetAll()) do
			if v != ply then
				v:ChatPrint(ply:Nick().." has started a map vote! You have "..VOTE_TIME.." to cast your vote!")
				v:ConCommand("openmap")
				v:ChatPrint("Don't want to change? Vote for the current map: "..game.GetMap())
			end
	end
	timer.Simple(VOTE_TIME, GAMEMODE.EndVote,GAMEMODE)
end

function GM:EndVote()
	local map = ""
	local lastgreat = 0
	for k,v in pairs(mapvotes) do
		if v > lastgreat || (v >= lastgreat && string.sub(k,1, -5 ) == game.GetMap()) then
			map = k
			lastgreat = v
		end
	end
	if game.GetMap() == string.sub(map,1, -5 ) then
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("The current map has won the vote!")
			voting = false
			v.mapvoted = false
			v:ChatPrint("Map voting is now disabled!")
		end
		VOTE_ENABLE_TIME = CurTime() + VOTE_ENABLE_TIME
		return
	end
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("The map: "..string.sub(map,1, -5 ).." has won the vote!")
		v:ChatPrint("Starting the winning map in 5 seconds!")
	end
	GAMEMODE:SaveAllProfiles()
	timer.Simple(5, GAMEMODE.ChangeMap, GAMEMODE, string.sub(map,1, -5 ))
end

function GM:ChangeMap(map)
	game.ConsoleCommand("changelevel "..map.."\n")
end

function GM:ScaleNPCDamage(npc,hit,dmg)
	if npc:GetClass() == "npc_turret_floor" then return end
	if dmg:GetInflictor():GetClass() == "crossbow_bolt" then
		return dmg
	elseif dmg:GetInflictor():GetClass() == "npc_turret_floor" then
		dmg:SetDamage(6)
	end
		
	if dmg:GetInflictor():IsPlayer() then
		local wep = dmg:GetInflictor():GetActiveWeapon():GetClass()
		if wep == "weapon_shotgun" then -- the shotgun was pretty pathetic otherwise
			dmg:SetDamage(9)
		elseif wep == "weapon_ar2" then
			dmg:SetDamage(11 * 1.4)
		elseif wep == "weapon_357" then
			dmg:SetDamage(50)
		elseif wep == "weapon_smg1" then
			dmg:SetDamage(12)
		elseif wep == "weapon_pistol" then
			dmg:SetDamage(12)
		elseif wep == "weapon_crowbar" then
			dmg:SetDamage(25)
		elseif wep == "swep_scatter" then
			dmg:SetDamage(10)
		end
	end
	
	if hit == 1 then
		dmg:ScaleDamage(2)
	end

	local plycount = math.sqrt(#player.GetAll())
	dmg:ScaleDamage(1 / plycount)
	if dmg:GetDamage() < 1 then
		dmg:SetDamage(1)
	end
	return dmg
end


function GM:Initialize()
	if not file.Exists( "onslaught_profiles" ) then
		file.CreateDir( "onslaught_profiles" )
	end
	game.ConsoleCommand("mp_falldamage 1\n") -- we could do this in the scaleplayerdamage but I think the engines function works best
	self.SaveProps = { }
	GAMEMODE:StartBuild()
	
	if SinglePlayer() then
		MAX_NPCS = S_MAX_NPCS -- If it isnt a server raise the NPC limit since you shouldn't have to worry about lag :)
	end
end

function CheckDead()
	for k,v in pairs(player.GetAll()) do
		if v:Alive() then return end
	end
	GAMEMODE:StartBuild()
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("All players have perished loading build mode!")
	end
end

function GM:CheckRanks(ply,join)
	local kills = ply:GetNWInt("kills")
	local rank = ply:GetNWInt("rank")
	local newrank = rank
	for k,v in pairs(RANKS) do
		if kills >= v.KILLS then
			newrank = k
		end
	end
	if newrank > rank then
		ply:SetNWInt("rank", newrank)
		ply:SetTeam(newrank+1)
		if !join then
			ply:ChatPrint("You are now a "..RANKS[ply:GetNWInt("rank")].NAME.." rank!")
			GAMEMODE:SaveAllProfiles()
		end
	end
end

function GM:PlayerDeath( ply, wep, killer )
	--GAMEMODE:CheckRanks(ply,false)
	ply:SetTeam(1)
	ply:ConCommand("stopsounds")
	ply:Spectate(OBS_MODE_DEATHCAM)
	ply.specid = 1
	ply.Specatemode = OBS_MODE_CHASE
	local name = npcs[killer:GetClass()] or killer:GetClass()
	
	for k,v in pairs(ents.FindByClass("npc_turret_floor")) do
		if v:GetOwner() == ply then v:Remove() end
	end
	for k,v in pairs(ents.FindByClass("sent_dispenser")) do
		if v.Owner == ply && v.Type == "BATTLE" then v:Remove() end
	end
	
	if PHASE == "BUILD" then
		ply.NextSpawn = CurTime() + 1
		return true
	end
 
	if ply != killer then
		for k,v in pairs(player.GetAll()) do
			v:Message(ply:Nick().." was killed by a " .. name, Color(255,100,100,255), true)
		end
	end
	
	ply.NextSpawn = CurTime() + SPAWN_TIME + (#player.GetAll() * 10)
	ply:CreateRagdoll( )
	ply.Died = ply.Died + 1
	timer.Simple(2,CheckDead)
	ply:AddDeaths(1)	
	return true
end

--function GM:CanPlayerSuicide ( ply )
--ply:PrintMessage(HUD_PRINTTALK, "You can't suicide!")
--return false
--end 

function GM:PlayerDeathThink( ply )
	if ply.NextSpawn == nil then
		ply.NextSpawn = CurTime() + SPAWN_TIME + (#player.GetAll() * 10)
	end
	if ply.NextSpawn > CurTime( ) then
		local players = player.GetAll()
		if ply:KeyReleased( IN_ATTACK ) then
			ply.specid = ply.specid + 1
			if ply.specid > #players then
				ply.specid = 1
			end
			if players[ply.specid] == ply || !players[ply.specid]:Alive() then
				return
			end
			ply:SetPos(players[ply.specid]:GetPos())
			ply:UnSpectate()
			ply:Spectate(ply.Specatemode)
			ply:Message("You are now spectating "..players[ply.specid]:Nick())
			ply:SpectateEntity( players[ply.specid] )
		end
		if ply:KeyReleased( IN_ATTACK2 ) then
			ply.specid = ply.specid - 1
			if ply.specid <= 0 then
				ply.specid = #players
			end
			ply:SetPos(players[ply.specid]:GetPos())
			ply:UnSpectate()
			ply:Spectate(ply.Specatemode)
			ply:SpectateEntity( players[ply.specid] )
		end
		if ply:KeyReleased( IN_JUMP ) then
			if ply.Specatemode == OBS_MODE_CHASE then
				ply.Specatemode = OBS_MODE_IN_EYE
			else
				ply.Specatemode = OBS_MODE_CHASE
			end
			ply:Spectate(ply.Specatemode)
			ply:SpectateEntity( players[ply.specid] )
		end
		ply:PrintMessage( HUD_PRINTCENTER, "You will respawn in " .. math.Round( ply.NextSpawn - CurTime( ) ) )
		return
	end
	ply:Spawn( )
end

function GM:PlayerShouldTakeDamage( ply, attacker )
	if PHASE == "BATTLE" then
		if attacker:GetClass() == "worldspawn" then
			if ply:GetClass().NAME == "Scout" then
				ply:SetHealth(ply:Health() - 10)
				return false
			end
		end
	else
		if attacker:GetClass() == "worldspawn" then
			return false
		end
	end
	
	if attacker:IsPlayer() then 
	return false
	elseif ValidEntity(attacker:GetOwner()) then
		if attacker:GetOwner():IsPlayer() then
			return false
		end
	end
		if !attacker:IsNPC() && !attacker:GetClass() == "trigger_hurt" then return false end
	return true
end

function GM:ScalePlayerDamage(ply, hitgrp, dmg)
	if dmg:IsExplosionDamage() || dmg:GetAttacker():GetClass() == "weapon_shotgun" then
		dmg:ScaleDamage(0.4)
	elseif table.HasValue(Zombies, dmg:GetAttacker():GetClass()) then
		dmg:ScaleDamage(10)
	elseif dmg:GetAttacker():GetClass() == "npc_manhack" then
		dmg:ScaleDamage(2)
	end
	return dmg
end

function GM:PlayerNoClip(ply)
	if ply:IsAdmin() then return true end
	if PHASE == "BATTLE" then return false end
	if PHASE == "BUILD" then
		if BUILD_NOCLIP then
			if ply:GetRank() >= 2 then
				return true
			else
				ply:Message("You need to be private or above to have noclip in build!")
				return false
			end
		end
	end
end

function NoClipThink()
	if PHASE == "BATTLE" then return end
	for k,v in pairs(player.GetAll()) do
		if !v:IsInWorld() && v:Alive() then
			v:SetPos(v:GetPos() + (v:GetVelocity() * -0.1))
			v:SetVelocity(Vector(0,0,0))
			if !v:IsInWorld() then
				v:Kill()
				v:Message("Spy sappin' mah noclip protection", Color(255,100,100,255))
			end
		end
	end
end

hook.Add("Think", "NoClipThink", NoClipThink)

function GM:SaveAllProfiles()
	for k,ply in pairs(player.GetAll()) do
		local id = string.Replace( ply:SteamID(), ":", "." )
		if file.Exists("onslaught_profiles/"..string.lower(id)..".txt") then
			print("[ONSLAUGHT] Writing player kill profile.")
			local name = string.Replace( ply:SteamID(), ":", "." )
			local t = {id = ply:SteamID(), kills = ply:GetNWInt("kills"), rank = ply:GetNWInt("rank")}
			file.Write( "onslaught_profiles/"..name..".txt", util.TableToKeyValues(t) )
		end
	end
end

function GM:ShutDown( )
	GAMEMODE:SaveAllProfiles()
end

function GM:PlayerDisconnected( ply )
	for k,v in pairs(ents.FindByClass("npc_turret_floor")) do
		if v:GetOwner() == ply then v:Remove() end
	end
	for k,v in pairs(ents.FindByClass("sent_dispenser")) do
			if v.Owner == ply then v:Remove() end
	end
	discplayers[ply:SteamID()] = {MONEY = ply:GetNWInt("money"), OBJECT = ply}
	if PROP_CLEANUP then
		timer.Simple(PROP_DELETE_TIME, GAMEMODE.DeleteProps, GAMEMODE, ply, ply:SteamID(), ply:Nick())
		for k,v in pairs(player.GetAll()) do
			v:Message("Removing "..ply:Nick().."'s props in "..PROP_DELETE_TIME.." seconds!")
		end
	end
	local id = string.Replace( ply:SteamID(), ":", "." )
	if file.Exists("onslaught_profiles/"..string.lower(id)..".txt") then
		print("[ONSLAUGHT] Writing player kill profile.")
		local t = {id = ply:SteamID(), kills = ply:GetNWInt("kills"), rank = ply:GetNWInt("rank")}
		file.Write( "onslaught_profiles/"..id..".txt", util.TableToKeyValues(t) )
	end
	timer.Simple(2,CheckDead)
end

function GM:DeleteProps(ply, ID, nick)
	if !ID then return end
	for k,v in pairs(player.GetAll()) do
		if v:SteamID() == ID then
			v:Message(nick.."'s prop will not be deleted", Color(100,255,100,255))
			return
		end
	end
	print("[ONSLAUGHT] Deleting props")
	for k,v in pairs(ents.FindByClass("sent_*")) do
		if v:GetClass() != "sent_spawner" then
			if v.Owner == ply then
				v:Remove()
			elseif !ValidEntity(v.Owner) then
				v:Remove()
			end
		end
	end
	for k,v in pairs(discplayers) do
		if k == ID then discplayers[k] = nil end
	end
end

function GM:GravGunOnPickedUp( ply,ent )
	if ent:GetClass() == "sent_turret_controller" then 
		ent:GetPhysicsObject():EnableMotion(true)
		if ValidEntity(ent.Turret) then
			ent.Turret:GetPhysicsObject():EnableMotion(true)
		end
	end
end

function GM:GravGunOnDropped( ply, ent )
	return false
end

--ANTI LAG SYSTEM-- This function modifies the amount of NPCs in the game to try and compensate server lag,
--NOTE: NOT A PING KICKER.

function GM:AntiLag( )
	if !ANTILAG then return end
	if SinglePlayer( ) then
		return
	end
	
	if PHASE == "BUILD" then
		return
	end
	
	local avg = 0
	local c = #player.GetAll( )
	for k,v in pairs( player.GetAll( ) ) do
		avg = avg + v:Ping( )
	end
	avg = avg / c
	
	if avg > 500 then
		for k,v in pairs( ents.FindByClass( "npc_*" ) ) do
			if v:GetClass( ) != "npc_turret_floor" then
				local mindist = 1000
				for _, pl in pairs( player.GetAll( ) ) do
					if v:GetPos( ):Distance( pl:GetPos( ) ) < mindist then
						mindist = v:GetPos( ):Distance( pl:GetPos( ) )
					end
				end
				if mindist == 1000 then
					v:Remove( )
				end
			end
		end
	end
end

function GM:GravGunPunt( ply, ent )
	if !ent:GetClass() == "npc_manhack" then return false end
	return true
end

function GM:PhysgunPickup(ply, ent)
	if ent:GetClass() != "sent_prop" && ent:GetClass() != "sent_ladder" && ent:GetClass() != "sent_ammo_dispenser" then
		return false
	elseif ValidEntity( ent.Owner ) and ent.Owner != ply && !ply:IsAdmin() then
		ply:PrintMessage( HUD_PRINTCENTER, "This item is owned by " .. ent.Owner:Nick() )
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return false
	else
		return true
	end
end

function GM:PhysgunDrop(ply, ent)
	ent:GetPhysicsObject():EnableMotion(false)
end

function GM:OnPhysgunFreeze(weapon, physobj, ent, ply)
	if ent:GetClass() != "sent_prop" && ent:GetClass() != "sent_ladder" && ent:GetClass() != "sent_ammo_dispenser" then
		return false
	elseif ValidEntity( ent.Owner ) and ent.Owner != ply && !ply:IsAdmin() then
		ply:PrintMessage( HUD_PRINTCENTER, "This item is owned by " .. ent.Owner:Nick() )
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
	return false
	elseif ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent:SetColor(255,255,255,128)
	else
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	ent:SetColor(255,255,255,255)
	end
	return false
end

function GM:OnPhysgunReload( wep, ply ) -- TODO: BUDDY SYSTEM
	
	local trace = {}
	trace.start = ply:GetShootPos()
	trace.endpos = trace.start + (ply:GetAimVector() * 1000)
	trace.filter = ply
	local trc = util.TraceLine(trace)
	
	if !trc.Entity then return false end
	if !trc.Entity:IsValid( ) then return false end
	if trc.Entity:GetClass() != "sent_prop" && trc.Entity:GetClass() != "sent_ladder" && trc.Entity:GetClass() != "sent_ammo_dispenser" && trc.Entity:GetClass() != "sent_dispenser" && trc.Entity:GetClass() != "ose_mines" && trc.Entity:GetClass() != "npc_floor_turret" && trc.Entity:GetClass() != "sent_turretcontroller"  then return false end
	
	local ent = trc.Entity
	
	if ent.Turret then ent = ent.Turret end 
	
	local owner
	
	if ValidEntity(ent.Owner) then owner = ent.Owner elseif ValidEntity(ent:GetOwner()) then owner = ent:GetOwner() end
	

	if owner then
		if owner != ply and !ply:IsAdmin() then
			ply:PrintMessage(HUD_PRINTCENTER, "This item is owned by " .. owner:Nick( ))
			ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
			return false
		elseif MODELS[ent:GetModel()] && MODELS[ent:GetModel()].COST && !ent.Dissolving then
			owner:SetNetworkedInt("money", owner:GetNetworkedInt("money") + MODELS[ent:GetModel()].COST)
			owner:Message("+"..math.Round(MODELS[ent:GetModel()].COST).." [Deleted Item]", Color(100,255,100,255))
		elseif ent.SMH && ent.SMH > 0 then
			owner:SetNetworkedInt("money", owner:GetNetworkedInt("money") + ent.SMH)
			owner:Message("+"..math.Round(ent.SMH).." [Deleted Item]", Color(100,255,100,255))
		end
	end
	
	ent:Dissolve()
	return false
end

function GM:Think()
	self.OldAntiLagTime = self.OldAntiLagTime or CurTime( )
	if CurTime( ) - self.OldAntiLagTime >= 5 then
		self:AntiLag( )
	end
	TimeLeft = NextRound - CurTime()
	if TimeLeft <= 0 then
		if PHASE == "BUILD" then
			GAMEMODE:StartBattle()
		elseif PHASE == "BATTLE" then
			GAMEMODE:StartBuild()
		end
	end
	if CurTime() > VOTE_ENABLE_TIME && votingenabled == false then
		 votingenabled = true
		 for k,v in pairs(player.GetAll()) do
			v:ChatPrint("Map voting is now enabled!")
		 end
	end
end

function Pmeta:GetClass()
	return Classes[self:GetNWInt("class")]
end

function GM:RestockPlayer(ply)
	if !ply then return end
	--for k,v in pairs(AMMOS) do
	--	local class = ply:GetNWInt("class")
	--	if table.HasValue(Classes[class].AMMO, k) then
	--		ply:GiveAmmo(v.QT, v.AMMO)
	--	end
	--end
	local class = ply:GetNWInt("class")
	for k,v in pairs(Classes[class].AMMO) do
		local mult = AMMOS[v].SMULT or 1
		ply:GiveAmmo(AMMOS[v].QT*2*mult, AMMOS[v].AMMO)
	end
end

function BuyAmmo(ply, com, args)
	if !ply.AmmoBin then return end
	if !args[1] then return end
	local mon = ply:GetNWInt("money")
	local ammotogive = AMMOS[tonumber(args[1])]
	if !ammotogive then return false end
	local amt = tonumber(args[2])
	if mon - ammotogive.PRICE*amt <= 0 then
		ply:Message("Insufficient Funds!", Color(255,100,100,255))
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
	else
		ply:SendLua([[surface.PlaySound("items/ammo_pickup.wav")]])
		ply:SetNWInt("money",mon - ammotogive.PRICE*amt)
		ply:GiveAmmo(ammotogive.QT*amt, ammotogive.AMMO)
		ply:Message("Bought "..ammotogive.QT*amt.." of "..ammotogive.NAME,Color(255,100,100,255), true)
	end
end

concommand.Add( "buy_ammo", BuyAmmo )

function Pmeta:Ammo(bin)
	self.AmmoBin = bin
	self:Freeze(true)
	bin.InUse = true
	umsg.Start("openammo", self)
	umsg.End()
end

function CloseAmmo(ply)
	if !ply.AmmoBin then return end
	ply.AmmoBin:Close()
	ply.AmmoBin.InUse = false
	ply.AmmoBin = nil
	ply:Freeze(false)
end

concommand.Add("ammo_closed", CloseAmmo)

function Pmeta:GetRank()
	local rank = self:GetNWInt("rank")
	return rank
end

function Pmeta:Message(txt,col,msg)
	local colour = col or Color(255,255,255,255)
	umsg.Start("ose_msg", self)
		umsg.String(tostring(txt))
		umsg.String(colour.r.." "..colour.g.." "..colour.b.." "..colour.a)
		umsg.Bool(msg)
	umsg.End()
end

function Pmeta:MdlMessage(mdl,txt,col,msg)
	local colour = col or Color(255,255,255,255)
	umsg.Start("ose_mdl_msg", self)
		umsg.String(tostring(mdl))
		umsg.String(tostring(txt))
		umsg.String(colour.r.." "..colour.g.." "..colour.b.." "..colour.a)
		umsg.Bool(msg)
	umsg.End()
end

function Pmeta:AddHealth(health)
	if self:Health() + health > self:GetMaxHealth() then
		self:SetHealth(self:GetMaxHealth())
		return
	end
	self:SetHealth(self:Health() + health)
end

function Pmeta:Taunt()
	self.LastTaunt = self.LastTaunt or CurTime()
	if math.random(1,2) == 2 && self.LastTaunt + 20 <= CurTime() then
		local class = self:GetNWInt("class")
		local taunts = TAUNTS[class]
		self:EmitSound(taunts[math.random(1,#taunts)],140,100)
		self.LastTaunt = CurTime()
	end
end

function GM:OnNPCKilled( npc, killer, wep)
	if !killer:IsValid() then return end
	local class = npc:GetClass()
	local name = npcs[class] or class
	local bonus = 0

	if class == "npc_combine_s" then
		for k,v in pairs(ents.FindByClass("item_ammo_ar2_altfire")) do
			v:Remove()
		end
		if npc:GetModel() == "models/combine_super_soldier.mdl" then
		bonus = 40
		elseif npc:GetModel() == "models/combine_soldier_prisonguard.mdl" then
		bonus = 20
		end
	end
	local plyobj = killer
	if killer:IsPlayer() then 
	elseif ValidEntity(killer:GetOwner()) && killer:GetOwner():IsPlayer() then
			plyobj = killer:GetOwner()
	elseif ValidEntity(npc.Igniter) then
		plyobj = npc.Igniter
	end
	if !plyobj:IsPlayer() then return false end
	self:CalculatePowerups(npc,plyobj,wep)
	self:AddNPCKillMoney(class,plyobj,bonus)
	GAMEMODE:CheckRanks(plyobj,false)
end

function GM:AddNPCKillMoney(class,ply,bonus)
	local npc = "npc_combine_s" --default to stop errors
	for k,v in pairs(NPCS) do
		if v.CLASS == class then npc = v break end
	end
	local givemoney = npc.MONEY or 50
	local name = npcs[class] or class
	local mdl = npc.MODEL or "models/headcrab.mdl"
	givemoney = givemoney + bonus

	ply:SetNetworkedInt("money",ply:GetNetworkedInt( "money") + givemoney)
	ply:Message("+"..tonumber(givemoney).." ["..name.."]", Color(100,255,100,255))
	timer.Simple(0.2,ply.Taunt,ply)
	ply:SetNWInt("kills", ply:GetNWInt("kills") + math.Round(math.Clamp(givemoney / 100, 1, 10)))
	ply:SetFrags(ply:GetNWInt("kills"))
end

function GM:CalculatePowerups(npc, killer, wep, bonus)
	killer.LastKill = killer.LastKill or CurTime()
	if killer.LastKill + 0.5 > CurTime() then
		killer:Message("+10 Health [Double Kill]", Color(100,100,255,255))
		killer:AddHealth(10)
	end
	killer.LastKill = CurTime()
end

function DeleteModel(ply, cmd, args)
	local model = args[1]
	if !model then return end
	if PHASE == "BATTLE" && !MODELS[model].ALLOWBATTLE then
		ply:Message("You can't delete props in battle!", Color(255,100,100,255))
		return
	end
	local entz = ents.FindByModel(model)
	local monadd = 0
	if #entz > 0 then
		for k,v in pairs(entz) do
			if v.Owner == ply then if v.SMH then monadd = monadd + v.SMH end v:Dissolve() end
		end
		if monadd > 0 then
			ply:Message("+"..math.Round(monadd).." [Sold Props]", Color(100,255,100,255))
			ply:SetNWInt("money", ply:GetNWInt("money") + monadd)
		end
	end
end

concommand.Add("deletemodel", DeleteModel)

function OSE_Spawn(ply,cmd,args)
	if !args[1] then return end
	local model = tostring(args[1])
	if MODELS[model].ALLOWBATTLE then
	elseif PHASE == "BATTLE"  then
		ply:Message("You can't spawn props in battle mode!", Color(255,100,100,255))
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return
	end
	if !MODELS[model] then
		ply:Message("That model is disallowed!", Color(255,100,100,255))
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return
	elseif MODELS[model].PLYCLASS && MODELS[model].PLYCLASS != ply:GetNWInt("class") then
		ply:Message("Your Class cannot use that!", Color(255,100,100,255))
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return
	end
	
	local class = "sent_prop"
	local name = "Prop"
	if MODELS[model].CLASS then class = MODELS[model].CLASS end
	if MODELS[model].NAME then name = MODELS[model].NAME end
	
	local propcount = 0
	for k,v in pairs(ents.FindByClass(class)) do
		if v.Owner == ply || v:GetOwner() == ply then
			propcount = propcount + 1
		end
	end
	if MODELS[model].LIMIT then 
		if propcount >= MODELS[model].LIMIT then 
			ply:Message(name.."  Limit Reached!", Color(255,100,100,255)) 
			ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
			return 
		end 
	elseif propcount >= PROP_LIMIT then 
		ply:Message(name.."  Limit Reached!", Color(255,100,100,255)) 
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return 
	end
	
	local tracelen = 1000
	if MODELS[model].RANGE then tracelen = MODELS[model].RANGE end
 
	local trace = {} 
 	trace.start = ply:GetShootPos()
 	trace.endpos = ply:GetShootPos() + (ply:GetAimVector() * tracelen) 
 	trace.filter = ply
 
 	local tr = util.TraceLine( trace ) 
 
	if !tr.Hit then return end
	
	local ent
	
	if !MODELS[model].DONTSPAWN then 
		local ang = ply:EyeAngles()
		ang.yaw = ang.yaw + 180
		if MODELS[model].ANG then ang.yaw = ang.yaw + MODELS[model].ANG.yaw end
 		ang.roll = 0 
 		ang.pitch = 0 
		ent = ents.Create(class)
		ent:SetAngles(ang)
		ent:SetPos(tr.HitPos)
		ent:SetModel(model)
		ent.Owner = ply
		ent:Spawn()
		ent:Activate()
		//garry
		local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )	// Find a point that is definitely out of the object in the direction of the floor 
		vFlushPoint = ent:NearestPoint( vFlushPoint )			// Find the nearest point inside the object to that point 
		vFlushPoint = ent:GetPos() - vFlushPoint				// Get the difference 
		vFlushPoint = tr.HitPos + vFlushPoint					// Add it to our target pos 
	 
		ent:SetPos( vFlushPoint )
		//endgarry
		
		local cost = MODELS[model].COST or ent.SMH or 1000
		cost = cost * 1.05
		
		if args[2] then 
			if tonumber(args[2]) < util.GetModelInfo(ent:GetModel()).SkinCount then
				ent:SetSkin(tonumber(args[2]))
			end
		end
		
		if not ent:IsInWorld( ) then
			ent:Remove()
			ply:ChatPrint( "Prop was outside of the world!" )
			return
		elseif cost > ply:GetNetworkedInt( "money") then
			ply:Message("Insufficient Funds!", Color(255,100,100,255))
			ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
			ent:Remove()
			return
		else
			ply:SetNetworkedInt( "money",ply:GetNetworkedInt( "money") - cost)
			if MODELS[model].NAME then
			ply:Message((math.Round(cost * -1)).." [Spawned "..MODELS[model].NAME.."]", Color(255,100,100,255))
			else
			ply:Message((math.Round(cost * -1)).." [Spawned Item]", Color(255,100,100,255))
			end
		end
	end
	if MODELS[model].EXTBUILD then 
		MODELS[model].EXTBUILD(ent, ply, tr)
	end
end
 
concommand.Add("gm_spawn", OSE_Spawn)

function GM:ShutDown( )

end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

end

function GM:CreateEntityRagdoll( entity, ragdoll )

	ragdoll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	timer.Simple( 2, function( r ) if ValidEntity( r ) then r:Remove( ) end end, ragdoll )
	
end
