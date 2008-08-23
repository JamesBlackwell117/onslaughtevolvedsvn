function Emeta:Dissolve()
	if ( ValidEntity( self) && !self.Dissolving ) then
		local dissolve = ents.Create( "env_entity_dissolver" )
		dissolve:SetPos( self:GetPos() )

		self:SetName( tostring( self ) )
		dissolve:SetKeyValue( "target", self:GetName() )

		dissolve:SetKeyValue( "dissolvetype", "3" )
		dissolve:Spawn()
		dissolve:Fire( "Dissolve", "", 0 )
		dissolve:Fire( "kill", "", 1 )

		dissolve:EmitSound(Sound("weapons/physcannon/energy_sing_flyby1.wav"), 500,100)
		self:Fire( "sethealth", "0", 0 )
		self.Dissolving = true
	end
end

function Emeta:IsZombie()
	if ValidEntity( self ) then
		if table.HasValue(Zombies, self:GetClass()) then return true end
	end
	return false
end

function Emeta:NPCDiss()
	if ( ValidEntity( self) && !self.Dissolving ) then
		local dissolve = ents.Create( "env_entity_dissolver" )
		dissolve:SetPos( self:GetPos() )

		self:SetName( tostring( self ) )
		dissolve:SetKeyValue( "target", self:GetName() )

		dissolve:SetKeyValue( "dissolvetype", "0" )
		dissolve:SetKeyValue( "magnitude", "3000" )
		dissolve:Spawn()
		dissolve:Fire( "Dissolve", "", 0 )
		dissolve:Fire( "kill", "", 1 )

		dissolve:EmitSound(Sound("weapons/physcannon/energy_sing_flyby1.wav"), 500,100)
		self:Fire( "sethealth", "0", 0 )
		self.Dissolving = true
	end
end

function Emeta:GetRealOwner()
	local owner
	if ValidEntity(self.Owner) then owner = self.Owner elseif ValidEntity(self:GetOwner()) then owner = self:GetOwner() end
	return owner
end

function Emeta:CheckValidOwnership(removenpcs)
	removenpcs = removenpcs or false
	local owner = self:GetRealOwner()
	local model = self:GetModel()
	if owner then
		if MODELS[model] && MODELS[model].PLYCLASS && owner:GetNWInt("class") != MODELS[model].PLYCLASS then
			self:PropRemove(true)
		end
		return
	elseif removenpcs == true then
	self:PropRemove()
	end
end

function Emeta:IsProp()
	if self.Spawnable == true || self:GetClass() == "npc_turret_floor" || self:GetClass() == "npc_turret_ceiling" then return true end return false
end

function AllChat(msg)
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(msg)
	end
end

function Pmeta:Poison(npc)
	if self.Poisoned == true then
		self.Poisonend = self.Poisonend + math.Rand(10,15)
	else
		self:EmitSound("HL1/fvox/blood_toxins.wav", 150,100)
		self:SetColor(100,150,100,255)
		self.Poisoned = true
		self.Poisoner = npc
		self.Poisonend = CurTime() + math.random(2,30)
		self:PoisonThink()
	end
end

function Pmeta:PoisonThink()
	if !self.Poisoned || CurTime() > self.Poisonend then --stop poisoning
		self:EmitSound("HL1/fvox/antitoxin_shot.wav", 150,100)
		self:SetColor(255,255,255,255)
		self:SetNWBool("pois", false)
		self.Poisoned = false
		return false
	end
	self:SetNWBool("pois", true)
	self:TakeDamage(math.random(2,6), self.Poisoner, self.Poisoner)
	timer.Simple(math.Rand(0.5,1.5),self.PoisonThink,self)
end

function Pmeta:SaveProfile()
	self:ChatPrint("Your kill data has been saved!")
	local name = string.Replace( self:SteamID(), ":", "." )
	local t = {id = self:SteamID(), kills = self:GetNWInt("kills"), rank = self:GetNWInt("rank")}
	file.Write( "onslaught_profiles/"..name..".txt", util.TableToKeyValues(t) )
end

-------------------------------------------------------------------------------
--PropOp
--Check to see if a player can do an operation on a prop)
-------------------------------------------------------------------------------

function Emeta:PropOp(ply,noadmin)
	if !self:IsProp() then return false end
	local owner = self:GetRealOwner()
	if ValidEntity(owner) and owner != ply && (!ply:IsAdmin() || noadmin) then
		if !noadmin then
			ply:PrintMessage( HUD_PRINTCENTER, "This is owned by " .. self:GetRealOwner():Nick() )
			ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		end
		return false
	end
	return true
end

function Emeta:PropRemove(sell,silent)
	if self.Dissolving then return 0 end
	sell = sell or false
	silent = silent or false
	local cost
	if sell then
		local owner = self:GetRealOwner()
		local model = self:GetModel()

		if owner then
			if MODELS[model] && MODELS[model].COST then
				cost = MODELS[model].COST
			elseif self.SMH && self.SMH > 0 then
				cost = self.SMH
			end
		end
		if cost then
			if !silent then
				if MODELS[model] && MODELS[model].NAME then
					owner:Money(cost,"+"..math.Round(cost).." [Deleted "..MODELS[model].NAME.."]")
				else
					owner:Money(cost,"+"..math.Round(cost).." [Deleted Item]")
				end
			end
		end
	end
	if self:IsNPC() then self:Remove() else self:Dissolve() end
	return cost or 0
end

function Pmeta:Money(amt,msg,col)
	local suffix = " "
	local money = self:GetNWInt("money")
	if amt < 0 then
		if money + amt < 0 then
			self:Message("Insufficient Funds!", Color(255,100,100,255))
			self:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
			return false
		end
		if !col then col = Color(255,100,100,255) end
	else
		suffix = "+"
		if !col then col = Color(100,255,100,255) end
	end

	self:SetNetworkedInt("money",money + amt)
	if msg then self:Message(msg,col) end

	return true
end

function Pmeta:IsStuck()
		local trc = {}
		trc.start = self:LocalToWorld(self:OBBMaxs())
		trc.endpos = self:LocalToWorld(self:OBBMins())
		trc.filter = self
		trc = util.TraceLine( trc )
		if trc.Hit then
			self.NextSpawn = CurTime() + 5
			self:Kill()
			return true
		end
	return false
end

function Pmeta:GetDefaultClass()
	local dclass = self:GetInfo("ose_defaultclass")
	if dclass then
		for k,v in pairs(Classes) do
			if v.NAME == dclass then
				self:SetNetworkedInt( "class", k)
				break
			end
		end
	end
end

function Pmeta:GetClass()
	return Classes[self:GetNWInt("class")]
end

function Pmeta:GetRank()
	local rank = self:GetNWInt("rank")
	return rank
end

function Pmeta:Message(txt,col,msg)
	local colour = col or Color(255,255,255,255)
	umsg.Start("ose_msg", self)
		umsg.String(tostring(txt))
		umsg.String(colour.r.." "..colour.g.." "..colour.b.." "..colour.a)
		umsg.Bool(msg)
	umsg.End()
end

function Pmeta:MdlMessage(mdl,txt,col,msg)
	local colour = col or Color(255,255,255,255)
	umsg.Start("ose_mdl_msg", self)
		umsg.String(tostring(mdl))
		umsg.String(tostring(txt))
		umsg.String(colour.r.." "..colour.g.." "..colour.b.." "..colour.a)
		umsg.Bool(msg)
	umsg.End()
end

function Pmeta:AddHealth(health)
	if self:Health() + health > self:GetMaxHealth() then
		self:SetHealth(self:GetMaxHealth())
		return
	end
	self:SetHealth(self:Health() + health)
end

function Pmeta:Taunt()
	self.LastTaunt = self.LastTaunt or CurTime()
	if math.random(1,2) == 2 && self.LastTaunt + 20 <= CurTime() then
		local class = self:GetNWInt("class")
		local taunts = TAUNTS[class]
		self:EmitSound(taunts[math.random(1,#taunts)],140,100)
		self.LastTaunt = CurTime()
	end
end

function isnumber( var )
	if var == nil then
		return false
	end
	if type( var ) == "string" then
		return tostring( tonumber( var ) ) == var
	elseif type( var ) == "number" then
		return true
	end
	return false
end

function UpdateTime()
	----------------------------------------------------------------
	umsg.Start("updatebattletime")
		umsg.Long(BATTLETIME)
	umsg.End()
	----------------------------------------------------------------
	umsg.Start("updatebuildtime")
			umsg.Long(BUILDTIME)
	umsg.End()
	----------------------------------------------------------------
	umsg.Start("updatetime")
		umsg.Long(TimeLeft)
		umsg.String(PHASE)
	umsg.End()
end

function Pmeta:CheckDead()

	if PHASE == "BUILD" then return end

	for k,v in pairs(player.GetAll()) do
		if self != v and v:Alive() then return end
	end
	GAMEMODE:StartBuild()
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("All players have perished loading build mode!")
	end
end

DMGMOD = 1
LDMGMOD = CurTime()
function DamageMod()
	if CurTime() > LDMGMOD + 5 then
		DMGMOD = math.sqrt(#player.GetAll())+.01
	end
	return DMGMOD
end