AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
	self.Entity:SetModel( "models/props_combine/combine_mine01.mdl")
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )  
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then 	
		phys:Wake()
		--phys:EnableGravity( false )
	end
	self:SetPoseParameter("blendstates", 1)
end

function ENT:Touch(ent)
end

function ENT:Think()
	if !self.Primed then
		local trc = {}
		trc.start = self:GetPos()
		trc.endpos = self:GetPos() + self:GetUp() * -2
		trc.filter = self
		trc = util.TraceLine( trc )
		if trc.HitWorld then
			self:SetNWBool("Closed", true)
			self.Primed = true
			self.Entity:GetPhysicsObject():EnableMotion(false)
			self:SetPoseParameter("blendstates", 1)
		else
			return
		end
		self:SetPoseParameter("blendstates", 1)
	end
	local ents = ents.FindInSphere(self.Entity:GetPos(), 250)
	for k,v in pairs(ents) do
		if v:IsNPC() && v:GetClass() != "npc_bullseye" && v:GetClass() != "npc_turret_floor" then
			self:Explode(v)
			return
		end
	end
	self.Entity:NextThink( CurTime( ) + 1 )
	return true
end

function ENT:Explode(ent)
	if !ValidEntity(self.Entity) then return end
	if !ValidEntity(ent) then return end
	if math.random(1,3) == 1 then
		local effectdata = EffectData()
		local pos = self.Entity:GetPos()
		effectdata:SetStart( pos )
		effectdata:SetOrigin( pos )
		effectdata:SetScale( 10 )
		util.Effect( "Explosion", effectdata )
		util.BlastDamage( self.Entity, self.Entity, pos, 300, 100 )
		self.Entity:Remove()
	end
end

function ENT:Use()
	return false
end

function ENT:PhysicsCollide(data)
end

function ENT:OnRemove()
end
