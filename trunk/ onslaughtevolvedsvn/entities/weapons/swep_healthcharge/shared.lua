
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
	SWEP.BeamMat = Material( "cable/redlaser" ) 
end

SWEP.ViewModel	= "models/weapons/v_superphyscannon.mdl"
SWEP.WorldModel	= "models/weapons/w_physics.mdl"
SWEP.mdl = "models/weapons/v_superphyscannon.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

--SWEP.Sound = Sound("items/suitcharge1.wav")
--SWEP.SuckSound = Sound("npc/vort/attack_charge.wav")
--SWEP.StopSoond = Sound("vehicles/tank_turret_stop1.wav")

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "smg" )
	end
end

--function SWEP:Holster( )
--	self:SetNWBool( "On", false )
--	return true
--end
 
--function SWEP:Think( )
	--if self.Owner:KeyPressed( IN_ATTACK ) || self.Owner:KeyReleased( IN_ATTACK2 ) then
	--	if ( !self:CanPrimaryAttack() ) then return end
	--	self:SetNWBool( "On", true )
	--	self.Weapon:EmitSound(self.Sound)
	--end
	--if self.Owner:KeyReleased( IN_ATTACK ) || self.Owner:KeyReleased( IN_ATTACK2 ) then
	--	self:SetNWBool( "On", false )
	--	self.Weapon:StopSound(self.Sound)
	--	self.Weapon:EmitSound(self.StopSoond)
	--end
--end


function SWEP:PrimaryAttack( )
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .1 )
	self.Weapon:SetNextSecondaryFire( CurTime( ) + .1 )
	
if CLIENT then
	self.mdl = "models/weapons/v_physcannon.mdl"
else

 	local tr = util.GetPlayerTrace( self.Owner ) 
 	local trace = util.TraceLine( tr )
 	if (!trace.Hit) then return end
	local ent = trace.Entity
	local hitpos = trace.HitPos
	
	if ValidEntity(ent) && ent:IsNPC() && !ent:IsProp() then
		ent:SetHealth(ent:Health() - 10)
		if ent:Health() > 0 && self:Clip1() < 50 then
			self:SetClip1(self:Clip1() + 2)
		else
			ent.Igniter = self.Owner
			ent:TakeDamage(1,self.Owner)
		end
	end
	
	
	--local effectdata = EffectData()
 	--effectdata:SetOrigin( hitpos )
 	--effectdata:SetStart( self.Owner:GetShootPos() )
 	--effectdata:SetAttachment( 1 )
 	--effectdata:SetEntity( self.Owner )
 	--util.Effect( "healthbeam", effectdata )
	
end
end

function SWEP:SecondaryAttack( )
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .1 )
	self.Weapon:SetNextSecondaryFire( CurTime( ) + .1 )
	
if CLIENT then
	self.mdl = "models/weapons/v_superphyscannon.mdl"
else

 	local tr = util.GetPlayerTrace( self.Owner ) 
 	local trace = util.TraceLine( tr )
 	if (!trace.Hit) then return end
	local ent = trace.Entity
	local hitpos = trace.HitPos
	
	if ValidEntity(ent) && ent:IsPlayer() && ent:Health() < ent:MaxHealth() then
		if self:Clip1() > 0 then
			ent:AddHealth(2)
			self:SetClip1(self:Clip1() - 1)
		end
	end
end
end

function SWEP:GetViewModelPosition(pos,ang)
	for k,v in pairs(ents.FindByClass("viewmodel")) do
			v:SetModel(self.mdl)
	end
return pos,ang
end

function SWEP:Reload()
	if self:Clip1() >= 50 then
		for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(),200)) do
			if v:IsPlayer() then v:AddHealth(100) end
		end
		self:SetClip1(0)
	end
end