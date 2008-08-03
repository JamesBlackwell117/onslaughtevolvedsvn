if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Combine Railgun"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 4
end

--Swep info and other stuff
SWEP.Author	= "Model by Jaanus"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Shoot and kill"
SWEP.Instructions = "Shoot and kill"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel				= "models/weapons/v_combinesniper_e2.mdl"
SWEP.WorldModel				= "models/weapons/w_combinesniper_e2.mdl"
SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Sound = Sound("weapons/physcannon/energy_sing_explosion2.wav")
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"
SWEP.Zoomed = false

SWEP.LastReload = CurTime()

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "ar2" )
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:EmitSound(self.Primary.Sound) 
	self.Weapon:EmitSound(Sound("weapons/physcannon/energy_bounce1.wav")) 
	self.Weapon:EmitSound(Sound("weapons/physcannon/physcannon_charge.wav")) 
	if SERVER then
		self:TakePrimaryAmmo(1)
		local iter = 0
		local tr = util.GetPlayerTrace( self.Owner ) 
		tr.filter = ents.FindByClass("sent*")
 		local trace = util.TraceLine( tr )
 		if (!trace.Hit) then return end
		local ent = trace.Entity
		while ent && iter < 10 do 
			if ent:IsNPC() then
				ent.Igniter = self.Owner
				ent:NPCDiss()
			end
 			trace = util.TraceLine( tr )
 			table.insert(tr.filter,ent)
 			if (!trace.Hit) then return end
			ent = trace.Entity
			iter = iter + 1
		end
	end
end

function SWEP:SecondaryAttack( )
	if !self.Zoomed then
		self.Owner:SetFOV( 20, 0 )
		self.Zoomed = true	
	else
		self.Zoomed = false
		self.Owner:SetFOV( 90, 0 ) 
	end
end

--function SWEP:GetViewModelPosition(pos,ang)
--	ang = Angle(-ang.p,ang.y+180,ang.r)
--	local vec = Vector(-30,7.5,-6.5)
--	vec:Rotate(ang)
--	pos = pos+vec
--	return pos,ang
--end

