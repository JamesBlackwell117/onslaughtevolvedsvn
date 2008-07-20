
function EFFECT:Init( data ) 
	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()
	self.emitter = ParticleEmitter( self.Pos )
end

local parts = { "models/roller/rollermine_glow", "sprites/light_glow02_add"} --, "models/roller/rollermine_glowred", "models/roller/rollermine_gloworange"}
 
function EFFECT:Think()
   	if not ValidEntity( self.Ent )  then
		self.emitter:Finish( )
		return false
	end
	local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos)
	for i = 0, 10 do
		local vel = (Vector(math.Rand(-15,15), math.Rand(-15,15),math.Rand(50,120) + i))
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( .5, .8 ) )
		p:SetGravity( Vector( 0, 0, -1 ) )
		p:SetStartSize( math.Rand( 1, 4 ) )
		p:SetEndSize( 15 )
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
	end
	local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos)
	for i = 0, 2 do
		local vel = (Vector(math.sin(CurTime() * 10) * 50, math.cos(CurTime() * 10) * 50, 25))
		p:SetVelocity( vel )
		p:SetDieTime( .8 )
		p:SetGravity( Vector( 0, 0, -1 ) )
		p:SetStartSize( math.Rand( 1, 4 ) )
		p:SetEndSize( 15 )
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
	end
	local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos)
	for i = 0, 2 do
		local vel = (Vector(math.sin(CurTime() * 10) * -50, math.cos(CurTime() * 10) * -50, 25))
		p:SetVelocity( vel )
		p:SetDieTime( .8 )
		p:SetGravity( Vector( 0, 0, -1 ) )
		p:SetStartSize( math.Rand( 1, 4 ) )
		p:SetEndSize( 15 )
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
	end
	WorldSound( "k_lab.teleport_rings_high", self.Pos , 1, 100)
	return true
end

function EFFECT:Render()
 
end
