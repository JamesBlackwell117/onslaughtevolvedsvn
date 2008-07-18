MODELS["models/Combine_turrets/Floor_turret.mdl"].EXTBUILD = function(this,owner)
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
