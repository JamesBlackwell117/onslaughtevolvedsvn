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

	self.ListList = vgui.Create( "DPanelList", self )
	self.List = {}
	self.ListCollapse = {}
			
	for k,v in pairs (Classes) do
		self.ListCollapse[k] = vgui.Create( "DCollapsibleCategory", self.ListList )
		self.ListCollapse[k]:SetSize( 610,20 ) 
		self.ListCollapse[k]:SetLabel( v.NAME ) 
		self.ListCollapse[k]:SetVisible( true ) 
		self.ListCollapse[k]:SetExpanded( 0 )
		self.ListList:AddItem( self.ListCollapse[k] )
		self.ListCollapse[k].Header.OnMousePressed = function(mcode)
			for k,v in pairs (self.ListCollapse) do
				if v:GetExpanded() == true then v:Toggle() end
			end
			self.ListCollapse[k]:Toggle()
			RunConsoleCommand( "Join_Class", tostring( k ) )
		end
		
		self.List[k] = vgui.Create( "DPanelList", self.ListCollapse[k] )
		self.List[k]:EnableVerticalScrollbar( false ) 
 		self.List[k]:EnableHorizontal( true ) 
 		self.List[k]:SetPadding( 4 ) 
		self.List[k]:SetVisible( true ) 
		self.ListCollapse[k]:SetContents(self.List[k])
		
		local text = vgui.Create("DLabel",self.List[k])
		text:SetText(v.DSCR)
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,5)
		
		text = vgui.Create("DLabel",self.List[k])
		text:SetText("Health: "..v.HEALTH)
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,20)
			
		text = vgui.Create("DLabel",self.List[k])
		if v.ARMOR then	text:SetText("Armor: "..v.ARMOR) else text:SetText("Armor: 0") end
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,35)
		
		text = vgui.Create("DLabel",self.List[k])
		text:SetText("Speed: "..math.Round(v.SPEED/3).."%")
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,50)
	
		text = vgui.Create("DLabel",self.List[k])
		text:SetText("Jump: "..math.Round(v.JUMP/1.6).."%")
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,65)
		
		local bpos = 80
		
		for _,w in pairs(WEAPON_SET[k])do
			if WEAPON_MDL[w] then
				local ent = ents.Create("prop_physics") -- lol ailias filthy hack
				ent:SetAngles(Angle(0,0,0))
				ent:SetPos(Vector(0,0,0))
				ent:SetModel(WEAPON_MDL[w].MODEL)
				ent:Spawn()
				ent:Activate()
				ent:PhysicsInit( SOLID_VPHYSICS )   
				local ico = vgui.Create( "DModelPanel", self.List[k] )
				ico:SetModel(WEAPON_MDL[w].MODEL)
				ico.Skin = math.random(0,util.GetModelInfo(k).SkinCount-1)
				ico.Entity:SetSkin(ico.Skin)
				ico:SetSize(80,80)	
				ico:SetPos(bpos,20)
				bpos = bpos + 80

				if ValidEntity(ent:GetPhysicsObject()) then
					local center = ent:OBBCenter()
					local dist = ent:BoundingRadius()*1.2
					ico:SetLookAt( center )
					ico:SetCamPos( center+Vector(dist,dist,dist) )
				end
			
				ico:SetToolTip( WEAPON_MDL[w].NAME ) 
				ico:InvalidateLayout( true ) 
				ent:Remove()
			end
		end
	end
	self.ListCollapse[1]:SetExpanded( 1 )	
	
	local dtab = vgui.Create( "DCollapsibleCategory", self.ListList )
	dtab:SetSize( 610,20 ) 
	dtab:SetLabel( "Default Class" )
	dtab:SetVisible( true ) 
	dtab:SetExpanded( 1 )
	
	self.ListList:AddItem( dtab )
	
	self.ClassList = vgui.Create("DMultiChoice", self)
	self.ClassList:SetText("Default Class")
	self.ClassList:SetConVar("ose_defaultclass")
	for k,v in pairs(Classes) do
		self.ClassList:AddChoice(v.NAME)
	end
	self.ClassList:SizeToContents()
	
	dtab:SetContents(self.ClassList)
	
	self.ListList:AddItem( self.ClassList )

	
end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	self.Label:SetPos( 2, 2 )
	self.ListList:StretchToParent( 4, 26, 4, 4 ) 
 	self.ListList:InvalidateLayout() 
	for k,v in pairs (self.List) do
		v:SetSize(360+256,100)
 		v:InvalidateLayout() 
	end
	for k,v in pairs (self.ListCollapse) do
		v:SizeToContents( )
 		v:InvalidateLayout() 
	end
	self:SizeToContents( )
end

vgui.Register( "onslaught_classselect", PANEL, "DPanel" )