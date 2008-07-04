local ammoup = false

local PANEL = { }

function PANEL:Init( )
	ammoup = true
	self.IconList = vgui.Create( "DPanelList", self )
	self.IconList:EnableVerticalScrollbar( true ) 
 	self.IconList:EnableHorizontal( true ) 
 	self.IconList:SetPadding( 4 ) 
	self.IconList:SetVisible( true ) 
	self:SetDraggable(false)
	self:SetSize( 258, 278)
	self:Center()
	
	self:SetTitle("Click on the ammo icon to buy it!")
	
	for k,v in pairs(AMMOS) do
		local class = LocalPlayer():GetNWInt("class")
		if table.HasValue(Classes[class].AMMO, k) then
			local ammo = vgui.Create( "SpawnIcon", self )
			ammo:SetModel(v.MODEL)
			ammo.DoClick = function( ammo ) RunConsoleCommand("buy_ammo", k) end
			ammo:SetIconSize( 80 )
			ammo:InvalidateLayout( true )
			ammo:SetToolTip( Format( "%s", v.NAME.." \nCost: "..v.PRICE.."\nAmount: "..v.QT ) ) 
			self.IconList:AddItem( ammo )
		end
	end

end

function PANEL:PerformLayout()
 	self.IconList:StretchToParent( 4, 26, 4, 4 ) 
 	self.IconList:InvalidateLayout() 
 	DFrame.PerformLayout( self )
end

function PANEL:Close()
 	self:SetVisible( false ) 
   	RememberCursorPosition( )
	gui.EnableScreenClicker( false )
	self:Remove()
	
	ammoup = false
end

vgui.Register( "onslaught_ammobuy", PANEL, "DFrame" )

function create()
	if ammoup == true then return end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
	vgui.Create( "onslaught_ammobuy" )
end

usermessage.Hook("openammo", create)