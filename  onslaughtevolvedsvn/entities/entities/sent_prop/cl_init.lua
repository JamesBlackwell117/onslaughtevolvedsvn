include('shared.lua')

function ENT:Draw()             
	self.Entity:DrawModel()
end

function Owner(um)
	local owner = um:ReadEntity()
	local ent = um:ReadEntity()
	ent.Owner = owner
end

usermessage.Hook("owner", Owner)
