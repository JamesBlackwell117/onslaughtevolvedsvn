AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.Shealth = 100
ENT.Mhealth = 100
ENT.Model = ""
ENT.Owner = nil
ENT.LastTouch = CurTime()
ENT.Prepared = false
ENT.Bull = nil


function ENT:Initialize()
	self.Entity:SetModel( self.Model ) 	//Model path
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )  
	self.Entity:SetSolid( SOLID_VPHYSICS )      
	
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableMotion(false)
		self:SetUnFreezable( true )
		self:CalculateHealth()
	end
	
end

function ENT:CalculateHealth()
		local phys = self.Entity:GetPhysicsObject()  	
		self.Shealth = phys:GetMass()
		self.Shealth = self.Shealth * (self.Entity:OBBMins():Distance(self.Entity:OBBMaxs())) / 100
		
		if self.Shealth < 200 then
			self.Shealth = 200
		elseif self.Shealth > 800 then
			self.Shealth = 800
		end
		self.Mhealth = self.Shealth 
end

function ENT:SpawnFunction( ply, tr) //This func is used by gmods entity menu

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "sent_prop" ) // This line must be EXACTLY the same as the sents folder name!
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Touch(ent) -- Zombies need all the help they can get :-(
	if table.HasValue(Zombies, ent:GetClass()) && self.LastTouch + 2 < CurTime() then
		ent:SetSchedule(SCHED_MELEE_ATTACK1)
		ent:SetNPCState(3)
		self.Shealth = self.Shealth - 70
		self.Entity:UpdateColour()
		self.LastTouch = CurTime()
		if self.Shealth <= 0 then
			self:Dissolve()
		elseif FLAMABLE_PROPS && self.Shealth / self.Mhealth <= 0.4 then
			self.Entity:Ignite(8,150)
		end
	end
end

function ENT:InitCreateBull()
		//Ailia
		local ang = self:GetAngles()
		local spawners = ents.FindByClass("sent_spawner")
 
		local bull = ents.Create("npc_bullseye")
		local pos = spawners[math.random(1,#spawners)]:GetPos()
 
		local npz = self:LocalToWorld(self:OBBCenter())
 
		local bullpos = self.NearestPoint(self, Vector(pos.x,pos.y,npz.z))	
 
		bullpos = self:WorldToLocal(bullpos)
 
		local posone = self:OBBMaxs()
		local postwo = self:OBBMins()
 
		local xd = posone.x - postwo.x
		local yd = posone.y - postwo.y
		local zd = posone.z - postwo.z
 
		local xy = xd*yd
		local xz = xd*zd
		local yz = yd*zd
 
		if xy > xz && xy > yz then 
		bullpos.z = self:OBBCenter().x
		elseif xz > yz && xz > xy then
		bullpos.x = self:OBBCenter().z
		else
		bullpos.y = self:OBBCenter().y
		end
 
		bullpos = self:LocalToWorld(bullpos)
 
		bull:SetPos(bullpos)
		bull:SetParent(self.Entity)
		bull:SetKeyValue("health","9999")
		bull:SetKeyValue("minangle","360")
		bull:SetKeyValue("spawnflags","1049092")
		bull:SetNotSolid( true )
		bull:Spawn()
		bull:Activate()
		self.Bull = bull
		self:SetAngles(ang)
		/*
		local vis = ents.Create("prop_physics") --- debugging position code
		vis:SetPos(bullpos)
		vis:SetParent(self.Entity)
		vis:SetColor(255,100,100,100)
		vis:SetModel("models/props_junk/wood_crate001a.mdl")
		vis:SetNotSolid( true )
		vis:Spawn()
		vis:Activate()
		*/
		//Ailia
end

function ENT:Think()
end

function ENT:Prepare()
	self:CalculateHealth()
	if ValidEntity(self.Bull) then
		self.Bull:Remove()
	end
	self:InitCreateBull()
	local trace = util.QuickTrace(self:GetPos(), Vector(0,0,-1000), ents.FindByClass("sent_*"))
	if trace.HitWorld then
		if trace.Fraction > .01 then
			self.Mhealth = self.Mhealth / (10*trace.Fraction)
		end
	end
	local propcount = #ents.FindByClass("sent_prop")
	self.Mhealth = self.Mhealth - ((propcount / 3) * self.Mhealth / 320) --less health for more props
	self.Shealth = self.Mhealth
	if self.Mhealth <= 50 then self.Mhealth = 50 self.Shealth = 50 end
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetColor(255,255,255,255)
	self.Entity:SetMoveType( MOVETYPE_NONE )
end

function ENT:UpdateColour()
	if self.Shealth > self.Mhealth then
		self.Shealth = self.Mhealth
	end
	local col = (self.Shealth / self.Mhealth) * 255
	self.Entity:SetColor(col, col, col, 255)
end

function ENT:OnTakeDamage(dmg)
	if dmg:GetInflictor():IsPlayer() then
	 	dmg:SetDamage(0)
		return dmg 
	elseif ValidEntity(dmg:GetInflictor():GetOwner()) then
		if dmg:GetInflictor():GetOwner():IsPlayer() then
			dmg:SetDamage(0)
			return dmg
		end
	end
	
	local damage = dmg:GetDamage()
	local pos = self:LocalToWorld(self:OBBCenter())
	local count = 0
	local base = 0

	for k,v in pairs(ents.FindInBox(Vector(pos.x-300,pos.y-300,pos.z-300),Vector(pos.x+300,pos.y+300,pos.z+300))) do
		if v:IsPlayer() then count = count + 1 end
	end
	
	if count == 0 then damage = damage * math.sqrt(#player.GetAll())
	else damage = damage * math.sqrt(#player.GetAll()) / count end
	
	if dmg:GetInflictor():GetClass() == "weapon_shotgun" then damage = damage / 2 end

	self.Shealth = self.Shealth - damage 
	self:UpdateColour()
	if self.Shealth <= 0 then
		self:Dissolve()
	elseif FLAMABLE_PROPS && self.Shealth / self.Mhealth <= 0.4 then
		self.Entity:Ignite(8,150)
	end
	return dmg
end

function ENT:OnRemove()
end

