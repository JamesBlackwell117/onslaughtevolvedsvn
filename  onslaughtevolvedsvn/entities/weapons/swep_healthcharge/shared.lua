
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

--SWEP.Sound = Sound("items/suitcharge1.wav")
--SWEP.SuckSound = Sound("npc/vort/attack_charge.wav")
--SWEP.StopSoond = Sound("vehicles/tank_turret_stop1.wav")

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "physgun" )
	end
end
 
function SWEP:Think( )
	if self.Owner:KeyPressed( IN_ATTACK ) then
		self:SetNWBool( "On", true )
		--self.Weapon:EmitSound(self.Sound)
	end
	if self.Owner:KeyPressed( IN_ATTACK2 ) then
		self:SetNWBool( "On2", true )
		print("k")
		--self.Weapon:EmitSound(self.Sound)
	end
	if self.Owner:KeyReleased( IN_ATTACK ) || self.Owner:KeyReleased( IN_ATTACK2 ) then
		self:SetNWBool( "On", false )
		self:SetNWBool( "On2", false )
		--self.Weapon:StopSound(self.Sound)
		--self.Weapon:EmitSound(self.StopSoond)
	end
end


function SWEP:PrimaryAttack( )
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
			if ent:Health() > 0 && self:Clip1() < 25 then
				self:SetClip1(self:Clip1() + 1)
			else
				ent:TakeDamage(1,self.Owner, self.Owner)
			end
		end	
	end
	local effectdata = EffectData()
 	effectdata:SetStart( self.Owner:GetShootPos() )
 	effectdata:SetAttachment( 1 )
 	effectdata:SetEntity( self.Owner )
 	util.Effect( "support_suckbeam", effectdata )
end

function SWEP:SecondaryAttack( )
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
	
	local effectdata = EffectData()
 	effectdata:SetOrigin( hitpos )
 	effectdata:SetStart( self.Owner:GetShootPos() )
 	effectdata:SetAttachment( 1 )
 	effectdata:SetEntity( self.Owner )
 	util.Effect( "support_healbeam", effectdata )
end

function SWEP:GetViewModelPosition(pos,ang)
	for k,v in pairs(ents.FindByClass("viewmodel")) do
			v:SetModel(self.mdl)
	end
	return pos,ang
end

function SWEP:Reload()
	if self:Clip1() >= 25 then
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(),200)) do
				if v:IsPlayer() then v:AddHealth(50) end
			end
		end
			local effectdata = EffectData()
			effectdata:SetOrigin( self.Owner:GetPos() )
			effectdata:SetEntity( self.Owner )
			util.Effect( "support_healthexplode", effectdata )
			self:SetClip1(0)
	end
end
