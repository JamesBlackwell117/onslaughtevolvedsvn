AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.LastUse = CurTime()
ENT.AutomaticFrameAdvance = true
ENT.Shealth = 300
ENT.Mhealth = 300
ENT.LastTouch = 0

function ENT:Initialize()   
	self.Entity:SetModel("models/Items/ammocrate_smg1.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   
	self.Entity:SetSolid( SOLID_VPHYSICS )      
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableMotion(false)
	end
end

function ENT:Think()
end

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

function ENT:UpdateColour()
	if self.Shealth > self.Mhealth then
		self.Shealth = self.Mhealth
	end
	local col = (self.Shealth / self.Mhealth) * 255
	self.Entity:SetColor(col, col, col, 255)
end
