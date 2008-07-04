if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Crossbow"
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
SWEP.ViewModel	= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel	= "models/weapons/w_crossbow.mdl"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "xbowbolt"
SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

SWEP.LastReload = CurTime()

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "crossbow" )
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)
	if SERVER then
		local bolt = ents.Create("prop_dynamic")
		local ang = self.Owner:GetAimVector()
		local pos = self.Owner:GetShootPos()
		bolt:SetPos(pos + (ang * 10))
		bolt:SetAngles(ang:Angle())
		bolt:SetModel("models/crossbow_bolt.mdl")
		bolt:SetVelocity(ang * 100)
		bolt:Spawn()
		bolt:Activate()
	end
	self.Weapon:EmitSound(self.Primary.Sound) 
	self:TakePrimaryAmmo( 1 )
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 ) 
	self.Owner:ViewPunch(Vector(-10,0,0))
end

function SWEP:SecondaryAttack( )
	if ( self.Weapon:Clip1() < 3 ) then
	 	self.Weapon:EmitSound( "Weapon_Pistol.Empty" ) 
 		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 ) 
		return
	end
	self.Weapon:SetNextSecondaryFire(CurTime() + 1.5)
	self:ShootBullet( 7, 40, 0.3 )
	self.Weapon:EmitSound(self.Primary.Sound) 
	self:TakePrimaryAmmo( 3 )
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
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.7)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
	timer.Simple(0.5,function(self) if ValidEntity(self) then self:DefaultReload(ACT_SHOTGUN_RELOAD_START) end end, self )
	timer.Simple(0.5,function(self) if ValidEntity(self) then self:DefaultReload(ACT_SHOTGUN_RELOAD_FINISH) end end, self )
	
end
