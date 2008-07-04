
function EFFECT:Init( data ) 
   
 	self.Position = data:GetStart()
	self.Player = data:GetEntity()
 	self.WeaponEnt = self.Player:GetActiveWeapon()
 	self.Attachment = data:GetAttachment() 
 	 
	-- Keep the start and end pos - we're going to interpolate between them 
 	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment ) 
 	self.EndPos = data:GetOrigin() 
 	 
	self.emitter = ParticleEmitter( self.StartPos )
   
 end

 
function EFFECT:Think()

 	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment ) 
   	if not ValidEntity( self.WeaponEnt ) then
		self.emitter:Finish( )
		return false
	end
	if ValidEntity( self.WeaponEnt ) and self.WeaponEnt:GetClass( ) == "swep_flamethrower" and self.WeaponEnt:GetNWBool( "On", false ) then
		for i = 0,10 do
			local p = self.emitter:Add( "particles/flamelet"..math.random( 1, 5 ), (self.StartPos + self.Player:GetAimVector() * 5))
			local vel = (self.Player:GetAimVector() * (math.random(440,460) + i) + self.Player:GetVelocity( )) + Vector(math.Rand(-15,15), math.Rand(-15,15),math.Rand(-15,15)) --spread it out a bit
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( .5, .8 ) )
			p:SetGravity( Vector( 0, 0, -1 ) )
			p:SetStartSize( math.Rand( 0.5, 1 ) )
			p:SetEndSize( 9 )
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 10 )
			p:SetEndAlpha( 0 )
		end
		for i = 0, 2 do
			local p = self.emitter:Add( "particles/flamelet"..math.random( 1, 5 ), self.StartPos )
			local vel = (self.Player:GetAimVector() * 450 + self.Player:GetVelocity( ))
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( .1, .2 ) )
			p:SetGravity( Vector( 0, 0, -5 ) )
			p:SetStartSize( math.Rand( 0.5, 1 ) )
			p:SetEndSize( 1)
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 10 )
			p:SetEndAlpha( 0 )
			p:SetColor(100,100,255,math.random(150,200))
		end

	end
	if math.random(1,5) >= 4 then
		local p = self.emitter:Add( "sprites/heatwave", (self.StartPos + self.Player:GetAimVector() * 5))
		local vel = (self.Player:GetAimVector() * math.random(440,460) + self.Player:GetVelocity( )) + Vector(math.Rand(-15,15), math.Rand(-15,15),math.Rand(-15,15)) --spread it out a bit
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( .5, .8 ) )
		p:SetGravity( Vector( 0, 0, -1 ) )
		p:SetStartSize( math.Rand( 5, 6 ) )
		p:SetEndSize( 10 )
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
	end
	if math.random(1,5) == 1 then
		local p = self.emitter:Add( "particle/smokesprites_000"..math.random(1,6), self.StartPos + self.Player:GetAimVector())
		local vel = (((self.Player:GetAimVector() * 5) + self.Player:GetVelocity( )) + Vector(math.Rand(-5,5), math.Rand(-5,5),math.Rand(-5,5))) --spread it out a bit
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( .5, .8 ) )
		p:SetGravity( Vector( 0, 0, 2 ) )
		p:SetStartSize( math.Rand( 0.8, 1.2 ) )
		p:SetEndSize( 3 )
		p:SetStartAlpha( math.Rand( 150, 200 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
		p:SetColor(50,50,50)
	end
	
	return false
 end
 
 function EFFECT:Render()
 
 end
