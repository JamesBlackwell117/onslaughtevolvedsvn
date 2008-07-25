
function EFFECT:Init( data ) 
	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()
	self.emitter = ParticleEmitter( self.Pos )
end

local parts = { "models/roller/rollermine_glow", "sprites/light_glow02_add", "models/roller/rollermine_glowred", "models/roller/rollermine_gloworange"}
 
function EFFECT:Think()
	local ply = self.Ent:GetNWEntity("owner")
   	if not ValidEntity( self.Ent )  then
		self.emitter:Finish( )
		return false
	end
	local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos)
	for i = 0, 6 do
		local vel = (Vector(math.Rand(-15,15), math.Rand(-15,15),math.Rand(50,120) + i))
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( .3, .5 ) )
		p:SetGravity( Vector( 0, 0, -1 ) )
		p:SetStartSize( math.Rand( 1, 4 ) )
		p:SetEndSize( 15 )
		p:SetColor(200,200,200)
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
	end
	if math.random(1,3) > 1 && ValidEntity(ply) then
		if !ply:Alive() then
			local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos)
			local vel = (Vector(math.sin(CurTime() * 10) * 40, math.cos(CurTime() * 10) * 40, 20))
			p:SetVelocity( vel )
			p:SetDieTime( .8 )
			p:SetGravity( Vector( 0, 0, -1 ) )
			p:SetStartSize( math.Rand( 1, 4 ) )
			p:SetEndSize( 15 )
			p:SetColor(200,200,200)
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 10 )
			p:SetEndAlpha( 0 )
			local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos)
			local vel = (Vector(math.sin(CurTime() * 10) * -40, math.cos(CurTime() * 10) * -40, 20))
			p:SetVelocity( vel )
			p:SetDieTime( .8 )
			p:SetColor(200,200,200)
			p:SetGravity( Vector( 0, 0, -1 ) )
			p:SetStartSize( math.Rand( 1, 4 ) )
			p:SetEndSize( 15 )
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 10 )
			p:SetEndAlpha( 0 )
		end
	end
	return true
end

function EFFECT:Render()
 
end
