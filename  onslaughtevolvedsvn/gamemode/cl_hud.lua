//Conman

function GM:DrawHUD()
	local W,H = ScrW(), ScrH()
	local ply = LocalPlayer()
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
	if cur_mag == -1 && mags <= 0 then
		w = 0.208
		h = 0.1
	end
	surface.SetDrawColor(50, 50, 50, 255)
	surface.DrawRect( W * x, H * y, W * w, H * h )
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawOutlinedRect( W * x, H * y, W * w, H * h )
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
	draw.SimpleTextOutlined( "Health: "..ply:Health().."/"..Mhlth, "HUD", W * 0.03, H * 0.86, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
	if cur_mag == -1 && mags <= 0 then
		--do nothing
	else
		local text = ""
		if cur_mag == -1 then
			text = "Ammo: "..mags
		else
			text = "Ammo: "..cur_mag.."/"..mags
		end
		draw.SimpleText( text, "HUD", W * 0.03, H * 0.89 )
	end
	if alt_mags > 0 then
		draw.SimpleText( "Alt: "..alt_mags, "HUD", W * 0.18, H * 0.89 )
	end
end
