//Conman, Xera

include( "shared.lua" )
include( "cl_scoreboard.lua" )
include( "cl_deathnotice.lua" )
include( "cl_panels.lua" )
include( "cl_hud.lua")
include( "ose.lua" )

local PHASE = "BUILD"

MENU = nil

local NextRound = 0
local TimeLeft = BUILDTIME
local d = true
local Lstbeep = CurTime()

function GM:Initialize( )

	GAMEMODE.ShowScoreboard = false
	surface.CreateFont( "akbar", 20, 500, true, true, "HUD" )
	surface.CreateFont( "akbar", 16, 500, true, true, "HUDs" )
	surface.CreateFont( "coolvetica", 48, 500, true, false, "ScoreboardHead" )
	surface.CreateFont( "coolvetica", 24, 500, true, false, "ScoreboardSub" )
	surface.CreateFont( "Tahoma", 16, 1000, true, false, "ScoreboardText" )
	
end

/*
function GM:ForceDermaSkin()
	return "ose"
end
*/

function GM:PlayerInitialSpawn(ply)
	ply.Class = 1
	if !SinglePlayer() then
		RunConsoleCommand("rate 10000") -- reduce lag
	end
end

function GM:SpawnMenuEnabled( )
	return false
end

function GM:SpawnMenuOpen()
	return false
end

function GM:InitPostEntity()	
end

function GM:Think()
	if TimeLeft < 10 && TimeLeft > 0 && Lstbeep + 1 < CurTime() then
		surface.PlaySound(Sound("tools/ifm/beep.wav"))
		Lstbeep = CurTime()
	end
	TimeLeft = NextRound - CurTime()
end

function GM:HUDShouldDraw(nm)
	if (nm == "CHudHealth" || nm == "CHudSecondaryAmmo" || nm == "CHudAmmo" || nm == "CHudBattery") then
		return false
	else
		return true
	end
end

function GM:HUDPaint()
	
	if GetConVarNumber( "cl_drawhud" ) == 0 then return false end
	
	if d && LocalPlayer():GetNetworkedInt( "money") == 0 then -- this bit of code stops the HUD from displaying if the usermessages haven't been sent yet
		return false
	else
		d = false
	end
	
	GAMEMODE:DrawHUD()
	GAMEMODE:HUDDrawTargetID()
	
	local W,H = ScrW(), ScrH()
	local y1,y2,y3 = 0.91,0.93,0.95
	local xH = 0.08
	local xY = 0.90
	local MonCol = Color(255,255,255,255)
	local timecol = Color(255,255,255,255)
	
	surface.SetDrawColor(50, 50, 50, 255)
	surface.DrawRect( W / 1.3, H * xY, W * 0.2, H *  xH)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawOutlinedRect( W / 1.3, H * xY, W * 0.2, H *  xH)
	
	if LocalPlayer():GetNetworkedInt( "money") <= 0 then
		MonCol = Color(255,100,100,255)
	else
		MonCol = Color(255,255,255,255)
	end
	if TimeLeft <= 30 && (math.Round(TimeLeft) / 2) == math.Round(TimeLeft / 2) then --is even
		 timecol = Color(255,100,100,255)
	end
	if TimeLeft <= 0 then TimeLeft = 0 end
	draw.DrawText("Money: "..math.Round(LocalPlayer():GetNetworkedInt( "money")), "ScoreboardText", W / 1.15 , H * y1, MonCol,1)
	draw.DrawText("Phase: "..PHASE, "ScoreboardText", W / 1.15, H * y2, Color(255,255,255,255),1)
	draw.DrawText("Time Remaining: "..string.ToMinutesSeconds(TimeLeft), "ScoreboardText", W / 1.15 , H * y3, timecol,1)
end

function GM:RenderScreenspaceEffects( )
end

CreateClientConVar("ose_hidetips", "0", true, false)

tip = TIPS[1]

function ShowTip(lst)
	if GetConVarNumber( "ose_hidetips" ) == 1 then
		timer.Simple(TIP_DELAY,ShowTip, last)
		return
	end
	surface.PlaySound( "ambient/water/drip"..math.random(1, 4)..".wav" )
	local last = lst or 0
	if last >= #TIPS then last = 0 end
	tip = TIPS[last+1]
	last = last + 1
	timer.Simple(TIP_DELAY,ShowTip, last)
end

ShowTip()

function DrawTips()
	if GetConVarNumber( "ose_hidetips" ) == 1 then return end
	local W,H = ScrW(), ScrH()
	surface.SetDrawColor(50, 50, 50, 255)
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

hook.Add("HUDPaint", "OSETIPS", DrawTips)

function UpdateTime(um)
	NextRound = CurTime() + um:ReadLong()
	PHASE = um:ReadString()
end

usermessage.Hook("updatetime", UpdateTime)

function Cl_StartBattle(um)
	NextRound = CurTime() + BATTLETIME
	PHASE = "BATTLE"
end

usermessage.Hook("StartBattle", Cl_StartBattle)

function Cl_StartBuild(um)
	NextRound = CurTime() + BUILDTIME
	PHASE = "BUILD"
end

usermessage.Hook("StartBuild", Cl_StartBuild)

function UpdateBuild(um)
	BUILDTIME = um:ReadLong()
end

usermessage.Hook("updatebuildtime", UpdateBuild)

function UpdateBattle(um)
	BATTLETIME = um:ReadLong()
end

usermessage.Hook("updatebattletime", UpdateBattle)

Messages = {}

function Message(um)
	local txt = tostring(um:ReadString())
	local coltable = string.Explode(" ", um:ReadString())
	local msg = um:ReadBool() or false
	if msg then
		print(txt)
	end
	local col = Color(coltable[1], coltable[2], coltable[3], coltable[4])
	msg = {}
	msg.id = #Messages + 1
	msg.text = txt
	msg.colour = col
	msg.Time = CurTime()
	Messages[#Messages + 1] = msg
end

usermessage.Hook("ose_msg", Message) 

function DrawPowerUp()
	for k,v in pairs(Messages) do
		local col = v.colour
		local y = (ScrH() - 200) - ((CurTime() - v.Time) * 90) + (k * 12)
		draw.SimpleTextOutlined(v.text,"ScoreboardText",ScrW() - 30,y,col,2,0,0.5,Color(50,50,50,255))
		if v.Time - CurTime() <= -4 then
			local newcol = Color(col.r,col.g,col.b,col.a - 10)
			v.colour = newcol
			if v.colour.a <= 0 then
				Messages[k] = nil
			end
		end
	end
end

hook.Add("HUDPaint","messages",DrawPowerUp)

----TargetID-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	end
	
	if ent:IsNPC( ) then
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
