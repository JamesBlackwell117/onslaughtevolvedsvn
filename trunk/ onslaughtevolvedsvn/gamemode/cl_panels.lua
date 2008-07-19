if SERVER then
	AddCSLuaFile( "osmenu/admin.lua" )
	AddCSLuaFile( "osmenu/class.lua" )
	AddCSLuaFile( "osmenu/prop_spawn.lua" )
	AddCSLuaFile( "osmenu/fileload.lua" )
	AddCSLuaFile( "osmenu/Ammo_buy.lua")
	AddCSLuaFile( "osmenu/commands.lua" )
	AddCSLuaFile( "osmenu/mapload.lua" )
	AddCSLuaFile( "osmenu/player_stats.lua" )
	AddCSLuaFile( "osmenu/Message.lua" )
	return
end

include( "osmenu/admin.lua" )
include( "osmenu/class.lua" )
include( "osmenu/prop_spawn.lua" )
include( "osmenu/fileload.lua" )
include( "osmenu/Ammo_buy.lua" )
include( "osmenu/commands.lua" )
include( "osmenu/mapload.lua")
include( "osmenu/Message.lua")
include( "osmenu/player_stats.lua")

local W, H = ScrW(), ScrH()

function GM:OnSpawnMenuOpen( )
	if MENU == nil or not MENU:IsValid( ) then
		vgui.Create( "onslaught_menu" )
	else
		MENU:SetVisible( true )
	end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
end

function GM:OnSpawnMenuClose( )
	if MENU and MENU:IsValid( ) and MENU:IsVisible( ) then
		MENU:SetVisible( false )
	end
	RememberCursorPosition( )
	gui.EnableScreenClicker( false )
end

local PANEL = { }

function PANEL:Init( )

	MENU = self
	self:SetSize( 400, 350 )
	self:SetPos(0,W * 0.024)
	--self:SetDraggable(false)
	self:SetTitle( "Onslaught Menu" )
	self.ContentPanel = vgui.Create( "DPropertySheet", self )
	self:ShowCloseButton( false )
	local HelpLab = vgui.Create("DImage")
	HelpLab:SetImage("onslaught/helpmenu")
	HelpLab:SizeToContents( )
	local HelpList = vgui.Create("DPanelList")
	HelpList:AddItem(HelpLab)
	HelpList:EnableVerticalScrollbar(true)
	HelpList:EnableHorizontal()
	HelpList:SetPos(2,60)
	HelpList:SetSize(348,270)
	

	self.ContentPanel:AddSheet( "Help", HelpList, "onslaught/help", true, true )
	self.ContentPanel:AddSheet( "Class", vgui.Create( "onslaught_classselect", self ), "gui/silkicons/group", true, true )
	self.ContentPanel:AddSheet( "Build", vgui.Create( "onslaught_PropSpawn", self ), "onslaught/bricks", true, true )
	self.ContentPanel:AddSheet( "Commands", vgui.Create("onslaught_commands", self), "onslaught/help", true, true )
	self.ContentPanel:AddSheet( "Settings and Stats", vgui.Create("onslaught_stats", self), "onslaught/help", true, true )
	
	if LocalPlayer( ):IsAdmin( ) then
		self.ContentPanel:AddSheet( "Admin", vgui.Create( "onslaught_admin", self ), "onslaught/bricks", true, true )
	end
	
end

function PANEL:Close( )
	menuup = false
 	self:Remove( )
end

function PANEL:PerformLayout( )

	self.ContentPanel:StretchToParent( 4, 26, 4, 4 )
	
	DFrame.PerformLayout( self )

end

vgui.Register( "onslaught_menu", PANEL, "DFrame" )

