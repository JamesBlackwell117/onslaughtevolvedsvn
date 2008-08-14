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

	self:SetTitle("Click on the ammo icon to buy it!")
	local ammos = 0
	for k,v in pairs(AMMOS) do
		local class = LocalPlayer():GetNWInt("class")
		if table.HasValue(Classes[class].AMMO, k) then
			local ammo = vgui.Create( "DModelPanel", self )
			ammo:SetModel(v.MODEL)
			ammo.DoClick = function( ammo ) local amt if LocalPlayer():KeyDown(IN_SPEED) then amt=3 else amt = 1 end RunConsoleCommand("buy_ammo", k, amt) end
			ammo:SetSize( 80,80 )

			local ent = ents.Create("prop_physics") -- lol ailias filthy hack
			ent:SetAngles(Angle(0,0,0))
			ent:SetPos(Vector(0,0,0))
			ent:SetModel(v.MODEL)
			ent:Spawn()
			ent:Activate()
			ent:PhysicsInit( SOLID_VPHYSICS )


			local center = ent:OBBCenter()
			local dist = ent:BoundingRadius()*1.2

			ent:Remove()

			ammo:SetLookAt( center )
			ammo:SetCamPos( center+Vector(dist,dist,dist) )


			ammo:InvalidateLayout( true )
			ammo:SetToolTip( v.NAME.." \nCost: "..v.PRICE.."\nAmount: "..v.QT )
			self.IconList:AddItem( ammo )
			ammos = ammos + 1
		end
	end
	self:SetSize( 18+ammos*80, 118)
	self:Center()
end

function PANEL:PerformLayout()
	self.IconList:StretchToParent( 4, 26, 4, 4 )
	self.IconList:InvalidateLayout()
	DFrame.PerformLayout( self )
end

function PANEL:Close()
	--self:SetVisible( false )
	RememberCursorPosition( )
	gui.EnableScreenClicker( false )
	RunConsoleCommand("ammo_closed")
	ammoup = false
	self:Remove()
end

vgui.Register( "onslaught_ammobuy", PANEL, "DFrame" )

function create()
	vgui.Create( "onslaught_ammobuy" )
	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
end

usermessage.Hook("openammo", create)