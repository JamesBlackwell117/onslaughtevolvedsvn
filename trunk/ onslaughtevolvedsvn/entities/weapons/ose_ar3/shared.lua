if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Ar3"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

--Swep info and other stuff
SWEP.Author	= "Conman420"
SWEP.Contact = "FP thread"
SWEP.Purpose = "AR3"
SWEP.Instructions = "Ar2? Nah I used ar3s"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.HoldType			= "ar2"
SWEP.ViewModel	= "models/weapons/v_irifle.mdl"
SWEP.WorldModel	= "models/weapons/w_irifle.mdl"
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.Secondary.ClipSize	= 3
SWEP.Secondary.DefaultClip = 2
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "AR2AltFire"
SWEP.LastReload = CurTime()
SWEP.Ball = nil

function SWEP:Initialize( )
end

function SWEP:Deploy()
end

function SWEP:Holster(wep)

	return true
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
 	if ( !self:CanPrimaryAttack() ) then return end
	if SERVER then
		self.Weapon:SetNextPrimaryFire( CurTime( ) + .07 )
	end
	self.Weapon:EmitSound("Weapon_AR2.Single")
	self:Shoot(20,2,0.05)
	self:TakePrimaryAmmo(1)
	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )
end

function SWEP:Shoot( damage, num_bullets, aimcone )

	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos() // Source
	bullet.Dir = self.Owner:GetAimVector() // Dir of bullet
	bullet.Spread = Vector( aimcone, aimcone, 0 ) // Aim Cone
	bullet.Tracer = 5 // Show a tracer on every x bullets
	bullet.TracerName = "AR2Tracer"
	bullet.Force = 3 // Amount of force to give to phys objects
	bullet.Damage = damage

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end

function SWEP:SecondaryAttack( )
	if ( !self:CanSecondaryAttack() ) then return end
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self.Weapon:EmitSound( "weapons/irifle/irifle_fire2.wav" )
	if SERVER then
		self.Weapon:SetNextSecondaryFire(CurTime() + 3)
		self.Ball = ents.Create("point_combine_ball_launcher")
		self.Ball:SetKeyValue("ballcount","99999")
		self.Ball:SetKeyValue("ballradius","20.0")
		self.Ball:SetKeyValue("balltype","2")
		self.Ball:SetKeyValue("maxballbounces","3")
		self.Ball:SetKeyValue("maxspeed","900")
		self.Ball:SetKeyValue("minspeed","700")
		self.Ball:SetKeyValue("spawnflags","4096")
		local angs = self.Owner:GetAimVector():Angle()
		self.Ball:SetKeyValue("angles",angs.p..angs.y..angs.r)
		self.Ball:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50)
		self.Ball:SetAngles(self.Owner:GetAimVector():Angle())
		self.Ball:SetParent(self.Owner)
		self.Ball:Spawn()
		self.Ball:Activate()
		self.Ball:Fire("LaunchBall",0,0.1)
		self.Ball:Fire("kill",0,0.2)
		self:TakeSecondaryAmmo(1)
	end
end

