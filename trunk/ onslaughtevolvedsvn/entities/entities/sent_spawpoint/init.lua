AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize( )   
	self.Entity:SetModel( "models/props_junk/wood_crate001a.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetNoDraw( true )
	self:DrawShadow( false )	

	local phys = self.Entity:GetPhysicsObject( )  	
	if phys:IsValid( ) then  		
		phys:Wake( )
		phys:EnableMotion( false )
	end
	local ED = EffectData( )
	ED:SetEntity(self)
	ED:SetOrigin(self:GetPos())
	util.Effect( "spawnpoint", ED )

end

function ENT:Think( )
end
