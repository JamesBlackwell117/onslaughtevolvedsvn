AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

npc_types = {"npc_combine_s", "npc_manhack", "npc_hunter"}

ENT.Npcs = npc_types
ENT.pathname = "path"
ENT.Delay = SPAWN_DELAY

function ENT:KeyValue( key, value )
	if key == "npc" then
		self.Npcs = string.Explode(" ", value)
		if self.Npcs[1] == nil then
			ErrorNoHalt("WARNING!: sent_spawner keyvalues set up incorrectly!\n See a mapper!\n")
			self.Npcs = npc_types
		end
		if ZOMBIEMODE_ENABLED then
			for k,v in pairs(self.Npcs) do
				if table.HasValue(Zombies,v) then
				else ZOMBIEMODE_ENABLED = nil MAX_NPCS = MAX_NPCS /2 break end
			end
		end
	end
	if key == "path" then
		self.pathname = value
	end
	if key == "spawndelay" then
		self.Delay = value
	end
end

function ENT:Initialize( )
	self.Entity:SetModel( "models/props_junk/wood_crate002a.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )

	self:SetNotSolid( true )
	self:SetNoDraw( true )
	self:DrawShadow( false )

	local phys = self.Entity:GetPhysicsObject( )
	if phys:IsValid( ) then
		phys:Wake( )
		phys:EnableMotion( false )
		phys:EnableCollisions( false )
	end
end

function ENT:Think( )
	if PHASE == "BATTLE" then
		if NPC_COUNT < MAX_NPCS && LAGGGGG < PING_LIMIT then
			if #player.GetAll( ) == 0 then return end
			local npc = self.Npcs[ math.random( 1, #self.Npcs) ]
			local hacks = #ents.FindByClass("npc_manhack")
			local hunters = #ents.FindByClass("npc_hunter")
			if npc == "npc_hunter" then
				 if hunters >= MAXHUNTERS + math.Round(#player.GetAll()/4) then
					self.Entity:NextThink( CurTime( ) + self.Delay )
					return true
				end
			elseif npc == "npc_manhack" then
				if hacks >= MAXHACKS then
					self.Entity:NextThink( CurTime( ) + self.Delay )
					return true
				end
			end

			for k,v in pairs(self.Npcs) do
				if v == "npc_hunter" && hunters < MAXHUNTERS + math.Round(#player.GetAll()/4) then
					npc = v
					break
				end
			end

			local ent = ents.Create( npc )
			if !ValidEntity(ent) then return end --stop non existant npcs spawning
			local SpawnPos = Vector( (self.Entity:GetPos( ).x + math.random( -200, 200 )), (self.Entity:GetPos( ).y + math.random( -200, 200 )), self.Entity:GetPos( ).z + 10 )
			ent:SetPos( SpawnPos )
			ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

			local v = NPCS[npc]
			if v then -- This code makes sense to me :D
				if v[1] then v = v[math.random(1,#v)] end
				local flags = v.FLAGS
				if v.KEYS then
					local keys = v.KEYS
					keys = string.Explode(" ", keys)
					for k,v in pairs(keys) do
						if (k / 2) != math.Round(k / 2) then
							ent:SetKeyValue(v, keys[k + 1])
						end
					end
				end
				ent:SetKeyValue("spawnflags", flags)
				if v.SQUAD then
					ent:SetKeyValue("squadname", v.SQUAD)
				end
				ent:SetKeyValue("wakesquad", 1)
				ent:SetKeyValue("wakeradius", 999999)
			end

			ent:SetKeyValue("target",self.pathname)

			local ED = EffectData( )
			ED:SetEntity( ent )
			util.Effect( "npc_spawn", ED )

			for k,v in pairs(player.GetAll()) do
				ent:AddEntityRelationship(v, 1, 99 )
			end

			for k,v in pairs(NPCS) do
				ent:Fire( "setrelationship", k .. " D_LI 99" ) -- make the npcs like eachother
			end

			if ent:IsZombie() then
				if math.random(1,4) == 1 then
					ent.poison = true
					ent:SetColor(50,255,50,255)
				end
				for k,v in pairs(ents.FindByClass("npc_bullseye")) do
					local trace = util.QuickTrace(v:GetPos(), Vector(0,0,-75), ents.FindByClass("sent_*"))
					if trace.HitWorld then
						ent:AddEntityRelationship(v, 1, 1 )
					end
				end
			else
				ent:Fire( "setrelationship", "npc_bullseye D_HT 1" )
			end
			ent.spn = true
			ent:Spawn( )
			ent:Activate( )
			NPC_COUNT = NPC_COUNT + 1
		end
	end
	self.Entity:NextThink( CurTime( ) + self.Delay )
	return true
end
