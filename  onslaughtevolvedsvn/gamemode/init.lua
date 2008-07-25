//Conman, Xera

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_panels.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_hud.lua")
AddCSLuaFile( "ose.lua" )

Pmeta = FindMetaTable( "Player" )
Emeta = FindMetaTable( "Entity" )

include( "metafunctions.lua" )
include( "prop_save.lua" )
include( "shared.lua" )
include( "cl_panels.lua" )
include( "commands.lua" )

for k,v in pairs( file.Find( "../materials/onslaught/*" ) ) do
	resource.AddFile( "materials/onslaught/" .. v )
end

NextRound = BUILDTIME + CurTime( )
TimeLeft = NextRound - CurTime( )
local discplayers = {}
local ROUND_ID = 0

function GM:PlayerInitialSpawn(ply)
	ply.LastKill = 0
	ply.Buddies = {} --I'll get round to this I swear
	ply.Died = 0
	ply:SetNetworkedInt( "kills", 0)
	ply:SetNetworkedInt( "money", STARTING_MONEY )
	ply:SetNetworkedInt( "class", 1 )
	ply:SetNetworkedInt( "rank", 1 )
	timer.Simple(2,ply.GetDefaultClass, ply)
	AllChat(ply:Nick().." has finished joining the server!")
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
		ply:SetPos(ply.CusSpawn:GetPos())
		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		timer.Simple(2, ply.SetCollisionGroup,ply,COLLISION_GROUP_PLAYER)
	end
end

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

function GM:StartBattle()
	print("[ONSLAUGHT] Battle phase started!")
	NextRound = CurTime() + BATTLETIME
	UpdateTime()
	PHASE = "BATTLE"

	for k,v in pairs( ents.GetAll( ) ) do
		if v:IsWeapon( ) then
			v:Remove( )
		elseif v:IsNPC() || v:GetClass() == "ose_mines" then
			v:CheckValidOwnership()
		elseif v.Prepare then
			timer.Simple(k*0.05, v.Prepare, v)
		elseif v:IsPlayer() then
			v.Voted = false
			v.NextSpawn = (CurTime() + 5) + math.Rand(0.5,1.5)
			v:KillSilent()
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
				v:Money(bonus,"+"..bonus.." [Round Live Bonus]") -- if the player doesn"t die in that battle round give him some money
			end
			v.Died = 0
		end
	else
		for k,v in pairs(player.GetAll()) do
			local bonus = LIVE_BONUS + (DEATH_PENALTY * v.Died)
			if bonus > 0 && v.FullRound == true then
				v:Money(bonus,"+"..bonus.." [Round Live Bonus]")
				v:SetNWInt("kills", v:GetNWInt("kills") + math.Round(bonus / 100))
			end
			v.Died = 0
		end
	end
end

function GM:StartBuild()
	if PHASE != "BUILD" then
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
	GAMEMODE:CalculateLiveBonus()
	PHASE = "BUILD"
	end
	
	NextRound = CurTime() + BUILDTIME
	UpdateTime()
	voted = 0
	for k,v in pairs( ents.GetAll( ) ) do
		if v:IsWeapon( ) then
			v:Remove( )
		elseif v:IsNPC() || v:GetClass() == "ose_mines" then
			v:CheckValidOwnership(true)
		elseif v.PropReset then
			v:PropReset()
		elseif v:IsPlayer() then
			v.NextSpawn = CurTime() + 5
			v:KillSilent()
		end
	end
	for k,v in pairs(ents.FindByName("ose_build")) do
		if ValidEntity(v) then
			v:Fire("trigger",0,5)
		end
	end
	umsg.Start("StartBuild")
	umsg.End()
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
		
	if ply != killer then
		for k,v in pairs(player.GetAll()) do
			v:Message(ply:Nick().." was killed by a " .. name, Color(255,100,100,255), true)
		end
	end
	
	if self.AmmoBin then self.AmmoBin:Close() self.AmmoBin = nil end
	
	if PHASE == "BUILD" then
		ply.NextSpawn = CurTime() + 5
	else
		ply.NextSpawn = CurTime() + SPAWN_TIME + (#player.GetAll() * 10)
		ply:CreateRagdoll( )
		for k,v in pairs(ents.FindByClass("npc_turret_floor")) do
			if v:GetRealOwner() == ply then v:PropRemove() end
			end
		for k,v in pairs(ents.FindByClass("sent_dispenser")) do
			if v:GetRealOwner() == ply && v.Type == "BATTLE" then v:PropRemove() end
		end
	end
	
	ply.Died = ply.Died + 1
	timer.Simple(0.05,GAMEMODE.CheckDead, GAMEMODE)
	ply:AddDeaths(1)	
	return true
end

function GM:CheckDead(ply)
	if PHASE == "BUILD" then return end
	for k,v in pairs(player.GetAll()) do
		if ply != v and v:Alive() then return end
	end
	GAMEMODE:StartBuild()
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("All players have perished loading build mode!")
	end
end



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
				if ply:Health() <= 0 then ply:Kill() end
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
		if v:GetRealOwner() == ply then v:PropRemove() end
	end
	for k,v in pairs(ents.FindByClass("sent_dispenser")) do
		if v:GetRealOwner() == ply then v:PropRemove() end
	end
	if ValidEntity(ply.CusSpawn) then
		ply.CusSpawn:Remove()
	end
	timer.Simple(0.05,GAMEMODE.CheckDead, GAMEMODE)
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
			if v:GetRealOwner() == ply || !ValidEntity(v:GetRealOwner()) then
				v:PropRemove()
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
	if ent:PropOp(ply) then
		return true
	end
	return false
end

function GM:PhysgunDrop(ply, ent)
	ent:GetPhysicsObject():EnableMotion(false)
end

function GM:OnPhysgunFreeze(weapon, physobj, ent, ply)
	if ent:PropOp(ply) then
		if ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
			ent:SetColor(255,255,255,128)
		else
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		ent:SetColor(255,255,255,255)
		end
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
	
	local ent = trc.Entity
	
	if ent.Turret then ent = ent.Turret end 
	
	if ent:PropOp(ply) then
		ent:PropRemove(true)
	end
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

function GM:RestockPlayer(ply)
	if !ply then return end
	local class = ply:GetNWInt("class")
	for k,v in pairs(Classes[class].AMMO) do
		local mult = AMMOS[v].SMULT or 1
		ply:GiveAmmo(AMMOS[v].QT*2*mult, AMMOS[v].AMMO)
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

	ply:Money(givemoney,"+"..tonumber(givemoney).." ["..name.."]")
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

function GM:ShutDown( )

end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

end

function GM:CreateEntityRagdoll( entity, ragdoll )

	ragdoll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	timer.Simple( 2, function( r ) if ValidEntity( r ) then r:Remove( ) end end, ragdoll )
	
end