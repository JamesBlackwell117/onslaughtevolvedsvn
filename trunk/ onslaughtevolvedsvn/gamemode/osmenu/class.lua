// Xera

local PANEL = { }

local bCursorEnter = function( b )
	if b.m_colTextHovered then DLabel.ApplySchemeSettings( self ) end
end

local bCursorExit = function( b )
	if b.m_colTextHovered then DLabel.ApplySchemeSettings( self ) end
end

function PANEL:Init( )
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Click on a button to choose a class." )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SizeToContents( )
	self.Buttons = { }
	
	for k,v in pairs( Classes ) do
		local b = vgui.Create( "DButton", self )
		b:SetText( v.NAME )
		b.ClassIndex = k
		b.Hovered = false
		if v.NAME == "Scout" then
			b:SetDisabled( true )
		end
		
		function b.DoClick( b )
			for k,v in pairs( self.Buttons ) do
				v:SetDisabled( false )
			end
			b:SetDisabled( true )
			RunConsoleCommand( "Join_Class", tostring( b.ClassIndex ) )
		end
		b:SetTooltip( v.DSCR )
		table.insert( self.Buttons, b )
	end
end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	self.Label:SetPos( 2, 2 )
	local y = self.Label:GetTall( ) + 4
	for k,v in pairs( self.Buttons ) do
		v:SetPos( 2, y )
		v:SetSize( self:GetWide( ) - 4, 25 )
		y = y + 27
	end
end

vgui.Register( "onslaught_classselect", PANEL, "DPanel" )