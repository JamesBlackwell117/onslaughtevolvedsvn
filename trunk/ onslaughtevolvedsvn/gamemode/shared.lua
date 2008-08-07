include("swep_fix.lua")

-- DO NOT REDISTRIBUTE THIS GAMEMODE
GM.Name 	= "Onslaught: Evolved - 1.7.6"
GM.Author 	= "Conman420, Xera, & Ailia" -- DO NOT CHANGE THIS
GM.Email 	= ""
GM.Website 	= ""
-- DO NOT REDISTRIBUTE THIS GAMEMODE

PHASE = "BUILD"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Classes = {}
Classes[1] = {NAME = "Scout", SPEED = 650, JUMP = 260, WEAPON_SET = 1, HEALTH = 100, AMMO = {2,11}, MODEL = "models/player/Group03/Female_02.mdl", 					DSCR = "A fast and agile class the scout is perfect for those who like to be in the action."}
Classes[2] = {NAME = "Soldier", SPEED = 280, JUMP = 160, ARMOR = 100, WEAPON_SET = 2, HEALTH = 200,AMMO = {1,2,8,6}, MODEL = "models/player/Group03/male_08.mdl", 	DSCR = "A perfect for those defensive players featuring a wide range of weapons the soldier is a perfect well balanced class." }
Classes[3] = {NAME = "Engineer", SPEED = 300, JUMP = 160, WEAPON_SET = 3, HEALTH = 120, AMMO = {2,4}, MODEL = "models/player/Group03/male_03.mdl", 					DSCR = "With the ability to make turrets and dispensers the engineer is truly an invaluable class."  }
Classes[4] = {NAME = "Sniper", SPEED = 270, JUMP = 160, WEAPON_SET = 4, HEALTH = 80,AMMO = {7,5,14}, MODEL = "models/player/Group03/male_06.mdl",					DSCR = "The Sniper is the useful for taking out incoming enemies but its lack of health and speed requires you to keep cover!"}
Classes[5] = {NAME = "Pyro", SPEED = 450, JUMP = 210, WEAPON_SET = 5, HEALTH = 150, AMMO = {2,10,12,8}, MODEL = "models/player/Group03/male_07.mdl", 				DSCR = "The pyro has the ability to set enemies alight and place mines to send those enemies fliying!"  }
Classes[6] = {NAME = "Support", SPEED = 500, JUMP = 220, WEAPON_SET = 6, HEALTH = 90, AMMO = {13}, MODEL = "models/player/Group03/Female_04.mdl", 					DSCR = "Acting as the team medic, the support helps keep the team alive and the base standing."  }

TAUNTS = {}
TAUNTS[1] = {"vo/episode_1/npc/female01/cit_kill02.wav","vo/npc/female01/gotone01.wav","vo/episode_1/npc/female01/cit_kill04.wav", "vo/episode_1/npc/female01/cit_kill09.wav", "vo/episode_1/npc/female01/cit_kill06.wav","vo/episode_1/npc/female01/cit_kill11.wav","vo/episode_1/npc/female01/cit_kill16.wav"}
TAUNTS[2] = {"vo/episode_1/npc/male01/cit_kill03.wav", "vo/episode_1/npc/male01/cit_kill14.wav", "vo/episode_1/npc/male01/cit_kill19.wav", "vo/npc/male02/reb2_buddykilled13.wav","vo/episode_1/npc/male01/cit_kill03.wav"}
TAUNTS[3] = {"vo/coast/odessa/male01/nlo_cheer01.wav", "vo/coast/odessa/male01/nlo_cheer02.wav", "vo/coast/odessa/male01/nlo_cheer03.wav", "vo/coast/odessa/male01/nlo_cheer04.wav" }
TAUNTS[4] = {"vo/episode_1/npc/male01/cit_kill15.wav","vo/npc/male01/gotone01.wav","vo/npc/barney/ba_gotone.wav", "vo/npc/male01/gotone02.wav"}
TAUNTS[5] = {"vo/ravenholm/monk_kill01.wav","vo/ravenholm/monk_kill03.wav","vo/ravenholm/madlaugh01.wav","vo/ravenholm/monk_kill08.wav","vo/ravenholm/monk_kill05.wav","vo/ravenholm/madlaugh02.wav", "vo/ravenholm/madlaugh04.wav"}
TAUNTS[6] = {"vo/episode_1/npc/female01/cit_kill02.wav","vo/npc/female01/gotone01.wav","vo/episode_1/npc/female01/cit_kill04.wav", "vo/episode_1/npc/female01/cit_kill09.wav", "vo/episode_1/npc/female01/cit_kill06.wav","vo/episode_1/npc/female01/cit_kill11.wav","vo/episode_1/npc/female01/cit_kill16.wav"}

WEAPON_SET = {}
WEAPON_SET[1] = {"weapon_crowbar",	"weapon_pistol",	"swep_scatter"}
WEAPON_SET[2] = {"weapon_crowbar",	"weapon_pistol", 	"weapon_ar2", 		"weapon_frag"}
WEAPON_SET[3] = {"swep_repair",		"weapon_pistol", 	"weapon_shotgun", 	"weapon_physcannon",  		"swep_dispensermaker", "swep_turretmaker" }
WEAPON_SET[4] = {"weapon_crowbar",	"weapon_357",		"swep_xbow", 		"swep_railgun"}
WEAPON_SET[5] = {"weapon_crowbar", 	"weapon_pistol", 	"swep_flamethrower","weapon_frag", 		 		"swep_minemaker"}
WEAPON_SET[6] = {"weapon_crowbar", 	"swep_healthcharge"}

DMGO = {}
DMGO["weapon_crowbar"] = 25
DMGO["swep_repair"] = 25
DMGO["weapon_pistol"] = 12
DMGO["weapon_shotgun"] = 9
DMGO["weapon_ar2"] = 11 * 1.4
DMGO["weapon_smg1"] = 12
DMGO["weapon_357"] = 50
DMGO["npc_turret_floor"] = 6
DMGO["npc_turret_ceiling"] = 6


DMGO["swep_flamethrower"] = nil
DMGO["swep_scatter"] = nil
DMGO["swep_xbow"] = nil

WEAPON_MDL = {}
WEAPON_MDL["weapon_crowbar"] = {NAME = "Crowbar", MODEL = "models/weapons/w_crowbar.mdl"}
WEAPON_MDL["swep_repair"] = {NAME = "Wrench", MODEL = "models/weapons/w_crowbar.mdl"}
WEAPON_MDL["weapon_pistol"] = {NAME = "9mm Pistol", MODEL = "models/weapons/W_pistol.mdl"}
WEAPON_MDL["swep_scatter"] = {NAME = "Super Shotgun", MODEL = "models/weapons/w_shotgun.mdl"}
WEAPON_MDL["weapon_shotgun"] = {NAME = "Shotgun", MODEL = "models/weapons/w_shotgun.mdl"}
WEAPON_MDL["weapon_frag"] = {NAME = "Frag Grenade", MODEL = "models/weapons/W_grenade.mdl"}
WEAPON_MDL["weapon_ar2"] = {NAME = "Combine Assault Rifle", MODEL = "models/weapons/w_IRifle.mdl"}
WEAPON_MDL["weapon_physcannon"] = {NAME = "Gravity Gun", MODEL = "models/weapons/w_physics.mdl"}
WEAPON_MDL["swep_turretmaker"] = {NAME = "Turret", MODEL = "models/Combine_turrets/Floor_turret.mdl"}
WEAPON_MDL["swep_flamethrower"] = {NAME = "Flamethrower", MODEL = "models/weapons/w_smg1.mdl"}
WEAPON_MDL["swep_minemaker"] = {NAME = "Mine", MODEL = "models/props_combine/combine_mine01.mdl"}
WEAPON_MDL["weapon_357"] = {NAME = ".357 Magnum Revolver", MODEL = "models/weapons/W_357.mdl"}
WEAPON_MDL["swep_xbow"] = {NAME = "Crossbow", MODEL = "models/weapons/W_crossbow.mdl"}
WEAPON_MDL["swep_railgun"] = {NAME = "Combine Railgun", MODEL = "models/weapons/w_combinesniper_e2.mdl"}
WEAPON_MDL["swep_healthcharge"] = {NAME = "Health Charger", MODEL = "models/weapons/w_physics.mdl"}


AMMOS = {}
AMMOS[1] = {AMMO = "AR2", NAME = "Pulse ammo", QT = 120, PRICE = 150, MODEL = "models/Items/combine_rifle_cartridge01.mdl"}
AMMOS[2] = {AMMO = "Pistol", NAME = "Pistol ammo", QT = 72, PRICE = 100, MODEL = "models/Items/BoxSRounds.mdl"}
AMMOS[3] = {AMMO = "SMG1", NAME = "SMG ammo", QT = 90, PRICE = 150, MODEL = "models/Items/BoxMRounds.mdl"}
AMMOS[4] = {AMMO = "BuckShot", NAME = "Buckshot", QT = 32, PRICE = 200, MODEL = "models/Items/BoxBuckshot.mdl"}
AMMOS[5] = {AMMO = "357", NAME = "357 ammo", QT = 18, PRICE = 200, MODEL = "models/Items/357ammo.mdl"}
AMMOS[6] = {AMMO = "AR2AltFire", NAME = "Combine Ball", SMULT = 2, QT = 1, PRICE = 400, MODEL = "models/Items/combine_rifle_ammo01.mdl"}
AMMOS[7] = {AMMO = "xbowbolt", NAME = "Crossbow Bolt", SMULT = 2, QT = 10, PRICE = 500, MODEL = "models/Items/CrossbowRounds.mdl"}
AMMOS[8] = {AMMO = "grenade", NAME = "Grenade", SMULT = 2, QT = 1, PRICE = 300, MODEL = "models/Items/grenadeAmmo.mdl"}
AMMOS[9] = {AMMO = "SMG1_Grenade", NAME = "Smg Grenade", QT = 1, PRICE = 250, MODEL = "models/Items/AR2_Grenade.mdl"}
AMMOS[10] = {AMMO = "AR2", NAME = "Fuel", QT = 100, PRICE = 500, MODEL = "models/props_junk/gascan001a.mdl"}
AMMOS[11] = {AMMO = "BuckShot", NAME = "Heavy Buckshot", QT = 32, PRICE = 200, MODEL = "models/Items/BoxFlares.mdl"}
AMMOS[12] = {AMMO = "SMG1", NAME = "Mine", SMULT = 2, QT = 1, PRICE = 300, MODEL = "models/props_combine/combine_mine01.mdl"}
AMMOS[13] = {AMMO = "grenade", NAME = "Repair Grenade", SMULT = 2, QT = 1, PRICE = 300, MODEL = "models/weapons/w_magnade.mdl"}
AMMOS[14] = {AMMO = "AR2AltFire", NAME = "Core Energy", SMULT = 2, QT = 1, PRICE = 600, MODEL = "models/Effects/combineball.mdl"}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

NPCS = {}
NPCS["npc_combine_s"] = {}
NPCS["npc_combine_s"][1] =		{FLAGS = 403204, MONEY = 100, 	MODEL = "models/combine_soldier.mdl", 	  			KEYS = "tacticalvariant 1 additionalequipment weapon_smg1 model models/combine_soldier.mdl NumGrenades 999999 wakeradius 999999"}
NPCS["npc_combine_s"][2] =		{FLAGS = 403204, MONEY = 140, 	MODEL = "models/combine_super_soldier.mdl", 		KEYS = "tacticalvariant 1 additionalequipment weapon_ar2 model models/combine_super_soldier.mdl wakeradius 999999"}
NPCS["npc_combine_s"][3] =		{FLAGS = 403204, MONEY = 120, 	MODEL = "models/combine_soldier_prisonguard.mdl", 	KEYS = "tacticalvariant 1 additionalequipment weapon_shotgun model models/combine_soldier_prisonguard.mdl NumGrenades 999999 wakeradius 999999"}
NPCS["npc_metropolice"]  = 		{FLAGS = 403204, MONEY = 50,  	MODEL = "models/police.mdl",			  			KEYS = "additionalequipment weapon_pistol"}
NPCS["npc_hunter"]  = 			{FLAGS = 9984, 	 MONEY = 500, 	MODEL = "models/hunter.mdl"}
NPCS["npc_manhack"]  = 			{FLAGS = 263940, MONEY = 50,  	MODEL = "models/manhack.mdl"}
NPCS["npc_zombie"]  = 			{FLAGS = 1796, 	 MONEY = 75,  	MODEL = "models/zombie/classic.mdl"}
NPCS["npc_fastzombie"]  = 		{FLAGS = 1796,   MONEY = 100, 	MODEL = "models/zombie/fast.mdl"}
NPCS["npc_zombine"]  = 			{FLAGS = 1796,   MONEY = 100, 	MODEL = "models/zombie/zombie_soldier.mdl"}
NPCS["npc_antlion"] = 			{FLAGS = 9984,   MONEY = 100, 	MODEL = "models/antlion.mdl", 	 		  			KEYS = "radius 512"}
NPCS["npc_headcrab"] = 			{FLAGS = 1796,   MONEY = 33,  	MODEL = "models/headcrabclassic.mdl"}
NPCS["npc_headcrab_fast"] = 	{FLAGS = 1796,   MONEY = 40,  	MODEL = "models/headcrab.mdl"}
NPCS["npc_antlionguard"] = 		{FLAGS = 9988,   MONEY = 700, 	MODEL = "models/antlion_guard.mdl"}
NPCS["npc_rollermine"] = 		{FLAGS = 9988,   MONEY = 175, 	MODEL = "models/roller.mdl", 		 		  		KEYS = "uniformsightdist 1"}
NPCS["npc_poisonzombie"] = 		{FLAGS = 9988,   MONEY = 125, 	MODEL = "models/zombie/poison.mdl",		  			KEYS = "crabcount 3"}
NPCS["npc_headcrab_black"] =	{FLAGS = 9988,   MONEY = 120, 	MODEL = "models/headcrabblack.mdl"}
NPCS["npc_zombie_torso"] = 		{FLAGS = 1796, 	 MONEY = 50,  	MODEL = "models/zombie/classic.mdl"}
NPCS["npc_fastzombie_torso"] = 	{FLAGS = 1796,   MONEY = 75,	MODEL = "models/zombie/fast.mdl"}

npcs = {
	npc_combine_s = "Combine Soldier",
	npc_hunter = "Hunter",
	npc_antlion = "Antlion",
	npc_manhack = "Manhack",
	npc_zombie = "Zombie",
	npc_zombie_torso = "Zombie",
	npc_zombine = "Zombine",
	npc_fastzombie = "Fast zombie",
	npc_fastzombie_torso = "Fast zombie",
	npc_headcrab = "Headcrab",
	npc_headcrab_fast = "Fast headcrab",
	npc_headcrab_black = "Poison headcrab",
	npc_metropolice = "Metro Police",
	npc_rollermine = "Rollermine",
	npc_poisonzombie = "Poison zombie",
	npc_antlionguard = "Antlion Guard"
}

Zombies = {"npc_zombine", "npc_zombie", "npc_fastzombie", "npc_antlion", "npc_antlionguard", "npc_poisonzombie"}

TIPS = {"Press reload with your physgun to delete the prop you are looking at.",
		"To earn money to spawn props, kills NPCs in the battle phase.",
		"As an engineer, you can only make dispensers on vertical walls.",
		"Remember, all props are destructable in Onslaught Evolved so one layer will not do!",
		"Type !give <partial player name> <amount to give> to give a player money",
		"As an engineer, your wrench tool - slot 2 - is a vital repairing and killing tool.",
		"Dieing less in battle round keeps your \'live bonus\' high!",
		"As a scout keep moving to avoid enemy fire.",
		"To hide this bar, type \"ose_hidetips 1\" in the console!",
		"As an engineer, you building spawning weapons are on slot 3",
		"Want to make your base neater? The no-collide SWEP is in weapon slot 2.",
		"As a soldier, you have 200 health, so don't be afraid to get out on the front line.",
		"Say !spawn to set a custom spawnpoint where you are standing",
		"say !resetspawn to reset your custom spawnpoint",
		"say !voteskip to vote to skip the build phase"
		}
		
TIP_DELAY = 30

team.SetUp( 1, "Dead", Color( 70, 70, 70, 255 ) )

RANKS = {}
RANKS[1] = {NAME = "Recruit", KILLS = 0, COLOR = Color( 255, 255, 255, 255 )}
RANKS[2] = {NAME = "Private", KILLS = 200, COLOR = Color( 80, 150, 80, 255 )}
RANKS[3] = {NAME = "Corporal", KILLS = 500, COLOR = Color( 100, 70, 70, 255 )}
RANKS[4] = {NAME = "Sergeant", KILLS = 1000, COLOR = Color( 20, 80, 20, 255 )}
RANKS[5] = {NAME = "Second Lieutenant", KILLS = 2000, COLOR = Color( 200, 100, 100, 255 )}
RANKS[6] = {NAME = "Lieutenant", KILLS = 3000, COLOR = Color( 255, 100, 100, 255 )}
RANKS[7] = {NAME = "Captain", KILLS = 5000, COLOR = Color( 50, 50, 80, 255 )}
RANKS[8] = {NAME = "General", KILLS = 8000, COLOR = Color( 50, 50, 50, 255 )}
RANKS[9] = {NAME = "Commander", KILLS = 15000, COLOR = Color( 105, 255, 105, 255)}
RANKS[10] = {NAME = "Jesus", KILLS = 20000, COLOR = Color( 255, 105, 180, 255)}
RANKS[11] = {NAME = "Fuckin' Godlike", KILLS = 30000, COLOR = Color(255, 0, 0,255)}
RANKS[12] = {NAME = "Ultimate Epic of Epicness", KILLS = 60000, COLOR = Color( 255, 100, 100, 255 )}


for k,v in pairs(RANKS) do
	team.SetUp( k + 1, v.NAME, v.COLOR )  -- yay for awesome ranks
end

--VARIABLES---
	--Core Gamemode Vars--
	BUILDTIME = 600
	BATTLETIME = 900
	MINBATTLETIME = 600
	SPAWN_TIME = 30 -- this is the base spawn time. The game adds 10 seconds to the spawn time for every player present on the server. So if there were 8 players the spawn time would be 30 + 80.
	ANTILAG = false --turn on with caution!
	BUILD_NOCLIP = true -- whether or not noclip should be allowed in build
	VOTE_TIME = 30 -- how long players have to vote for a map.
	VOTE_ENABLE_TIME = 660 -- how long the current map has to go on for until map voting is allowed -- once a vote has passed it redisables it then reenables it again after this time.
	PROP_DELETE_TIME = 180 -- how long a player has to leave for until his money and props are deleted.
	
	MODELS =   {}
	MODELS["models/props_c17/display_cooler01a.mdl"] = {ANG = Angle(0,-90,0), GROUP = 4, NAME = "Rack"}
	MODELS["models/props_c17/furnitureStove001a.mdl"] = {GROUP = 2, NAME = "Stove"}
	MODELS["models/props_combine/breendesk.mdl"] = {GROUP = 2, NAME = "Desk"}
	MODELS["models/props_lab/blastdoor001c.mdl"] = {GROUP = 1, NAME = "Blast Door"}
	MODELS["models/props_lab/blastdoor001b.mdl"] = {GROUP = 1, NAME = "Blast Door"}
	MODELS["models/props_junk/wood_crate001a.mdl"] = {GROUP = 2, NAME = "Crate"}
	MODELS["models/props_junk/wood_crate002a.mdl"] = {GROUP = 2, NAME = "Crate"}
	MODELS["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {GROUP = 5}
	MODELS["models/props_wasteland/wood_fence01a.mdl"] = {ANG = Angle(0,90,0), GROUP = 1, NAME = "Fence"}
	MODELS["models/props_wasteland/wood_fence02a.mdl"] = {ANG = Angle(0,90,0), GROUP = 1, NAME = "Fence"}
	MODELS["models/props_wasteland/kitchen_counter001b.mdl"] = {GROUP = 2, NAME = "Table"}
	MODELS["models/props_interiors/VendingMachineSoda01a_door.mdl"] = {GROUP = 1, NAME = "Vending Machine Door"}
	MODELS["models/props_interiors/VendingMachineSoda01a.mdl"] = {GROUP = 2, NAME = "Vending Machine"}
	MODELS["models/props_pipes/concrete_pipe001a.mdl"] = {GROUP = 4, NAME = "Pipe"}
	--MODELS["models/props_docks/dock01_pole01a_128.mdl"] = {GROUP = 3} -- hacky prop
	MODELS["models/props_c17/door01_left.mdl"] = {GROUP = 5, NAME = "Door"}
	MODELS["models/props_c17/shelfunit01a.mdl"] = {ANG = Angle(0,-90,0),GROUP = 1, NAME = "Shelf"}
	MODELS["models/props_interiors/Furniture_Couch02a.mdl"] = {GROUP = 5, NAME = "Couch"}
	MODELS["models/props_wasteland/kitchen_fridge001a.mdl"] = {GROUP = 2, NAME = "Fridge"}
	MODELS["models/props_wasteland/kitchen_stove002a.mdl"] = {GROUP = 2, NAME = "Large Stove"}
	MODELS["models/props_combine/combine_barricade_short01a.mdl"] = {ANG = Angle(0,180,0),GROUP = 4, NAME = "Combine Barricade"}
	MODELS["models/props_junk/TrashDumpster02b.mdl"] = {GROUP = 4, NAME = "Dumpster"}
	MODELS["models/props_c17/oildrum001.mdl"] = {GROUP = 5, NAME = "Oil Drum"}
	MODELS["models/props_c17/gravestone_coffinpiece002a.mdl"] = {GROUP = 3, NAME = "Gravestone"}
	MODELS["models/props_junk/PushCart01a.mdl"] = {GROUP = 5, NAME = "Cart"}
	MODELS["models/props_c17/FurnitureCouch001a.mdl"] = {GROUP = 5, NAME = "Couch"}
	MODELS["models/props_wasteland/laundry_cart001.mdl"] = {GROUP = 5, NAME = "Cart"}
	--MODELS["models/props_trainstation/handrail_64decoration001a.mdl"] = {GROUP = 3}
	MODELS["models/props_trainstation/traincar_rack001.mdl"] = {GROUP = 3, NAME = "Rack"}
	MODELS["models/props_wasteland/laundry_basket001.mdl"] = {GROUP = 5, NAME = "Basket"}
	MODELS["models/props_wasteland/prison_celldoor001a.mdl"] = {GROUP = 1, NAME = "Cell Door"}
	--MODELS["models/props_rooftop/chimneypipe01a.mdl"] = {GROUP = 3}
	MODELS["models/props_wasteland/prison_bedframe001b.mdl"] = {GROUP = 5, NAME = "Bedframe"}
	MODELS["models/props_junk/iBeam01a.mdl"] = {ANG = Angle(0,-90,0),GROUP = 3, NAME = "I-Beam"}
	MODELS["models/props_debris/metal_panel01a.mdl"] = {GROUP = 1, NAME = "Sheet Metal"}
	MODELS["models/props_debris/metal_panel02a.mdl"] = {GROUP = 1, NAME = "Sheet Metal"}
	MODELS["models/props_c17/concrete_barrier001a.mdl"] = {GROUP = 4, NAME = "Barricade"}
	--MODELS["models/props_c17/playgroundTick-tack-toe_post01.mdl"] = {GROUP = 5}
	MODELS["models/props_c17/FurnitureFridge001a.mdl"] = {GROUP = 2, NAME = "Fridge"}
	
	MODELS["models/props_c17/metalladder002.mdl"] = {GROUP = 6, COST = 800, CLASS = "sent_ladder", NAME = "Ladder", LIMIT = 3}
	
	MODELS["models/Items/ammocrate_smg1.mdl"] = {GROUP = 6, CLASS = "sent_ammo_dispenser", NAME = "Ammo Crate", LIMIT = 1}
	
	MODELS["models/Combine_turrets/Floor_turret.mdl"] = {ANG = Angle(0,180,0),GROUP = 6, PLYCLASS = 3, CLASS = "npc_turret_floor", NAME = "Turret", LIMIT = 2, COST = 700, EXTBUILD = nil, ALLOWBATTLE = true, RANGE = 200}
	
	MODELS["models/props_combine/combine_mine01.mdl"] = {GROUP = 6, PLYCLASS = 5, CLASS = "ose_mines", NAME = "Mine", LIMIT = 10, COST = 300, EXTBUILD = nil, ALLOWBATTLE = true, RANGE = 150}	
	
	MODELS["models/props_combine/health_charger001.mdl"] = {GROUP = 6, CLASS = "sent_dispenser", NAME = "Dispenser", LIMIT = 1, COST = 600, EXTBUILD = nil, DONTSPAWN = true, RANGE = 200}	
	
	MODELS["models/Combine_turrets/Ceiling_turret.mdl"] = {SPAWNFLAGS = "32", ANG = Angle(0,180,0),GROUP = 6, PLYCLASS = 3, CLASS = "npc_turret_ceiling", NAME = "Turret", LIMIT = 2, COST = 700, EXTBUILD = nil, ALLOWBATTLE = true, RANGE = 200}

	if SERVER then
		include("extbuild.lua")
	end
	
	MODELGROUPS = {}
	MODELGROUPS[1] = "Walls"
	MODELGROUPS[2] = "Boxes"
	MODELGROUPS[3] = "Beams"
	MODELGROUPS[4] = "Other"
	MODELGROUPS[5] = "Junk"
	MODELGROUPS[6] = "Special"
				
	for k,v in pairs(MODELS) do
		util.PrecacheModel(k)
	end
	
	for k,v in pairs(Classes) do
		util.PrecacheModel(v.MODEL)
	end
	
	for k,v in pairs(NPCS) do
		if v[1] then 
			for _,x in pairs(v) do
				util.PrecacheModel(x.MODEL)
			end
		else
			util.PrecacheModel(v.MODEL)
		end
	end
	
	--MONEY VARIABLES--
	STARTING_MONEY = 20000
	
	LADDER_COST = 800
	LIVE_BONUS = 5000
	DEATH_PENALTY = -1500

	--PROP VARS--
	FLAMABLE_PROPS = false
	PROP_CLEANUP = false
	PROP_LIMIT = 25

	--NETWORK VARS--
	PING_LIMIT = 300 -- This is NOT a ping kicker this is where if the gamemode feels that everyone is getting a bit laggy then start lowering the max npcs available :)
	
	--NPC Spawner Vars--
	MAXHUNTERS = 2
	MAXHACKS = 7
	SPAWN_DELAY = .5
	S_MAX_NPCS, MAX_NPCS = 60,30 -- S is for singleplayer normal is multiplayer
	
	--turret vars--
	TURRET_COST = 700
	DISP_COST = 600
	DISP_RATE = 50 -- lower is faster
	TURRET_HEALTH = 100
