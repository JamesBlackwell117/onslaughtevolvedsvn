
ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:Touch(ent)
	if ent:IsPlayer() then
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
end

function ENT:StartTouch(ent)
	if PHASE == "BUILD" then
		if ent:GetClass() == "sent_prop" || ent:GetClass() == "sent_ladder" || ent:GetClass() == "sent_ammo_dispenser" then
			if ValidEntity(ent.Owner) then
				ent.Owner:Message("You can't spawn props there!", Color(255,100,100,255))
				if ent.Shealth then
					ent.Owner:SetNetworkedInt("money", ent.Owner:GetNetworkedInt("money") + (ent.Shealth))
					ent.Shealth = 0
					ent.Owner:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
				end
			end
			ent:Dissolve()
		end
	end
	if ent:IsPlayer() then
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	end
end

function ENT:Think()

end
