MODELS["models/Combine_turrets/Floor_turret.mdl"].EXTBUILD = function(this,owner,tr)
	this:SetPos(tr.HitPos)
	this:SetKeyValue("spawnflags","512")
	this:GetPhysicsObject():EnableMotion(false)
	this:SetOwner(owner)
	this:SetNetworkedEntity("owner",owner)
	local trtctrl = ents.Create("sent_turretcontroller") --this entity controls the turrets health and kills it etc.
	trtctrl:SetPos(this:GetPos())
	trtctrl:SetParent(this)
	trtctrl:Spawn()
	trtctrl:Activate()
	trtctrl:SetOwner(owner)
	this.Controller = trtctrl
	this:SetNWInt("health",trtctrl.Shealth)
	owner:EmitSound( "npc/scanner/scanner_siren1.wav" )
	owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_siren1.wav" )]] )
end

MODELS["models/props_combine/combine_mine01.mdl"].EXTBUILD = function(this,owner,tr)
	local ang = tr.HitNormal:Angle()
	local ang2 = Angle(ang.p + 90, ang.y, ang.r)
	this:SetPos(tr.HitPos)
	this:SetAngles(ang2)
	this:SetOwner(owner)
	
	owner:EmitSound( "npc/scanner/scanner_siren1.wav" )
	owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_siren1.wav" )]] )
end


MODELS["models/props_combine/health_charger001.mdl"].EXTBUILD = function(this,owner,tr)
	if MODELS["models/props_combine/health_charger001.mdl"].COST*1.05 > owner:GetNetworkedInt( "money") then
		owner:Message("Insufficient funds!", Color(255,100,100,255))
		return false
	end

	if tr.Entity then
		if tr.Entity:IsPlayer() || tr.Entity:GetClass() == "sent_dispenser" || tr.Entity:GetClass() == "npc_turret_floor" || tr.Entity:GetClass() == "sent_turretcontroller" then return end
	end
	
	local ang = tr.HitNormal:Angle()
	if ang.pitch < 10 || ang.pitch > 350 then
		local disp = ents.Create("sent_dispenser")
		disp:SetPos(tr.HitPos)
		disp:SetAngles(ang)
		disp.Owner = owner
		disp:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		disp:Spawn()
		disp:Activate()
		disp.Class = owner:GetNWInt("class")
		disp.Type = PHASE
		if tr.Entity && tr.HitNonWorld then
			disp:SetParent(tr.Entity)
		end
		disp:GetPhysicsObject():EnableMotion(false)
		owner:Message((- MODELS["models/props_combine/health_charger001.mdl"].COST*1.05).." [Dispenser Spawned]",Color(100,255,100,255))
		owner:SetNetworkedInt( "money", owner:GetNetworkedInt( "money" ) - MODELS["models/props_combine/health_charger001.mdl"].COST*1.05 )
		owner:EmitSound( "npc/scanner/scanner_electric1.wav" )
		owner:SendLua( [[ surface.PlaySound( "npc/scanner/scanner_electric1.wav" ) ]] )
	else
		owner:Message("Must be spawned on a vertical wall!")
	end
end


