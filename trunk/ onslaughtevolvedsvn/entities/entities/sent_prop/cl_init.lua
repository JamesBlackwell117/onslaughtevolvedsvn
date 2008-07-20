include('shared.lua')

function ENT:Draw()             
	self.Entity:DrawModel()
end

function Owner(um)
	local owner = um:ReadEntity()
	local ent = um:ReadEntity()
	if ValidEntity(ent) then
		ent.Owner = owner
	end
end

usermessage.Hook("owner", Owner)
