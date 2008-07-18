//Conman, Xera

include( "shared.lua" )
include( "cl_scoreboard.lua" )
include( "cl_deathnotice.lua" )
include( "cl_panels.lua" )
include( "cl_hud.lua")
include( "ose.lua" )

PHASE = "BUILD"

MENU = nil

NextRound = 0
TimeLeft = BUILDTIME
local d = true
local Lstbeep = CurTime()

function GM:Initialize( )

	GAMEMODE.ShowScoreboard = false
	surface.CreateFont( "akbar", 20, 500, true, true, "HUD" )
	surface.CreateFont( "akbar", 20, 600, true, false, "HUD2" )
	surface.CreateFont( "akbar", 16, 500, true, true, "HUDs" )
	surface.CreateFont( "coolvetica", 48, 500, true, false, "ScoreboardHead" )
	surface.CreateFont( "coolvetica", 24, 500, true, false, "ScoreboardSub" )
	surface.CreateFont( "Tahoma", 16, 1000, true, false, "ScoreboardText" )
	surface.CreateFont( "Tahoma", 18, 1000, true, false, "Message" )
	
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
end

function GM:RenderScreenspaceEffects( )
end

CreateClientConVar("ose_hidetips", "0", true, false)
CreateClientConVar("ose_hud", "0", true, false)


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

local function GetTargetPos(ent)
	local attach = nil
	if ent:IsPlayer() 
	|| ent:GetModel() == "models/zombie/classic.mdl"
	 || ent:GetModel() == "models/zombie/zombie_soldier.mdl"
	  || ent:GetModel() == "models/combine_soldier.mdl"
	  || ent:GetModel() == "models/combine_super_soldier.mdl"
	  || ent:GetModel() == "models/combine_soldier_prisonguard.mdl"
	   || ent:GetModel() == "models/police.mdl"
	    || ent:GetModel() == "models/zombie/fast.mdl"
	     || ent:GetModel() == "models/zombie/poison.mdl" then
		attach = ent:GetAttachment(2)
		end
		
		if attach then
			if ent:GetModel() == "models/zombie/classic.mdl" || ent:GetModel() == "models/zombie/zombie_soldier.mdl" then
				return attach.Pos + ent:GetAngles():Forward() * 2
			elseif ent:GetModel() == "models/police.mdl" || ent:GetModel() == "models/combine_super_soldier.mdl" || ent:GetModel() == "models/combine_soldier_prisonguard.mdl" || ent:GetModel() == "models/combine_soldier.mdl" then
				return attach.Pos + ent:GetAngles():Forward() * 8 + ent:GetAngles():Up() * 4 + ent:GetAngles():Right() * 4
			elseif ent:GetModel() == "models/zombie/fast.mdl" then
				return attach.Pos + ent:GetAngles():Forward() * 2
			else
				return attach.Pos
			end
		end
				
	return ent:OBBCenter() 
end

function MdlMessage(um)
	local mdl = tostring(um:ReadString())
	local txt = tostring(um:ReadString())
	local coltable = string.Explode(" ", um:ReadString())
	local msg = um:ReadBool() or false
	--if msg then
	--	print(txt)
	--end
	--local col = Color(coltable[1], coltable[2], coltable[3], coltable[4])
	--msg = {}
	--msg.id = #Messages + 1
	--msg.text = txt
	--msg.colour = col
	--msg.Time = CurTime()
	--Messages[#Messages + 1] = msg
	
	
	local mdlmsg = vgui.Create( "onslaught_message" )
	mdlmsg.mdl:SetModel(mdl)
	mdlmsg.mdl:SetSize( 80,80 )
			
	local ent = ents.Create("prop_physics") -- lol ailias filthy hack
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(Vector(0,0,0))
	ent:SetModel(mdl)
	ent:Spawn()
	ent:Activate()
	ent:PhysicsInit( SOLID_VPHYSICS )    

	local dist = ent:BoundingRadius()*1.2
	local center = GetTargetPos(ent)
	--if center == ent:OBBCenter() then dist = ent:BoundingRadius()*1.2 else dist = ent:BoundingRadius()/3 end
			
	ent:Remove()
			
	mdlmsg.mdl:SetLookAt( center )
	mdlmsg.mdl:SetCamPos( center+Vector(-dist,-dist,dist) )
	mdlmsg.mdl:SetPos(244,20)

end

usermessage.Hook("ose_mdl_msg", MdlMessage) 