AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.owner = nil

function ENT:Initialize()   
	self.Entity:SetModel( "models/props_combine/combine_mine01.mdl")
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )  
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableGravity( false )
	end

end


function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "sent_prop" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Touch(ent)
end

function ENT:Think()
	local ents = ents.FindInSphere(self.Entity:GetPos(), 50)
	for k,v in pairs(ents) do
		if v:IsNPC() && v:GetClass() != "npc_bullseye" && v:GetClass() != "npc_turret_floor" then
			self:Explode(v)
			return
		end
	end
	self.Entity:NextThink( CurTime( ) + 2 )
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
		util.BlastDamage( self.Entity, self.Entity, pos, 500, 180 )
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
