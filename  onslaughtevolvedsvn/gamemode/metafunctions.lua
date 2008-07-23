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

function Emeta:GetRealOwner()
	local owner
	if ValidEntity(self.Owner) then owner = self.Owner elseif ValidEntity(self:GetOwner()) then owner = self:GetOwner() end
	return owner
end

function Emeta:PropRemove(ply,checkowner,ifnotclass,silent)
	if self.Dissolving then return 0 end
	ply = ply or nil
	checkowner = checkowner or false
	ifnotclass = ifnotclass or false
	silent = silent or false
	local cost
	if checkowner then
		local owner = self:GetRealOwner()
		local model = self:GetModel()
	
		if owner then
			if ifnotclass and MODELS[model] && MODELS[model].PLYCLASS && owner:GetNWInt("class") == MODELS[model].PLYCLASS then
			elseif ply and owner != ply and !ply:IsAdmin() then
				if !silent then
					ply:PrintMessage(HUD_PRINTCENTER, "This item is owned by " .. owner:Nick( ))
					ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
				end
				return 0
			elseif MODELS[model] && MODELS[model].COST then
				cost = MODELS[model].COST
			elseif self.SMH && self.SMH > 0 then
				cost = self.SMH
			end
		end
		if cost then
			if !silent then
				owner:Money(self.SMH,"+"..math.Round(self.SMH).." [Deleted Item]")
			end
		end
	end
	if self:IsNPC() then self:Remove() elseif cost then self:Dissolve() end
	return cost or 0
end

function Pmeta:Money(amt,msg,col)
	local suffix = " "
	local money = self:GetNWInt("money")
	if amt < 0 then 
		if money - amt < 0 then 
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
	if msg then	self:Message(msg,col) end
	
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
	for k,v in pairs(Classes) do
		if v.NAME == self:GetInfo("ose_defaultclass") then
			self:SetNetworkedInt( "class", k)
			break
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

function CheckDead()
	if PHASE == "BUILD" then return end
	for k,v in pairs(player.GetAll()) do
		if v:Alive() then return end
	end
	GAMEMODE:StartBuild()
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("All players have perished loading build mode!")
	end
end