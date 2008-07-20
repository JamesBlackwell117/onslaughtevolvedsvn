
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
SWEP.WorldModel	= "models/weapons/w_superphyscannon.mdl"

SWEP.Primary.ClipSize = 900
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"

SWEP.Sound = Sound("items/suitcharge1.wav")
SWEP.SuckSound = Sound("npc/vort/attack_charge.wav")
SWEP.StopSoond = Sound("vehicles/tank_turret_stop1.wav")

SWEP.Secondary.ClipSize	= 900
SWEP.Secondary.DefaultClip = 100
SWEP.Secondary.Automatic =true
SWEP.Secondary.Ammo	= "SMG1"

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "smg" )
	end
end

function SWEP:Holster( )
	self:SetNWBool( "On", false )
	return true
end
 
function SWEP:Think( )
	if self.Owner:KeyPressed( IN_ATTACK ) || self.Owner:KeyReleased( IN_ATTACK2 ) then
		if ( !self:CanPrimaryAttack() ) then return end
		self:SetNWBool( "On", true )
		self.Weapon:EmitSound(self.Sound)
	end
	if self.Owner:KeyReleased( IN_ATTACK ) || self.Owner:KeyReleased( IN_ATTACK2 ) then
		self:SetNWBool( "On", false )
		self.Weapon:StopSound(self.Sound)
		self.Weapon:EmitSound(self.StopSoond)
	end
end

function SWEP:PrimaryAttack( )
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .02 )
 	local tr = util.GetPlayerTrace( self.Owner ) 
 	local trace = util.TraceLine( tr )
 	if (!trace.Hit) then return end
	local ent = trace.Entity
	local hitpos = trace.HitPos
	if SERVER then
		if !ent || (!ent:IsNPC() && !ent:IsPlayer()) then
			self:SetNWEntity("target", NULL)
		else
			self:SetNWEntity("target", ent)
			--print("ent ".. tostring(self:GetNWEntity("target")))
		end
	end
	
	/*
	local effectdata = EffectData()
 	effectdata:SetOrigin( hitpos )
 	effectdata:SetStart( self.Owner:GetShootPos() )
 	effectdata:SetAttachment( 1 )
 	effectdata:SetEntity( self.Owner )
 	util.Effect( "healthbeam", effectdata )
	*/
end

function SWEP:SecondaryAttack( )

end
