if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Mine Spawner"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 5
end

--Swep info and other stuff
SWEP.Author	= "Conman420"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Makes freindly mines"
SWEP.Instructions = "look and spawn"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_hands.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "SMG1"
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"
SWEP.LastReload = CurTime()

function SWEP:Initialize( )
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end
	if ( !self:CanPrimaryAttack() ) then return end 
	self:TakePrimaryAmmo(1)
	local trace = {}
	trace.start = self.owner:GetShootPos()
	trace.endpos = trace.start + (self.owner:GetAimVector() * 150)
	trace.filter = self.owner
	local trc = util.TraceLine(trace)
	if !trc.Hit then return end
	if !trc.Entity then return end
	local class = trc.Entity:GetClass()
	if class != "sent_prop" && trc.HitNonWorld then return end
	local mine = ents.Create("ose_mines")
	mine:SetPos(trc.HitPos)
	local ang = trc.HitNormal:Angle()
	local ang2 = Angle(ang.p + 90, ang.y, ang.r)
	mine:SetAngles(ang2)
	mine.owner = self.owner
	mine:Spawn()
	mine:Activate()
	
	self.owner:EmitSound( "npc/scanner/scanner_siren1.wav" )
	self.owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_siren1.wav" )]] )
	self.Weapon:SetNextPrimaryFire(CurTime() + 3)
end
