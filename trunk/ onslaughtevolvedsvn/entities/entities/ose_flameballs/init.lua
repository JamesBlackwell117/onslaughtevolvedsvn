AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
	self.Entity:SetModel( "models/combine_helicopter/helicopter_bomb01.mdl")
	self.Entity:SetMoveType( MOVETYPE_FLY )  
	self.Entity:SetSolid( SOLID_BSP )  
	--self.Entity:SetNotSolid(true)
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableGravity( false )
	end
	self.Entity:SetColor(255,255,255,0)
		
	timer.Simple(0.9,  function(self) if ValidEntity(self) then self.Remove(self) end end, self.Entity)
end

function ENT:Touch(ent)
	if ent:IsNPC() && ent:GetClass() != "npc_turret_floor" then
		ent.Igniter = self.Owner
		ent:Ignite(7,50)
		ent:SetHealth(ent:Health()-2)
	end
	self.Entity:Remove()
end

function ENT:Think()
end

function ENT:Use()
	return false
end

function ENT:PhysicsCollide(data)
end

function ENT:OnRemove()
end
