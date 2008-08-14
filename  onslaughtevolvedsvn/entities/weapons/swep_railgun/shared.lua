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
SWEP.Spawnable = false
SWEP.ViewModel = "models/weapons/v_combinesniper_e2.mdl"
SWEP.WorldModel	= "models/weapons/w_combinesniper_e2.mdl"
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

SWEP.ScopeScale = 0.5


function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "ar2" )
	else
		-- We need to get these so we can scale everything to the player's current resolution.
		local iScreenWidth = surface.ScreenWidth()
		local iScreenHeight = surface.ScreenHeight()

		-- The following code is only slightly riped off from Night Eagle
		-- These tables are used to draw things like scopes and crosshairs to the HUD.
		self.ScopeTable = {}
		self.ScopeTable.l = iScreenHeight*self.ScopeScale
		self.ScopeTable.x1 = 0.5*(iScreenWidth + self.ScopeTable.l)
		self.ScopeTable.y1 = 0.5*(iScreenHeight - self.ScopeTable.l)
		self.ScopeTable.x2 = self.ScopeTable.x1
		self.ScopeTable.y2 = 0.5*(iScreenHeight + self.ScopeTable.l)
		self.ScopeTable.x3 = 0.5*(iScreenWidth - self.ScopeTable.l)
		self.ScopeTable.y3 = self.ScopeTable.y2
		self.ScopeTable.x4 = self.ScopeTable.x3
		self.ScopeTable.y4 = self.ScopeTable.y1

		self.ParaScopeTable = {}
		self.ParaScopeTable.x = 0.5*iScreenWidth - self.ScopeTable.l
		self.ParaScopeTable.y = 0.5*iScreenHeight - self.ScopeTable.l
		self.ParaScopeTable.w = 2*self.ScopeTable.l
		self.ParaScopeTable.h = 2*self.ScopeTable.l

		self.ScopeTable.l = (iScreenHeight + 1)*self.ScopeScale -- I don't know why this works, but it does.

		self.QuadTable = {}
		self.QuadTable.x1 = 0
		self.QuadTable.y1 = 0
		self.QuadTable.w1 = iScreenWidth
		self.QuadTable.h1 = 0.5*iScreenHeight - self.ScopeTable.l
		self.QuadTable.x2 = 0
		self.QuadTable.y2 = 0.5*iScreenHeight + self.ScopeTable.l
		self.QuadTable.w2 = self.QuadTable.w1
		self.QuadTable.h2 = self.QuadTable.h1
		self.QuadTable.x3 = 0
		self.QuadTable.y3 = 0
		self.QuadTable.w3 = 0.5*iScreenWidth - self.ScopeTable.l
		self.QuadTable.h3 = iScreenHeight
		self.QuadTable.x4 = 0.5*iScreenWidth + self.ScopeTable.l
		self.QuadTable.y4 = 0
		self.QuadTable.w4 = self.QuadTable.w3
		self.QuadTable.h4 = self.QuadTable.h3

		self.LensTable = {}
		self.LensTable.x = self.QuadTable.w3
		self.LensTable.y = self.QuadTable.h1
		self.LensTable.w = 2*self.ScopeTable.l
		self.LensTable.h = 2*self.ScopeTable.l

		self.CrossHairTable = {}
		self.CrossHairTable.x11 = 0
		self.CrossHairTable.y11 = 0.5*iScreenHeight
		self.CrossHairTable.x12 = iScreenWidth
		self.CrossHairTable.y12 = self.CrossHairTable.y11
		self.CrossHairTable.x21 = 0.5*iScreenWidth
		self.CrossHairTable.y21 = 0
		self.CrossHairTable.x22 = 0.5*iScreenWidth
		self.CrossHairTable.y22 = iScreenHeight
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:ViewModelDrawn()
	if CLIENT then
		local Laser = Material( "cable/blue_elec" )
		local muz = Material("effects/blueblackflash")
		local ViewModel = LocalPlayer():GetViewModel()
		if !ViewModel:IsValid() then return end
 		local spos = ViewModel:GetAttachment(1).Pos + (self.Owner:GetAimVector() * 25)

		if self:GetNWBool("on") == true then
			local tr = util.GetPlayerTrace( self.Owner )
			tr.filter = ents.GetAll()
			local trace = util.TraceLine( tr )
			if (!trace.Hit) then return end
			render.SetMaterial( Laser )
			render.DrawBeam( spos, trace.HitPos, 15, 0, 0, Color( 255, 255, 255, 255 ) )
			render.SetMaterial( muz )
			render.DrawSprite(spos, 10, 10, color_white)
		end
	end
end

function SWEP:DrawWorldModel()
	self.Weapon:DrawModel()
	if CLIENT then
		local Laser = Material( "cable/blue_elec" )
		local muz = Material("effects/blueblackflash")
		local spos = self.Weapon:GetAttachment(1).Pos

		if self:GetNWBool("on") == true then
			local tr = util.GetPlayerTrace( self.Owner )
			tr.filter = ents.GetAll()
			local trace = util.TraceLine( tr )
			if (!trace.Hit) then return end
			render.SetMaterial( Laser )
			render.DrawBeam( spos, trace.HitPos, 15, 0, 0, Color( 255, 255, 255, 255 ) )
			render.SetMaterial( muz )
			render.DrawSprite(spos, 10, 10, color_white)
		end
	end
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:EmitSound(self.Primary.Sound)
	self.Weapon:EmitSound(Sound("weapons/physcannon/energy_bounce1.wav"))
	self.Weapon:EmitSound(Sound("weapons/physcannon/physcannon_charge.wav"))
	local hitpos = nil
	self:SetNWBool("on", true)
	timer.Simple(0.1, self.SetNWBool, self, "on", false)
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
		if self:Clip1() == 0 then self:SetNWBool("zoom", false) self.Owner:SetFOV( 90, 0 ) self:Reload() end
	end
end

function SWEP:SecondaryAttack( )
	if !self:GetNWBool("zoom") then
		self.Owner:SetFOV( 20, 0 )
		self:SetNWBool("zoom", true)
	else
		self:SetNWBool("zoom", false)
		self.Owner:SetFOV( 90, 0 )
	end
end

function SWEP:DrawHUD()
	if self:GetNWBool("zoom") then
		surface.SetDrawColor(0, 0, 0, 220)
		surface.SetTexture(surface.GetTextureID("jaanus/ep2snip_parascope"))
		surface.DrawTexturedRect(self.ParaScopeTable.x,self.ParaScopeTable.y,self.ParaScopeTable.w,self.ParaScopeTable.h)
		surface.SetDrawColor(20,20,20,40)
		surface.SetTexture(surface.GetTextureID("overlays/scope_lens"))
		surface.DrawTexturedRect(self.LensTable.x,self.LensTable.y,self.LensTable.w,self.LensTable.h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.SetTexture(surface.GetTextureID("jaanus/sniper_corner"))
		surface.DrawTexturedRectRotated(self.ScopeTable.x1,self.ScopeTable.y1,self.ScopeTable.l,self.ScopeTable.l,270)
		surface.DrawTexturedRectRotated(self.ScopeTable.x2,self.ScopeTable.y2,self.ScopeTable.l,self.ScopeTable.l,180)
		surface.DrawTexturedRectRotated(self.ScopeTable.x3,self.ScopeTable.y3,self.ScopeTable.l,self.ScopeTable.l,90)
		surface.DrawTexturedRectRotated(self.ScopeTable.x4,self.ScopeTable.y4,self.ScopeTable.l,self.ScopeTable.l,0)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(self.QuadTable.x1,self.QuadTable.y1,self.QuadTable.w1,self.QuadTable.h1)
		surface.DrawRect(self.QuadTable.x2,self.QuadTable.y2,self.QuadTable.w2,self.QuadTable.h2)
		surface.DrawRect(self.QuadTable.x3,self.QuadTable.y3,self.QuadTable.w3,self.QuadTable.h3)
		surface.DrawRect(self.QuadTable.x4,self.QuadTable.y4,self.QuadTable.w4,self.QuadTable.h4)
		local rotatick = CurTime()*90/5
		surface.SetTexture(surface.GetTextureID("jaanus/rotatingthing"))
		surface.SetDrawColor(0,0,0,120)
		surface.DrawTexturedRectRotated(ScrW()/2, ScrH()/2,self.LensTable.w * 1.2, self.LensTable.h * 1.2, rotatick)
	end
end