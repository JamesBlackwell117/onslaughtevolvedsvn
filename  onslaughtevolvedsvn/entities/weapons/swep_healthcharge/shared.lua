
if SERVER then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight	= 1
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom	= false
end

if CLIENT then
	SWEP.PrintName = "Health Charger"
	SWEP.DrawCrosshair = true
	SWEP.DrawAmmo = true
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false
	SWEP.Slot = 1
end

SWEP.ViewModel	= "models/weapons/v_superphyscannon.mdl"
SWEP.WorldModel	= "models/weapons/w_physics.mdl"
SWEP.mdl = "models/weapons/v_superphyscannon.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "physgun" )
	end
end
 
function SWEP:Deploy()
	return true
end

function SWEP:Think( )
	if !self.Owner:KeyDown( IN_ATTACK ) && !self.Owner:KeyDown( IN_ATTACK2 ) then
		if self:GetNWInt("mode") != 0 then
			self:SetNWInt("mode",0)
		end
	end
end
 
function SWEP:PrimaryAttack( )
	if self:GetNWInt("mode") != 1 then
		self:SetNWInt("mode",1)
	end
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .1 )
	self.Weapon:SetNextSecondaryFire( CurTime( ) + .1 )
	local tr = util.GetPlayerTrace( self.Owner ) 
 	local trace = util.TraceLine( tr )
 	if (!trace.Hit) then return end
	local ent = trace.Entity
	local hitpos = trace.HitPos
	if CLIENT then
		self.mdl = "models/weapons/v_physcannon.mdl"
	else
		if ValidEntity(ent) && ent:IsNPC() && !ent:IsProp() then
			ent:SetHealth(ent:Health() - 6)
			if ent:Health() > 0 && self:Clip1() < 50 then
				self:SetClip1(self:Clip1() + 1)
			else
				ent:TakeDamage(1,self.Owner, self.Owner)
			end
		end	
	end
end

function SWEP:SecondaryAttack( )
	if self:GetNWInt("mode") != 2 then
		self:SetNWInt("mode",2)
	end
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .1 )
	self.Weapon:SetNextSecondaryFire( CurTime( ) + .1 )
	
	local tr = util.GetPlayerTrace( self.Owner ) 
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	local ent = trace.Entity
	local hitpos = trace.HitPos
	
	if CLIENT then
		self.mdl = "models/weapons/v_superphyscannon.mdl"
	else
		if ValidEntity(ent) && ent:IsPlayer() && ent:Health() < ent:GetMaxHealth() then
			if self:Clip1() > 0 then
				ent:AddHealth(4)
				self:SetClip1(self:Clip1() - 1)
			end
		end
	end
end

function SWEP:GetViewModelPosition(pos,ang)
	local ViewModel = LocalPlayer():GetViewModel()
	if !ViewModel:IsValid() then return pos,ang end	
	ViewModel:SetModel( self.mdl )
	return pos,ang
end

function SWEP:Reload()
	if self:Clip1() >= 25 then
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(),500)) do
				if v:IsPlayer() then v:AddHealth(200) end
			end
		end
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetPos() )
		effectdata:SetEntity( self.Owner )
		util.Effect( "support_healthexplode", effectdata )
		self:SetClip1(self:Clip1() - 25)
	end
end

function SWEP:DrawWorldModel()
	self.Weapon:DrawModel()
	if CLIENT then
 		local spos = ViewModel:GetAttachment(1) 
	
		local TexOffset = CurTime()*-2.0
	
		if self:GetNWInt("mode") == 1 then
			local tr = util.GetPlayerTrace( self.Owner ) 
			local trace = util.TraceLine( tr )
			if (!trace.Hit) then return end
			
			render.SetMaterial( Material( "onslaught/refract_ring") )
			render.UpdateRefractTexture()
			render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )
			
			render.SetMaterial( Material( "cable/redlaser" )  )
			render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )
			
			render.SetMaterial(Material("sprites/redglow1"))
			render.DrawSprite(trace.HitPos, 20, 20, Color( 255, 50, 50 ))
			
		elseif self:GetNWInt("mode") == 2 then
			local tr = util.GetPlayerTrace( self.Owner ) 
			local trace = util.TraceLine( tr )
			if (!trace.Hit) then return end
			
			render.SetMaterial( Material( "onslaught/refract_ring"))
			render.UpdateRefractTexture()
			render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )
			
			render.SetMaterial(Material( "cable/physbeam"))
			render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )
			
			render.SetMaterial(Material("sprites/animglow02"))
			render.DrawSprite(trace.HitPos, 10, 10, Color( 50, 50, 255 ))
		end
	end
end

function SWEP:ViewModelDrawn()
	if CLIENT then
		local ViewModel = LocalPlayer():GetViewModel()
		if !ViewModel:IsValid() then return end
 		local spos = ViewModel:GetAttachment(1) 
	
		local TexOffset = CurTime()*-2.0
	
		if self:GetNWInt("mode") == 1 then
			local tr = util.GetPlayerTrace( self.Owner ) 
			local trace = util.TraceLine( tr )
			if (!trace.Hit) then return end
			
			render.SetMaterial( Material( "onslaught/refract_ring") )
			render.UpdateRefractTexture()
			render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )
			
			render.SetMaterial( Material( "cable/redlaser" )  )
			render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )
			
			render.SetMaterial(Material("sprites/redglow1"))
			render.DrawSprite(trace.HitPos, 20, 20, Color( 255, 50, 50 ))
			
		elseif self:GetNWInt("mode") == 2 then
			local tr = util.GetPlayerTrace( self.Owner ) 
			local trace = util.TraceLine( tr )
			if (!trace.Hit) then return end
			
			render.SetMaterial( Material( "onslaught/refract_ring"))
			render.UpdateRefractTexture()
			render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )`
			
			render.SetMaterial(Material( "cable/physbeam"))
			render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )
			
			render.SetMaterial(Material("sprites/animglow02"))
			render.DrawSprite(trace.HitPos, 10, 10, Color( 50, 50, 255 ))
		end
	end
end
