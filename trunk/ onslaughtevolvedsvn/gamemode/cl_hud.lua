//Conman

Weaponclass = "weapon_none"
Maxammo = 0
Maxclip = 0


function GM:DrawHUD()
	local W,H = ScrW(), ScrH()
	local ply = LocalPlayer()
	
	-- messages
	for k,v in pairs(Messages) do
		local col = v.colour
		local y = (H - 200) - ((CurTime() - v.Time) * 90) + (k * 12)
		draw.SimpleTextOutlined(v.text,"ScoreboardText",W - 30,y,col,2,0,0.5,Color(50,50,50,255))
		if v.Time - CurTime() <= -4 then
			local newcol = Color(col.r,col.g,col.b,col.a - 10)
			v.colour = newcol
			if v.colour.a <= 0 then
				Messages[k] = nil
			end
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
	
	surface.SetDrawColor(50, 50, 50, 150)
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
	draw.SimpleTextOutlined( "Health: "..ply:Health().."/"..Mhlth, "HUD2", W * 0.03, H * 0.862, Color(255,255,255,255),0, 0, 1, Color(0,0,0,255) )
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
			draw.SimpleTextOutlined( "Ammo: "..mags, "HUD2", W * 0.03, H * 0.892, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
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
			--surface.DrawOutlinedRect( W * 0.025, H * 0.89, W / 5.02, H / 40 )
			surface.DrawOutlinedRect( W * 0.025, H * 0.89, W / 5.02, H / 32 )
			draw.SimpleTextOutlined( "Ammo: "..cur_mag.."/"..mags, "HUD2", W * 0.03, H * 0.892, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
			
			if alt_mags > 0 then
				draw.SimpleTextOutlined( "Alt: "..alt_mags, "HUD2", W * 0.18, H * 0.892, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
			end
		end
	end
	
	if TimeLeft <= 0 then TimeLeft = 0 end
	draw.DrawText("Money: "..math.Round(LocalPlayer():GetNetworkedInt( "money")), "ScoreboardText", W / 1.15 , H * y1, MonCol,1)
	draw.DrawText("Phase: "..PHASE, "ScoreboardText", W / 1.15, H * y2, Color(255,255,255,255),1)
	draw.DrawText("Time Remaining: "..string.FormattedTime( TimeLeft, "%2i:%02i")  , "ScoreboardText", W / 1.15 , H * y3, timecol,1)
	
	
	if GetConVarNumber( "ose_hidetips" ) != 1 then
		surface.SetDrawColor(50, 50, 50, 150)
		surface.DrawRect( 0,0, W, H * 0.04)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect( 0,0, W, H * 0.04)
		draw.SimpleText( "TIP: "..tip, "HUD", W * 0.01, H * 0.006 )
		surface.DrawOutlinedRect( W * 0.7,0, W * 0.3, H * 0.04)
		local kills = math.Round(LocalPlayer():GetNWInt("kills")) or 0
		local nextrank = RANKS[LocalPlayer():GetNWInt("rank") + 1] or RANKS[LocalPlayer():GetNWInt("rank")]
		local killneeded = nextrank.KILLS or 0
		local rank = LocalPlayer():GetNWInt("rank") or 1
		if kills > killneeded || rank >= #RANKS then
			draw.SimpleText( "KILLS: "..kills, "HUD", W * 0.71, H * 0.006 )
		else
			draw.SimpleText( "KILLS: "..kills.."/"..math.Clamp(killneeded - kills,0,killneeded).." kills until "..RANKS[rank + 1].NAME, "HUD", W * 0.71, H * 0.006 )
		end
	end
end

function GM:HUDDrawTargetID( )
	if !LocalPlayer():Alive() then return end
	if GetConVarNumber( "ose_hidetips" ) == 1 then return end
	local tr = LocalPlayer( ):GetEyeTrace( )
	if not tr.Hit or not ValidEntity( tr.Entity ) then
		return
	end
	
	local ent = tr.Entity
	
	local sw,sh = ScrW( ), ScrH( )
	local midx, midy = sw / 2, sh / 2
	local y, bh = midy - 20, 42

	if ent:IsPlayer( ) then
		surface.SetFont( "ScoreboardText" )
		local w, h = surface.GetTextSize( ent:GetName( ) )
		if w > 100 then
			draw.RoundedBox( 8, midx - ( w / 2 ) - 2, y + 26, w + 5, bh, Color( 0, 0, 255, 200 ) )
		else
			draw.RoundedBox( 8, midx - 50, y + 46, 100, bh, Color( 0, 0, 255, 200 ) )
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
		draw.RoundedBox( 8, midx - ( w / 2 ) - 4, midy - ( h / 2 ) - 4 + 26, w + 8, h + 8, col )
		
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
