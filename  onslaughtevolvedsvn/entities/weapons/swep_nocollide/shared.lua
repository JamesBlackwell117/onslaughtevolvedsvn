if (SERVER) then
	AddCSLuaFile( "shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Nocollide SWEP"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 1
end

SWEP.ViewModel	= "models/weapons/v_pistol.mdl"
SWEP.WorldModel	= "models/weapons/w_pistol.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

function SWEP:Initialize( )

end

function SWEP:Reload( )
end

function SWEP:PrimaryAttack( )
	if CLIENT then return end
	
	local tr = self.owner:GetEyeTrace( )
	
	if not tr.Hit or not tr.HitNonWorld or not ValidEntity( tr.Entity ) or tr.Entity:GetClass( ) != "sent_prop" and tr.Entity:GetClass( ) != "sent_ladder" then
		return
	end
	
	if ValidEntity( self.FirstEntity ) and self.FirstBone then
		if self.FirstEntity == tr.Entity then return end
		constraint.NoCollide( tr.Entity, self.FirstEntity, tr.PhysicsBone, self.FirstBone )
		tr.Entity:SetColor(0,0,255,255)
		timer.Simple(0.2,self.FirstEntity.UpdateColour, self.FirstEntity)
		timer.Simple( 0.2, tr.Entity.UpdateColour, tr.Entity )
		self.FirstEntity = nil
		self.FirstBone = nil
	else
		self.FirstEntity = tr.Entity
		tr.Entity:SetColor(0,0,255,255)
		self.FirstBone = tr.PhysicsBone
		timer.Simple(2,self.FirstEntity.UpdateColour, self.FirstEntity)
	end
	
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 ) 
end

function SWEP:Holster( wep )
	self.FirstEntity = nil
	self.FirstBone = nil
	return true
end

function SWEP:SecondaryAttack( )
	return
end
