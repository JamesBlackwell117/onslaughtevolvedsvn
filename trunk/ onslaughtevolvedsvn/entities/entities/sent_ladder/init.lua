AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()  
	self.Entity:SetModel(self.Model)
	self.Entity:PhysicsInit( SOLID_BBOX )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   
	self.Entity:SetSolid( SOLID_BBOX )      

	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableMotion(false)
	end
	local pos = ents.Create("func_useableladder")
	pos:SetAngles(self:GetAngles())
	pos:SetPos(self:GetPos() + (self:GetForward() * 30) + Vector(0,0,22))
	pos:SetKeyValue("point0", tostring(self:GetPos() + (self:GetForward() * 30) + Vector(0,0,22)))
	pos:SetKeyValue("point1", tostring(self:GetPos() + (self:GetForward() * 30) + Vector(0,0,155)))
	pos:SetParent(self)
	pos:Spawn()
	pos:Activate()
	local pos = ents.Create("info_ladder_dismount")
	pos:SetAngles(self:GetAngles())
	pos:SetPos(self:GetPos() + (self:GetForward() * 30) + Vector(0,0,22))
	pos:SetParent(self)
	pos:Spawn()
	pos:Activate()
	pos:SetAngles(self:GetAngles())
	pos:SetPos(self:GetPos() + (self:GetForward() * 30) + Vector(0,0,150))
	pos:SetParent(self)
	pos:Spawn()
	pos:Activate()
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "sent_ladder" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

