include('shared.lua')
 
function ENT:Draw()             
	self.Entity:DrawModel()

end

function ENT:Initialize()
	local ED = EffectData( )
	ED:SetEntity(self)
	ED:SetOrigin(self:GetPos())
	util.Effect( "spawnpoint", ED )
end
 