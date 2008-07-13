AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.LastUse = CurTime()
ENT.Healing = 0

function ENT:Initialize()   
	self.Entity:SetModel("models/props_combine/health_charger001.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   
	self.Entity:SetSolid( SOLID_VPHYSICS )      
	
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableMotion(false)
	end
end


function ENT:Use(act, cal)
	if !act:IsPlayer() then return end
	if self.LastUse + 0.08 < CurTime() then
	if act:Health() >= act:GetMaxHealth() then return end
		self.Entity:EmitSound("items/medshot4.wav",50,100)
		act:AddHealth(math.Round(act:GetMaxHealth()/DISP_RATE))
		if act:Health() > act:GetMaxHealth() then act:SetHealth(act:GetMaxHealth()) end
		if PHASE == "BATTLE" then
			self.Healing = self.Healing + 1
			if (self.Healing / 50) == math.Round(self.Healing / 50) && self.Healing > 49 then
				if self.Class == 3 then
					self.Owner:Message("+100 [Dispenser healing]", Color(100,255,100,255))
					self.Owner:SetNWInt("money",self.Owner:GetNWInt("money") + 100)
				end
			end
		end
		timer.Simple(2, act.Extinguish, act)
		self.LastUse = CurTime()
	end
end