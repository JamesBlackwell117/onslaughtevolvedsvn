
local white = Color(255,255,255,255)
local ose_dark = Color( 50, 50, 50, 255 )
local ose_dark_sleep = Color( 50, 50, 50, 50 )

local SKIN = {}

// These are used in the settings panel

SKIN.PrintName 		= "Onslaught: Evolved"
SKIN.Author 		= "conman420"
SKIN.DermaVersion	= 1

SKIN.colOutline	= white

// You can change the colours from the Default skin

SKIN.bg_color 					= ose_dark
SKIN.bg_color_sleep 			= ose_dark
SKIN.bg_color_dark				= ose_dark
SKIN.bg_color_bright			= ose_dark

SKIN.colPropertySheet 			= white
SKIN.panel_transback			= ose_dark

SKIN.colTab			 			= ose_dark
SKIN.colTabText		 			= white
SKIN.colTabInactive				= Color( 100, 100, 100, 155 )
SKIN.colTabTextInactive			= white
SKIN.fontTab					= "HUDs"

SKIN.text_bright				= white
SKIN.text_normal				= white
SKIN.text_dark					= white
SKIN.text_highlight				= Color( 255, 20, 20, 255 )

SKIN.colCategoryText			= Color( 255, 255, 255, 255 )
SKIN.colCategoryTextInactive	= Color( 255, 255, 255, 255 )
SKIN.fontCategoryHeader			= "HUDs"

SKIN.fontButton					= "HUDs"
SKIN.fontFrame					= "HUDs"

derma.DefineSkin( "ose", "Derma Skin for Onslaught Evolved", SKIN )