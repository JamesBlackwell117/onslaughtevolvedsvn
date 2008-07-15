local ammoup = false

local PANEL = { }

function PANEL:Init( )
	ammoup = true
	AMMO = self
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
		print(v.NAME)
		if table.HasValue(Classes[class].AMMO, k) then
			local ammo = vgui.Create( "SpawnIcon", self.IconList )
			ammo:SetModel(v.MODEL)
			ammo.DoClick = function( ammo ) RunConsoleCommand("buy_ammo", k) end
			ammo:SetIconSize( 80 )
			ammo:InvalidateLayout( true )
			ammo:SetToolTip( v.NAME.." \nCost: "..v.PRICE.."\nAmount: "..v.QT ) 
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
	RunConsoleCommand("ammo_closed")
	ammoup = false
end

vgui.Register( "onslaught_ammobuy", PANEL, "DFrame" )

function create()
	if AMMO == nil or not AMMO:IsValid( ) then
		vgui.Create( "onslaught_ammobuy" )
	else
		AMMO:SetVisible( true )
	end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
end

usermessage.Hook("openammo", create)


local matHover = Material( "vgui/spawnmenu/hover" )

local PANEL = {}

AccessorFunc( PANEL, "m_iIconSize", 		"IconSize" )

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	self.Icon = vgui.Create( "ModelImage", self )
	self.Icon:SetMouseInputEnabled( false )
	self.Icon:SetKeyboardInputEnabled( false )
	
	self.animPress = Derma_Anim( "Press", self, self.PressedAnim )
	
	self:SetIconSize( 64 ) // Todo: Cookie!

end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )

	if ( mcode == MOUSE_LEFT ) then
		self:DoClick()
		self.animPress:Start( 0.2 )
	end

end

function PANEL:OnMouseReleased()
end

/*---------------------------------------------------------
   Name: DoClick
---------------------------------------------------------*/
function PANEL:DoClick()
end

/*---------------------------------------------------------
   Name: OpenMenu
---------------------------------------------------------*/
function PANEL:OpenMenu()
end

/*---------------------------------------------------------
   Name: OnMouseReleased
---------------------------------------------------------*/
function PANEL:OnCursorEntered()

	self.PaintOverOld = self.PaintOver
	self.PaintOver = self.PaintOverHovered

end

/*---------------------------------------------------------
   Name: OnMouseReleased
---------------------------------------------------------*/
function PANEL:OnCursorExited()

	if ( self.PaintOver == self.PaintOverHovered ) then
		self.PaintOver = self.PaintOverOld
	end

end

/*---------------------------------------------------------
   Name: PaintOverHovered
---------------------------------------------------------*/
function PANEL:PaintOverHovered()

	if ( self.animPress:Active() ) then return end

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( matHover )
	self:DrawTexturedRect()

end

/*---------------------------------------------------------
   Name: OnMouseReleased
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( self.m_iIconSize, self.m_iIconSize )	
	self.Icon:StretchToParent( 0, 0, 0, 0 )

end

/*---------------------------------------------------------
   Name: PressedAnim
---------------------------------------------------------*/
function PANEL:SetModel( mdl, iSkin )

	if (!mdl) then debug.Trace() return end

	self.Icon:SetModel( mdl, iSkin )

end


/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()

	self.animPress:Run()

end

/*---------------------------------------------------------
   Name: PressedAnim
---------------------------------------------------------*/
function PANEL:PressedAnim( anim, delta, data )

	if ( anim.Started ) then
	end
	
	if ( anim.Finished ) then
		self.Icon:StretchToParent( 0, 0, 0, 0 )
	return end

	local border = math.sin( delta * math.pi ) * ( self.m_iIconSize * 0.1 )
	self.Icon:StretchToParent( border, border, border, border )

end

/*---------------------------------------------------------
   Name: RebuildSpawnIcon
---------------------------------------------------------*/
function PANEL:RebuildSpawnIcon()

	self.Icon:RebuildSpawnIcon()

end


vgui.Register( "SpawnIcon", PANEL, "Panel" )
