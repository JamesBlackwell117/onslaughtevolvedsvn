AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.LastUse = CurTime()
ENT.AutomaticFrameAdvance = true
ENT.LastTouch = 0

function ENT:Close()
	local sequence = self.Entity:LookupSequence("Idle")
	self.Entity:SetSequence(sequence)
end

function ENT:Use(act, cal)
	if !act:IsPlayer() then return end
	if PHASE == "BUILD" then return end
	if self.LastUse + 2 > CurTime() then return end
	local sequence = self.Entity:LookupSequence("Open")
	self.Entity:SetSequence(sequence)
	timer.Simple(1.5,self.Close,self)
	act:Ammo()
	self.Entity:EmitSound("items/ammocrate_open.wav",90,100)
	self.LastUse = CurTime()
end

