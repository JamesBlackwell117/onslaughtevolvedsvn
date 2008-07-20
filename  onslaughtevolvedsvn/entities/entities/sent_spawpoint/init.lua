AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

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
	local ED = EffectData( )
	ED:SetEntity(self)
	ED:SetOrigin(self:GetPos())
	util.Effect( "spawnpoint", ED )
end

function ENT:Think( )
end
