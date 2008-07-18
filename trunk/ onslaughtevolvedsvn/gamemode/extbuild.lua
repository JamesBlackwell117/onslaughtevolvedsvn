MODELS["models/Combine_turrets/Floor_turret.mdl"].EXTBUILD = function(this,owner,tr)
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