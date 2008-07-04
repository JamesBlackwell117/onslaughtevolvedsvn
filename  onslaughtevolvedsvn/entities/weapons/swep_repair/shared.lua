
if SERVER then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight	= 1
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom	= false
end

if CLIENT then
	SWEP.PrintName = "Wrench"
	SWEP.DrawCrosshair = true
	SWEP.DrawAmmo = false
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false
	SWEP.Slot = 1
end

local Decals = {
	MAT_CONCRETE = "Concrete",
	MAT_METAL 			= "Metal",
	MAT_DIRT 			= "Dirt",
	MAT_VENT 			= "Vent",
	MAT_GRATE 			= "Grate",
	MAT_TILE 			= "Tile",
	MAT_SLOSH 			= "Slosh",
	MAT_WOOD 			= "Wood",
	MAT_COMPUTER 		= "Computer",
	MAT_GLASS 			= "Glass",
	MAT_FLESH 			= "Flesh",
	MAT_BLOODYFLESH 	= "Bloodyflesh",
	MAT_CLIP 			= "Clip",
	MAT_ANTLION 		= "Antlion",
	MAT_ALIENFLESH 		= "Alienflesh",
	MAT_FOLIAGE 		= "Foliage",
	MAT_SAND 			= "Sand",
	MAT_PLASTIC 		= "Plastic",
}

SWEP.ViewModel	= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= ""

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "melee" )
	end
end

function SWEP:PrimaryAttack( )
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .4 )
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	self.owner:SetAnimation(ACT_MELEE_ATTACK_SWING_GESTURE)
	local trace = { }
	trace.start = self.owner:GetShootPos( )
	trace.endpos = trace.start + ( self.owner:GetAimVector( ) * 100 )
	trace.filter = self.owner
	
	local tr = util.TraceLine( trace )
	if !tr.Entity || !tr.HitNonWorld then
		self.Weapon:EmitSound( "weapons/iceaxe/iceaxe_swing1.wav" )
		return false
	end
	
	self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet3.wav")
	
	if SERVER then
		if tr.Entity:GetClass() == "sent_prop" || tr.Entity:GetClass() == "sent_ladder" || tr.Entity:GetClass() == "sent_ammo_dispenser" then
			if tr.Entity.Shealth >= tr.Entity.Mhealth then return end
			if !tr.Entity:IsOnFire() then 
				tr.Entity.Shealth = tr.Entity.Shealth + 15
			end
			if math.random(1,4) == 1 then
				tr.Entity:Extinguish()
			end
			tr.Entity:GetPhysicsObject( ):EnableMotion( false )
			tr.Entity:UpdateColour( )
		elseif tr.Entity:IsNPC() then
			self.owner:TraceHullAttack( self.owner:GetShootPos( ), self.owner:GetAimVector( ) * 120, Vector( -16, -16, -16 ), Vector( 36, 36, 36 ), 30, 2, true )
		end
		if tr.Entity:GetClass() == "npc_turret_floor" then
			if tr.Entity.Controller.Shealth >= TURRET_HEALTH then return end
			tr.Entity:SetNWInt("health", tr.Entity:GetNWInt("health") + 5)
			tr.Entity.Controller.Shealth = tr.Entity.Controller.Shealth + 5
		end
	end
	if tr.MatType == MAT_FLESH || tr.HitType == MAT_BLOODYFLESH then
		local effectdata = EffectData() 
 		effectdata:SetOrigin( tr.HitPos ) 
		util.Effect( "BloodImpact", effectdata )
	else
		local effectdata = EffectData() 
		effectdata:SetOrigin( tr.HitPos ) 
		effectdata:SetNormal( tr.HitNormal:Angle() ) 
		effectdata:SetMagnitude( 1 ) 
		effectdata:SetScale( 1 ) 
		effectdata:SetRadius( 1 ) 
		util.Effect( "Sparks", effectdata )
	end

	util.Decal( "Impact." .. ( Decals[MatType] or "Concrete" ), tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
end

function SWEP:SecondaryAttack( )

end
