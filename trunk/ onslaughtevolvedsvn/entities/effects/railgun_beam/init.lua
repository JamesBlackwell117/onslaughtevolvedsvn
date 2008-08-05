
function EFFECT:Init( data ) 
   
 	self.Position = data:GetStart()
	self.Player = data:GetEntity()
 	self.WeaponEnt = self.Player:GetActiveWeapon()
 	self.Attachment = data:GetAttachment() 

 	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.Spawned = CurTime()
	
	self.emitter = ParticleEmitter( self.StartPos )
end

local parts = { "models/roller/rollermine_glow", "decals/redglowfade"}
 
function EFFECT:Think()

 	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = self.Player:GetEyeTrace().HitPos
   	if not ValidEntity( self.WeaponEnt ) then
		return false
	end
	/*
	local p = self.emitter:Add( "effects/bluemuzzle", (self.StartPos + self.Player:GetAimVector() * 5))
	local vel = (Vector(.1,0.1,0.1))
	p:SetVelocity( vel )
	p:SetDieTime( math.Rand( .5, .8 ) )
	p:SetGravity( Vector( 0, 0, -1 ) )
	p:SetStartSize( math.Rand( 0.5, 1 ) )
	p:SetEndSize( 9 )
	p:SetStartAlpha( math.Rand( 200, 255 ) )
	p:SetAirResistance( 10 )
	p:SetEndAlpha( 0 )
	*/
	if self.Spawned + 0.1 <= CurTime() then
		return false
	end
	return true
end
 
local Laser = Material( "cable/blue_elec" )
local muz = Material("effects/blueblackflash")

function EFFECT:Render()
	render.SetMaterial( Laser )
	render.DrawBeam( self.StartPos, self.EndPos, 15, 0, 0, Color( 255, 255, 255, 255 ) )
	render.SetMaterial( muz )
	render.DrawSprite(self.StartPos + self.Player:GetAimVector() * 5, 10, 10, color_white)
end
