
function EFFECT:Init( data ) 
   
 	self.Position = data:GetStart()
	self.Player = data:GetEntity()
 	self.WeaponEnt = self.Player:GetActiveWeapon()
 	self.Attachment = data:GetAttachment() 

 	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment ) 
 	self.EndPos = data:GetOrigin() 
end

local parts = { "models/roller/rollermine_glow", "decals/redglowfade"}
 
function EFFECT:Think()

 	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = self.Player:GetEyeTrace().HitPos
   	if not ValidEntity( self.WeaponEnt ) || self.WeaponEnt:GetNWBool("On2", false) == false then
		return false
	end
	return true
end
 
local Laser = Material( "cable/physbeam" )

function EFFECT:Render()
	render.SetMaterial( Laser )
	render.DrawBeam( self.StartPos, self.EndPos, 15, 0, 0, Color( 255, 255, 255, 255 ) )
end
