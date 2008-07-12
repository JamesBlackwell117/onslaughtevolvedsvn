if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Super shotgun"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 3
end

--Swep info and other stuff
SWEP.Author	= "Conman420"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Shoot and kill"
SWEP.Instructions = "Shoot and kill"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

SWEP.LastReload = CurTime()
SWEP.Reloading = false
SWEP.AT = false

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "shotgun" )
	end
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack()) then return end
	self.Reloading = false
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.6)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.6)
	self:ShootBullet( 10, 10, 0.015 )
	self.Weapon:EmitSound(self.Primary.Sound) 
	self:TakePrimaryAmmo( 1 )
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 ) 
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_SHOTGUN)
	if SERVER then
		timer.Simple(0.2, function(self) if ValidEntity(self) then self:EmitSound("weapons/shotgun/shotgun_cock.wav") end end, self)
	end
	timer.Simple(0.3, function(self) if ValidEntity(self) then self:SendWeaponAnim(ACT_SHOTGUN_PUMP) end end, self)
	self.Owner:ViewPunch(Vector(-10,0,0))
end

function SWEP:SecondaryAttack( )
	if ( self.Weapon:Clip1() < 4 ) then
		self:Reload()
		return
	end
	self.Reloading = false
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.6)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.6)
	self:ShootBullet( 10, 30, 0.03 )
	self.Weapon:EmitSound(self.Primary.Sound) 
	self:TakePrimaryAmmo( 4 )
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 ) 
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_SHOTGUN)
	if SERVER then
		local aimvec = self.Owner:GetAimVector()
		if aimvec:Angle().p >= 15 then
			self.Owner:SetVelocity(aimvec * -600)
		end
		timer.Simple(0.15, function(self) if ValidEntity(self) then self:EmitSound("weapons/shotgun/shotgun_cock.wav") end end, self)
	end
	timer.Simple(0.2, function(self) if ValidEntity(self) then self:SendWeaponAnim(ACT_SHOTGUN_PUMP) end end, self)
	self.Owner:ViewPunch(Vector(-10,0,0))
end


function SWEP:Reload()
	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Reloading == true || self.AT == true then return false end
	if self.LastReload + 0.8 > CurTime() then return end
	self.LastReload = CurTime()
	self.Reloading = true
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	if self.AT == false then
		self.AT = true
		timer.Simple(.3,DoReload,self)
	end
	return false
end

function DoReload(swep)
	if ValidEntity(swep) then 
		if swep.Weapon:Clip1() >= swep.Primary.ClipSize || swep:Ammo1() <= 0 then swep.AT = false swep:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH ) swep:SetBodygroup(1,1) return end
		if swep.Reloading == true then
			swep:SetBodygroup(1,0)
			swep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
			swep:SendWeaponAnim( ACT_VM_RELOAD )
			swep.Owner:RemoveAmmo( 1, swep.Weapon:GetPrimaryAmmoType() )
			swep.Weapon:SetClip1( swep.Weapon:Clip1() + 1 )
			timer.Simple(.4,DoReload,swep)
		else
			swep.AT = false
			return
		end
	end
end
