
Weaponclass = "weapon_none"
Maxammo = 0
Maxclip = 0
lastphase = "none"
TTimeleft = 0
Maxmoney = 0
local ply = LocalPlayer()

function UnifiedBar(r,x,y,w,h,c,d,p,b,t)
	b = b or false
	p = math.Clamp(p,0,1)
	if GetConVarNumber( "ose_hud" ) == 1 then
		if b == false then
			draw.RoundedBox(r,x,y,w,h,d)
			if p*w > 2 then
				draw.RoundedBox(r,x+1,y+1,(w-2)*p,h-2,c)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t, "HUD2", x+w/2, y, Color(255,255,255,255), 1, 0, 1, Color(0,0,0,255) )
			end
		else
			draw.RoundedBox(r,x-w,y,w,h,d)
			if p*w > 2 then
				draw.RoundedBox(r,(x-1)-(w-2)*p,y+1,(w-2)*p,h-2,c)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t, "HUD2", x-w/2, y, Color(255,255,255,255), 1, 0, 1, Color(0,0,0,255) )
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
				draw.SimpleTextOutlined(t, "HUD2", x+w*(n)/2, y, Color(255,255,255,255), 1, 0, 1, Color(0,0,0,255) )
			end
		else
			for i=1,n do
				UnifiedBar(r,x-(w+s)*(i-1),y,w,h,c,d,p-i+1,b)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t, "HUD2", x-w*(n)/2, y, Color(255,255,255,255), 1, 0, 1, Color(0,0,0,255) )
			end
		end
	end
end

function GM:DrawHUD()
	local W,H = ScrW(), ScrH()
	ply = LocalPlayer()
	local crnd = H/256
	local classid = ply:GetNetworkedInt("class") or 1

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
	
	-- player info
	for k, v in pairs(player.GetAll()) do
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
					local alphavalue = math.Clamp(1200 - (dist/1.5), 0, 255)					
					local outlinealpha = math.Clamp(900 - (dist/2), 0, 255)
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
				end
			end
		end
	end
	
	if GetConVarNumber( "ose_hud" ) == 1 then
		//Alias Modern HUD
		local bkdrop = Color(31, 31, 31, 127)
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
		
		local moncolor = Color(100,255,100,95)
		local money = ply:GetNetworkedInt( "money")
		if money <= 2500 then
			moncolor = Color(255,100,100,95)
		end		

		local rank = ply:GetNWInt("rank") or 1
		local prevrank = RANKS[rank - 1] or RANKS[rank]
		local currank =	RANKS[rank]
		local nextrank = RANKS[rank + 1] or RANKS[rank]
		local kills = math.Round(ply:GetNWInt("kills")) or 0
			
		-- timer calcs and draw
		local timecolor = Color(190, 200, 220, 95)
		if TimeLeft <= 30 && (math.Round(TimeLeft) / 2) == math.Round(TimeLeft / 2) then timecolor = Color(220, 100, 95, 95) end
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
			
		-- weapon calcs and draw + health draw
		local hbaroff = 0
		if ValidEntity(ply:GetActiveWeapon()) then
			local cur_mag = ply:GetActiveWeapon():Clip1() or 0
			local alt_mag = ply:GetActiveWeapon():Clip2() or 0
			local mags = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()) or 0
			local alt_mags = ply:GetAmmoCount(ply:GetActiveWeapon():GetSecondaryAmmoType()) or 0
		
			if Weaponclass != ply:GetActiveWeapon():GetClass() then
				Weaponclass = ply:GetActiveWeapon():GetClass()
				Maxammo = 0
				Maxclip = 0
			end	
			
			if cur_mag > Maxclip then Maxclip = cur_mag end
			if mags+cur_mag > Maxammo then Maxammo = mags end
			local ammofraction = (mags)/(Maxammo)
			local clipfraction = cur_mag/Maxclip
		
			if Maxammo > 0 then
				local maxclips = math.ceil(Maxammo/math.Clamp(Maxclip,1,math.huge))
				local clips = math.floor(mags/math.Clamp(Maxclip,1,math.huge))
				local alts = math.Clamp(alt_mags-1,-1,math.Round(W/36))
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
		
		UnifiedBar(crnd,19,H-42-hbaroff,W*maxhealth/600,22,Color(191, 0, 0, 127),bkdrop,ply:Health()/maxhealth,false,"Health: "..ply:Health().."/"..maxhealth)
		
		-- turret health bars
		local turoff = 14
		for k,v in pairs(ents.FindByClass("npc_turret_floor")) do
			if v:GetNWEntity( "Owner" ) == ply then
				UnifiedBar(crnd,19,H-42-hbaroff-turoff,W/6,12,Color(220, 220, 0, 95),bkdrop,v:GetNWInt("health")/TURRET_HEALTH,false,"Turret Health: "..v:GetNWInt("health").."/"..TURRET_HEALTH)
				turoff = turoff + 14
			end
		end
		-----------------------------------------------------------------------
		--------------------- END MODERN HUD ----------------------------------
		-----------------------------------------------------------------------
	else	
		if GetConVarNumber( "ose_hidetips" ) != 1 then
			surface.SetDrawColor(50, 50, 50, 150)
			surface.DrawRect( 0,0, W, H * 0.04)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawOutlinedRect( 0,0, W, H * 0.04)
			draw.SimpleText( "TIP: "..tip, "HUD", W * 0.01, H * 0.006 )
			surface.DrawOutlinedRect( W * 0.7,0, W * 0.3, H * 0.04)
			local kills = math.Round(ply:GetNWInt("kills")) or 0
			local nextrank = RANKS[ply:GetNWInt("rank") + 1] or RANKS[ply:GetNWInt("rank")]
			local killneeded = nextrank.KILLS or 0
			local rank = ply:GetNWInt("rank") or 1
			if kills > killneeded || rank >= #RANKS then
				draw.SimpleText( "KILLS: "..kills, "HUD", W * 0.71, H * 0.006 )
			else
				draw.SimpleText( "KILLS: "..kills.."/"..killneeded.." For "..RANKS[rank + 1].NAME.." Rank", "HUD", W * 0.71, H * 0.006 )
			end
		else
			surface.SetDrawColor(50, 50, 50, 150)
			surface.DrawRect( W * 0.7,0, W * 0.3, H * 0.04)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawOutlinedRect( W * 0.7,0, W * 0.3, H * 0.04)
			local kills = math.Round(ply:GetNWInt("kills")) or 0
			local nextrank = RANKS[ply:GetNWInt("rank") + 1] or RANKS[ply:GetNWInt("rank")]
			local killneeded = nextrank.KILLS or 0
			local rank = ply:GetNWInt("rank") or 1
			if kills > killneeded || rank >= #RANKS then
				draw.SimpleText( "KILLS: "..kills, "HUD", W * 0.71, H * 0.006 )
			else
				draw.SimpleText( "KILLS: "..kills.."/"..killneeded.." For "..RANKS[rank + 1].NAME.." Rank", "HUD", W * 0.71, H * 0.006 )
			end
		end
		
		if !ply:Alive() then return end
		local Mhlth = 100
		if PHASE == "BATTLE" then
			Mhlth = Classes[ply:GetNWInt("class",1)].HEALTH
		end
		local hlth = (ply:Health() / Mhlth) * 25
		if hlth > Mhlth then hlth = Mhlth end
		local x,y = 0.02, 0.80
		local w,h = 0.208, 0.13
		if not ValidEntity(ply:GetActiveWeapon()) then return end
		local cur_mag = ply:GetActiveWeapon():Clip1()
		local alt_mag = ply:GetActiveWeapon():Clip2()
		local mags = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())
		local alt_mags = ply:GetAmmoCount(ply:GetActiveWeapon():GetSecondaryAmmoType())
		if cur_mag <= 0 && mags <= 0 && alt_mags <= 0 then
			w = 0.208
			h = 0.1
		end
		local y1,y2,y3 = 0.91,0.93,0.95
		local xH = 0.08
		local xY = 0.90
		local MonCol = Color(255,255,255,255)
		local timecol = Color(255,255,255,255)
			
		if ply:GetNetworkedInt( "money") <= 0 then
			MonCol = Color(255,100,100,255)
		end
		if TimeLeft <= 30 && (math.Round(TimeLeft) / 2) == math.Round(TimeLeft / 2) then --is even
		 	timecol = Color(255,100,100,255)
		end
		
		surface.SetDrawColor(50, 50, 50, 200)
		surface.DrawRect( W * x, H * y, W * w, H * h ) -- left pannel
		surface.DrawRect( W / 1.3, H * xY, W * 0.2, H *  xH) -- right
	
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect( W * x, H * y, W * w, H * h ) -- left outline
		surface.DrawOutlinedRect( W / 1.3, H * xY, W * 0.2, H *  xH) -- right
		
		for i = 0, Mhlth do
			local frac = Mhlth / hlth
			local r = math.Clamp(255 - i,0,255)
			local g = math.Clamp((ply:Health() / Mhlth) * 255, 0, 255)
			surface.SetDrawColor(r, g, 10, 255)
			surface.DrawRect( W * 0.025 + ((i * (W * 0.00785))/ frac), H * 0.86, W / 300, H / 40 )
		end
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect( W * 0.025, H * 0.86, W / 5.02, H / 40 )
		local classid = ply:GetNetworkedInt("class") or 1
		
		draw.SimpleTextOutlined( "Class: "..Classes[classid].NAME, "HUD", W * 0.03, H * 0.82, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
		draw.SimpleTextOutlined( "Health: "..ply:Health().."/"..Mhlth, "HUD2", W * 0.03, H * 0.86, Color(255,255,255,255),0, 0, 1, Color(0,0,0,255) )
		if cur_mag <= 0 && mags <= 0 then
			if alt_mags > 0 then
				draw.SimpleText( "Alt: "..alt_mags, "HUD", W * 0.18, H * 0.892, Color(255,255,255,255), 0, 0, 1)
			end
		else
			if Weaponclass != ply:GetActiveWeapon():GetClass() then
				Weaponclass = ply:GetActiveWeapon():GetClass()
				Maxammo = 0
				Maxclip = 0
			end	
			if cur_mag == -1 then
				if 1 > Maxclip then Maxclip = 1 end
				if mags > Maxammo then Maxammo = mags end
				local ammofraction = (mags)/(Maxammo)
				local clipfraction = 1/(Maxammo)
				
				surface.SetDrawColor(0, 255, math.Clamp(clipfraction * 255, 0, 255), 255)
				surface.DrawRect( W * 0.025, H * 0.89, (W / 5.02), H / 40 )
				
				surface.SetDrawColor(0, 255, math.Clamp(clipfraction * 255, 0, 255), 255)
				surface.DrawRect( W * 0.025, H * 0.915, (W / 5.02)*(ammofraction), H / 160 )
				
				surface.SetDrawColor(0, math.Clamp(ammofraction * 255, 0, 255), 255, 255)
				surface.DrawRect( W * 0.025, H * 0.915, (W / 5.02)*(ammofraction-clipfraction), H / 160 )
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawOutlinedRect( W * 0.025, H * 0.89, W / 5.02, H / 40 )
				draw.SimpleTextOutlined( "Ammo: "..mags, "HUD2", W * 0.03, H * 0.89, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
			else
				if cur_mag > Maxclip then Maxclip = cur_mag end
				if mags+cur_mag > Maxammo then Maxammo = mags+cur_mag end
				local ammofraction = (mags+cur_mag)/(Maxammo)
				local clipfraction = cur_mag/(Maxammo)
				
				surface.SetDrawColor(0, 255, math.Clamp(clipfraction * 255, 0, 255), 255)
				surface.DrawRect( W * 0.025, H * 0.89, (W / 5.02)*cur_mag/Maxclip, H / 40 )
				
				surface.SetDrawColor(0, 255, math.Clamp(clipfraction * 255, 0, 255), 255)
				surface.DrawRect( W * 0.025, H * 0.915, (W / 5.02)*(ammofraction), H / 160 )
				
				surface.SetDrawColor(0, math.Clamp(ammofraction * 255, 0, 255), 255, 255)
				surface.DrawRect( W * 0.025, H * 0.915, (W / 5.02)*(ammofraction-clipfraction), H / 160 )
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawOutlinedRect( W * 0.025, H * 0.89, W / 5.02, H / 40 )
				surface.DrawOutlinedRect( W * 0.025, H * 0.89, W / 5.02, H / 32 )
				draw.SimpleTextOutlined( "Ammo: "..cur_mag.."/"..mags, "HUD2", W * 0.03, H * 0.891, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
				
				if alt_mags > 0 then
					draw.SimpleTextOutlined( "Alt: "..alt_mags, "HUD2", W * 0.18, H * 0.891, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
				end
			end
		end
	
		if TimeLeft <= 0 then TimeLeft = 0 end
		draw.DrawText("Money: "..math.Round(ply:GetNetworkedInt( "money")), "ScoreboardText", W / 1.15 , H * y1, MonCol,1)
		draw.DrawText("Phase: "..PHASE, "ScoreboardText", W / 1.15, H * y2, Color(255,255,255,255),1)
		draw.DrawText("Time Remaining: "..string.FormattedTime( TimeLeft, "%2i:%02i")  , "ScoreboardText", W / 1.15 , H * y3, timecol,1)
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
	
	local sw,sh = ScrW( ), ScrH( )
	local midx, midy = sw / 2, sh / 2
	local y, bh = midy - 20, 42
	
if GetConVarNumber( "ose_hud" ) == 1 then
	--if ent:IsPlayer( ) then
	--	draw.SimpleTextOutlined(ent:Nick(), "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
	--elseif ent:GetClass( ) == "npc_turret_floor" then
	--	local own = ent:GetNWEntity( "Owner")
	--	if ValidEntity(own) then
	--		draw.SimpleTextOutlined(own:GetName( ) .. "'s turret", "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
	--	end
	--else
	if ent:GetClass() == "sent_spawpoint" then
		local own = ent:GetNWEntity("owner")
		if ValidEntity(own) then
			draw.SimpleTextOutlined(own:Nick().."'s spawnpoint.", "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
		end
	end
else
	if ent:IsPlayer( ) then
		surface.SetFont( "ScoreboardText" )
		local w, h = surface.GetTextSize( ent:GetName( ) )
		
		if w > 100 then
			surface.SetDrawColor(50, 50, 50, 200)
			surface.DrawRect(  midx - ( w / 2 ) - 2, y + 46, w + 5, bh )
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawOutlinedRect(  midx - ( w / 2 ) - 2, y + 46, w + 5, bh )

			--surface.SetDrawColor(255, 255, 255, 255)
			--surface.DrawOutlinedRect( W * x, H * y, W * w, H * h ) -- left outline
			--surface.DrawOutlinedRect( W / 1.3, H * xY, W * 0.2, H *  xH) -- right
			--draw.RoundedBox( 8, midx - ( w / 2 ) - 2, y + 26, w + 5, bh, Color( 0, 0, 255, 200 ) )
		else
			surface.SetDrawColor(50, 50, 50, 200)
			surface.DrawRect(  midx - 50, y + 46, 100, bh )
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawOutlinedRect(  midx - 50, y + 46, 100, bh )
		end
		
		
		
		draw.Text( {
			text = "Health: " .. ent:Health( ),
			font = "ScoreboardText",
			pos = { midx, midy - 10 + 46 },
			color = Color( 255, 255, 255, 255 ),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER
		} )
		draw.Text( {
			text = "Class: " .. Classes[ ent:GetNWInt( "Class", 1 ) ].NAME,
			font = "ScoreboardText",
			pos = { midx, midy + 10 + 46 },
			color = Color( 255, 255, 255, 255 ),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER
		} )
		draw.Text( {
			text = ent:GetName( ),
			font = "ScoreboardText",
			pos = { midx, midy + 46 },
			color = Color( 255, 255, 255, 255 ),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER
		} )
	elseif ent:GetClass() == "sent_spawpoint" then
		local own = ent:GetNWEntity("owner")
		if ValidEntity(own) then
			draw.SimpleTextOutlined( ent:GetNWEntity("owner"):Nick().."'s spawnpoint.", "HUD2", W * 0.02, H * 0.98, Color(255,255,255,255), 0, 1, 1, Color(0,0,0,255) )
		end
	elseif ent:IsNPC( ) then
		local name = ""
		local name2 = ""
		local col = Color( 255, 0, 0, 50 )
		if npcs[ ent:GetClass( ) ] then
			name = npcs[ ent:GetClass( ) ]
		else
			if ent:GetClass( ) == "npc_turret_floor" then
				name = ent:GetNWEntity( "Owner", LocalPlayer( ) ):GetName( ) .. "'s turret"
				name2 = "Health: "..math.Round(ent:GetNWInt("health"))
				col = Color( 0, 0, 255, 200 )
			else
				name = ent:GetClass( )
			end
		end
		
		surface.SetFont( "ScoreboardText" )
		local w, h = surface.GetTextSize( name.."\n"..name2 )
		surface.SetDrawColor(50, 50, 50, 200)
		surface.DrawRect( midx - ( w / 2 ) - 4, midy - ( h / 2 ) - 4 + 26, w + 8, h + 8 )
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect( midx - ( w / 2 ) - 4, midy - ( h / 2 ) - 4 + 26, w + 8, h + 8 )
		draw.Text( {
			text = name,
			font = "ScoreboardText",
			pos = { midx, midy + 25 },
			color = Color( 255, 255, 255, 255 ),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER
		} )
		
		draw.Text( {
			text = name2,
			font = "ScoreboardText",
			pos = { midx, midy + 37 },
			color = Color( 255, 255, 255, 255 ),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER
		} )
		
	end
end
end
