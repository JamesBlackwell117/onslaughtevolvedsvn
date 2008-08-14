
local Weaponclass = "weapon_none"
local Maxammo = 0
local Maxclip = 0
local lastphase = "none"
local TTimeleft = 0
local Maxmoney = 0
local ply = LocalPlayer()
local bkdrop = Color(31, 31, 31, 127)

function UnifiedBar(r,x,y,w,h,c,d,p,b,t)
	b = b or false
	p = p or 1
	p = math.Clamp(p,0,1)
	if GetConVarNumber( "ose_hud" ) == 1 then
		if b == false then
			draw.RoundedBox(r,x,y,w,h,d)
			if p*w > 2 then
				draw.RoundedBox(r,x+1,y+1,(w-2)*p,h-2,c)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t,"HUD2",x+w/2,y,Color(255,255,255,255),1,0,1,Color(0,0,0,255))
			end
		else
			draw.RoundedBox(r,x-w,y,w,h,d)
			if p*w > 2 then
				draw.RoundedBox(r,(x-1)-(w-2)*p,y+1,(w-2)*p,h-2,c)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t,"HUD2",x-w/2,y,Color(255,255,255,255),1,0,1,Color(0,0,0,255))
			end
		end
	else
		surface.SetDrawColor(c.r,c.b,c.g,c.a)
		surface.DrawRect(x,y,w*p,h)
		surface.SetDrawColor(d.r,d.b,d.g,d.a)
		surface.DrawOutlinedRect(x,y,w,h)
	end
end

function UnifiedSplitBar(r,x,y,w,h,c,d,p,b,t,n,s)
	p=p*n
	s = s or 0
	if GetConVarNumber( "ose_hud" ) == 1 then
		if b == false then
			for i=1,n do
				UnifiedBar(r,x+(w+s)*(i-1),y,w,h,c,d,p-i+1,b)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t,"HUD2",x+w*(n)/2,y,Color(255,255,255,255),1,0,1,Color(0,0,0,255))
			end
		else
			for i=1,n do
				UnifiedBar(r,x-(w+s)*(i-1),y,w,h,c,d,p-i+1,b)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t,"HUD2",x-w*(n)/2,y,Color(255,255,255,255),1,0,1,Color(0,0,0,255))
			end
		end
	end
end

function GM:DrawHUD()
	local W,H = ScrW(), ScrH()
	ply = LocalPlayer()
	local crnd = H/256
	local classid = ply:GetNetworkedInt("class") or 1
	local health = ply:Health()
	if !ply:Alive() then health = 0 end
	local maxhealth = 100
	if PHASE == "BATTLE" then
		maxhealth = Classes[classid].HEALTH
	end
	if PHASE != lastphase then
		TTimeleft = 0
		lastphase = PHASE
	end
	if TTimeleft < TimeLeft then
		TTimeleft = TimeLeft
	end

	local armor = ply:GetNWInt("Armor")

	local moncolor = Color(100,255,100,95)
	local money = ply:GetNetworkedInt( "money")
	if money <= 2500 then
		moncolor = Color(255,100,100,95)
	end

	local rank = ply:GetNWInt("rank") or 1
	local prevrank = RANKS[rank - 1] or RANKS[rank]
	local currank = RANKS[rank]
	local nextrank = RANKS[rank + 1] or RANKS[rank]
	local kills = math.Round(ply:GetNWInt("kills")) or 0

	local timecolor = Color(190, 200, 220, 95)
	if TimeLeft <= 30 && (math.Round(TimeLeft) / 2) == math.Round(TimeLeft / 2) then timecolor = Color(220, 100, 95, 95) end

	local cur_mag,alt_mag,mags,alt_mags,ammofraction,clipfraction,maxclips,clips,alts
	local wdraw = false

	if ply:Alive() && ValidEntity(ply:GetActiveWeapon()) then
		wdraw = true
		local w = ply:GetActiveWeapon()
		if !ply:GetActiveWeapon().Primary then	ply:GetActiveWeapon().Primary = {} end
		local wt = w.Primary
		cur_mag = w:Clip1() or 0
		alt_mag = w:Clip2() or 0
		mags = ply:GetAmmoCount(w:GetPrimaryAmmoType()) or 0
		alt_mags = ply:GetAmmoCount(w:GetSecondaryAmmoType()) or 0

		if Weaponclass != w:GetClass() then
			Weaponclass = w:GetClass()
			Maxammo = wt.Maxammo or 0
			Maxclip = wt.ClipSize or 0
		end

		if cur_mag > Maxclip then Maxclip = cur_mag wt.ClipSize = Maxclip end
		if mags+cur_mag > Maxammo then Maxammo = mags wt.Maxammo = Maxammo end
		ammofraction = (mags)/(Maxammo)
		clipfraction = cur_mag/Maxclip

		maxclips = math.ceil(Maxammo/math.Clamp(Maxclip,1,math.huge))
		clips = math.floor(mags/math.Clamp(Maxclip,1,math.huge))
		alts = math.Clamp(alt_mags-1,-1,math.Round(W/36))
	end

	-- messages
	for k,v in pairs(Messages) do
		local col = v.colour
		local y = (H - 200) - ((CurTime() - v.Time) * 100) + (k * 14)
		draw.SimpleTextOutlined(v.text,"Message",W - 30,y,col,2,0,0.5,Color(50,50,50,255))
		if v.Time - CurTime() <= -4 then
			local newcol = Color(col.r,col.g,col.b,col.a - 10)
			v.colour = newcol
			if v.colour.a <= 0 then
				Messages[k] = nil
			end
		end
	end

	-- Player & Turret info
	local iterator = player.GetAll()
	table.Add(iterator,ents.FindByClass("npc_turret_floor"))
	table.Add(iterator,ents.FindByClass("npc_turret_ceiling"))
	for k, v in pairs(iterator) do
		local trace = {}
		trace.start = ply:GetPos() + Vector(0,0,40)
		trace.endpos = v:GetPos() + Vector(0,0,40)
		trace.filter = ply
		local trace = util.TraceLine( trace )

		if !trace.HitWorld then
			local spos = ply:GetPos()
			local tpos = v:GetPos()
			local dist = spos:Distance(tpos)

			if dist <= 1800 then
				local offset = -0.03333 * dist
				local pos = v:GetPos() + Vector(0,0,offset)
				pos = pos:ToScreen()
				if pos.visible == true then
					local alphavalue = math.Clamp(1200 - (dist/1.5),0,255)
					local outlinealpha = math.Clamp(900 - (dist/2),0,255)

					if v:IsPlayer() then
						local playercolour = team.GetColor(v:Team())
						if v != ply && v:Alive() then
							draw.SimpleTextOutlined(v:Name(), "HUD2", pos.x, pos.y - 10, Color(playercolour.r, playercolour.g, playercolour.b, alphavalue),1,1,1,Color(0,0,0,outlinealpha))
							if classid == 6 || ply:Alive() == false then
								local maxhealth
								if PHASE == "BUILD" then maxhealth = 100
								elseif v:GetNWInt("class") && v:GetNWInt("class")!= 0 then maxhealth = Classes[v:GetNWInt("class")].HEALTH else break end
								UnifiedBar(crnd,pos.x-W*.03*maxhealth/100,pos.y+6,W*0.06*maxhealth/100,12,Color(191, 0, 0, 127*alphavalue/255),Color(31, 31, 31, 127*outlinealpha/255),v:Health()/maxhealth)
							end
						end
					else
						if classid == 3 then
							UnifiedBar(crnd,pos.x-W*.03,pos.y+6,W*0.06,12,Color(191, 0, 0, 127*alphavalue/255),Color(31, 31, 31, 127*outlinealpha/255),v:GetNWInt("health")/TURRET_HEALTH)
						end
					end
				end
			end
		end
	end

	if GetConVarNumber( "ose_hud" ) == 1 then
		-- timer draw
		UnifiedBar(crnd,W-19,H-42,W/6,22,timecolor,bkdrop,TimeLeft/TTimeleft,true,"Time: "..string.FormattedTime( TimeLeft, "%2i:%02i"))

		-- money calcs and draw
		if money > Maxmoney then Maxmoney = money end
		local wads = math.ceil(Maxmoney/5000)
		UnifiedSplitBar(crnd,W-19,H-66,W/6/wads,22,moncolor,bkdrop,money/(wads*5000),true,"Money: "..money,wads)

		-- rank calcs and draw
		if currank != nextrank then
			local prbk = Color(prevrank.COLOR.r*2/3,prevrank.COLOR.g*2/3,prevrank.COLOR.b*2/3,bkdrop.a)
			local crbk = Color(currank.COLOR.r*2/3,currank.COLOR.g*2/3,currank.COLOR.b*2/3,bkdrop.a)
			local nrbk = Color(nextrank.COLOR.r*2/3,nextrank.COLOR.g*2/3,nextrank.COLOR.b*2/3,bkdrop.a)
			local prc = Color(prevrank.COLOR.r,prevrank.COLOR.g,prevrank.COLOR.b,95)
			local crc = Color(currank.COLOR.r,currank.COLOR.g,currank.COLOR.b,95)

			local rankpct = (kills-currank.KILLS) / (nextrank.KILLS-currank.KILLS)
			if prevrank != currank then
			draw.RoundedBox(crnd,W-19-W/6,H-90,W/6/5,22,prbk)
			draw.RoundedBox(crnd,W-18-W/6,H-89,W/6/5-2,20,prc)
			end
			draw.RoundedBox(crnd,W-19-W/6+W/6/5,H-90,W/6/5*3,22,crbk)
			if W/6/5*3*rankpct-2 > crnd/2 then draw.RoundedBox(crnd,W-18-W/6+W/6/5,H-89,W/6/5*3*rankpct-2,20,crc) end

			draw.RoundedBox(crnd,W-19-W/6+W/6*4/5,H-90,W/6/5,22,nrbk)
		end

		-- weapon draw
		local hbaroff = 0
		if wdraw == true then
			if Maxammo > 0 then
				UnifiedSplitBar(crnd,19,H-32,22,12,Color(190, 200, 220, 95),bkdrop,mags/(maxclips*Maxclip),false,"Clips: "..clips,maxclips,2)
				for i=0,alts do
					draw.RoundedBox(crnd,22+12*i,H-29,6, 6, Color(200, 200, 0, 200))
				end
				hbaroff = hbaroff + 14
			end
			if Maxclip > 0 then
				UnifiedBar(crnd,19,H-42-hbaroff,W/6*Maxclip/20,22,Color(190, 200, 220, 95),bkdrop,clipfraction,false,"Clip: "..cur_mag.."/"..Maxclip)
				hbaroff = hbaroff + 24
			end
		end

		-- health draw
		UnifiedBar(crnd,19,H-42-hbaroff,W*maxhealth/600,22,Color(191, 0, 0, 127),bkdrop,health/maxhealth,false,"Health: "..health.."/"..maxhealth)

		-- armor
		if armor > 0 then
			UnifiedBar(crnd,19,H-42-hbaroff,W*maxhealth/600,22,Color(0, 0, 255, 64),Color(0,0,0,0),armor/100)
		end

		-- turret health bars
		local turoff = 14
		local iterator = ents.FindByClass("npc_turret_floor")
		table.Add(iterator,ents.FindByClass("npc_turret_ceiling"))
		for k,v in pairs(iterator) do
			if v:GetNWEntity( "Owner" ) == ply then
				UnifiedBar(crnd,19,H-42-hbaroff-turoff,W/6,12,Color(220, 220, 0, 95),bkdrop,v:GetNWInt("health")/TURRET_HEALTH,false,"Turret Health: "..v:GetNWInt("health").."/"..TURRET_HEALTH)
				turoff = turoff + 14
			end
		end
	else
		local x,y = 0.02, 0.80
		local w,h = 0.208, 0.13
		if Maxammo > 0 then
			w = 0.208
			h = 0.1
		end

		-- main bottom pannels
		UnifiedBar(0, W*x,H*y, W*w, H*h,Color(50, 50, 50, 200),Color(255, 255, 255, 255))
		UnifiedBar(0, W/1.3, H*0.90, W*0.2, H*0.08,Color(50, 50, 50, 200),Color(255, 255, 255, 255))

		-- top bar
		if GetConVarNumber("ose_hidetips") != 1 then
			UnifiedBar(0,0,0,W,H*0.04,Color(50, 50, 50, 200),Color(255, 255, 255, 255))
			draw.SimpleText("TIP: "..tip,"HUD",W*0.01,H*0.006)
		end

		UnifiedBar(0,W*0.7,0,W*0.3,H*0.04,Color(0, 0, 0, 0),Color(255, 255, 255, 255))
		local killneeded = nextrank.KILLS or 0
		if kills > killneeded || rank >= #RANKS then
			draw.SimpleText("KILLS: "..kills, "HUD",W*0.71,H*0.006)
		else
			draw.SimpleText("KILLS: "..kills.."/"..killneeded.." For "..RANKS[rank + 1].NAME.." Rank", "HUD",W*0.71,H*0.006)
		end

		-- health bar
		local itr = W / 5.02 * health/maxhealth - 2
		for i = 0, itr do
			local r = math.Clamp(255 - i,0,255)
			local g = math.Clamp((health / maxhealth)*255,0,255)
			surface.SetDrawColor(r, g, 10, 255)
			surface.DrawRect( W * 0.025 + i, H * 0.86, 1, H / 40 )
		end

		if armor > 0 then
			UnifiedBar(0,W * 0.025, H * 0.86, W / 5.02*armor/100, H / 40,Color(0, 0, 255, 64),Color(0,0,0,0),armor/100)
		end

		UnifiedBar(0,W*0.025,H*0.86,W/5.02,H/40,Color(0, 0, 0, 0),Color(255, 255, 255, 255))
		draw.SimpleTextOutlined("Class: "..Classes[classid].NAME,"HUD",W*0.03,H*0.82,Color(255,255,255,255),0,0,1,Color(0,0,0,255))
		draw.SimpleTextOutlined("Health: "..health.."/"..maxhealth,"HUD2",W*0.03,H*0.86,Color(255,255,255,255),0,0,1,Color(0,0,0,255))

		-- weapon bars
		if wdraw == true then
			if Maxammo > 0 then
				surface.SetDrawColor(0, 255, math.Clamp(clipfraction * 255, 0, 255), 255)
				surface.DrawRect( W * 0.025, H * 0.89, (W / 5.02)*math.abs(cur_mag)/Maxclip, H / 40 )

				surface.SetDrawColor(0, math.Clamp(ammofraction * 255, 0, 255), 255, 255)
				surface.DrawRect( W * 0.025, H * 0.915, (W / 5.02)*(mags-Maxclip+cur_mag)/(Maxammo), H / 160 )
				
				surface.SetDrawColor(0, 255, math.Clamp(clipfraction * 255, 0, 255), 255)
				surface.DrawRect( W * 0.025, H * 0.915, (W / 5.02)*(mags-Maxclip)/(Maxammo), H / 160 )

				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawOutlinedRect( W * 0.025, H * 0.89, W / 5.02, H / 40 )
				surface.DrawOutlinedRect( W * 0.025, H * 0.89, W / 5.02, H / 32 )
				draw.SimpleTextOutlined( "Ammo: "..math.abs(cur_mag).."/"..mags, "HUD2", W * 0.03, H * 0.891, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
			end
			if alt_mags > 0 then
				draw.SimpleTextOutlined( "Alt: "..alt_mags, "HUD2", W * 0.18, H * 0.891, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
			end
		end
		-- right panel
		if TimeLeft <= 0 then TimeLeft = 0 end
		draw.DrawText("Money: "..math.Round(ply:GetNetworkedInt( "money")), "ScoreboardText", W / 1.15 , H * 0.91, MonCol,1)
		draw.DrawText("Phase: "..PHASE, "ScoreboardText", W / 1.15, H * 0.93, Color(255,255,255,255),1)
		draw.DrawText("Time Remaining: "..string.FormattedTime( TimeLeft, "%2i:%02i")  , "ScoreboardText", W / 1.15 , H * 0.95, timecol,1)
	end
end

function GM:HUDDrawTargetID( )
	if !LocalPlayer():Alive() then return end
	local tr = LocalPlayer( ):GetEyeTrace( )
	if not tr.Hit or not ValidEntity( tr.Entity ) then
		return
	end
	local W,H = ScrW(), ScrH()
	local ent = tr.Entity

	if ent.Turret then ent = ent.Turret end
	local own = ent:GetNWEntity("owner")
	if !ValidEntity(own) then return end

	if ent:GetClass() == "sent_spawpoint" then
		draw.SimpleTextOutlined(own:Nick().."'s spawnpoint", "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
	else
		local mdl = ent:GetModel()
		if MODELS[mdl].NAME then
			draw.SimpleTextOutlined(own:Nick().."'s "..MODELS[mdl].NAME, "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
		else
			draw.SimpleTextOutlined(own:Nick().."'s prop", "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
		end
	end
end
