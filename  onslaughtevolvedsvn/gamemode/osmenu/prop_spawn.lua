local PANEL = { }

function PANEL:Init( )
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Click on an icon to spawn a prop." )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SizeToContents( )
	
	self.ListList = vgui.Create( "DPanelList", self )
	
	self.IconList = {}
	self.IconListCollapse = {}
	for k,v in pairs (MODELGROUPS) do
	self.IconList[k] = vgui.Create( "DPanelList", self )
	self.IconList[k]:EnableVerticalScrollbar( true ) 
 	self.IconList[k]:EnableHorizontal( true ) 
 	self.IconList[k]:SetPadding( 4 ) 
	self.IconList[k]:SetVisible( true ) 
	
	self.IconListCollapse[k] = vgui.Create( "DCollapsibleCategory", self )
	self.IconListCollapse[k]:SetSize( 610,20 ) 
	self.IconListCollapse[k]:SetLabel( v ) 
	self.IconListCollapse[k]:SetVisible( true ) 
	self.IconListCollapse[k]:SetContents(self.IconList[k])
	self.ListList:AddItem( self.IconListCollapse[k] )
	end
			
	for k,v in pairs( MODELS ) do
		local ent = ents.Create("prop_physics") -- lol ailias filthy hack
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(Vector(0,0,0))
		ent:SetModel(k)
		print(ent:GetModel())
		PrintTable(	util.GetModelInfo( ent:GetModel() ))
		ent:Spawn()
		ent:Activate()
		ent:PhysicsInit( SOLID_VPHYSICS )    

		if ValidEntity(ent:GetPhysicsObject()) then
			local center = ent:OBBCenter()
			local dist = ent:BoundingRadius()*1.2
			local hlth = math.Round(math.Clamp(ent:GetPhysicsObject():GetMass() * (ent:OBBMins():Distance(ent:OBBMaxs())) / 100,200,800)*1.05)
			if v.COST then hlth = v.COST*1.05 end
			
			local ico = vgui.Create( "DModelPanel", self )
			ico:SetModel(k)
			ico.Skin = math.random(0,util.GetModelInfo(k).SkinCount-1)
			ico.Entity:SetSkin(ico.Skin)
			ico.DoClick = function( ico ) RunConsoleCommand("gm_spawn", k, ico.Skin) end
			ico.DoRightClick = function( ico ) ico.Skin = ico.Skin + 1 if ico.Skin == util.GetModelInfo(k).SkinCount then ico.Skin = 0 end ico.Entity:SetSkin(ico.Skin) ico:InvalidateLayout( true ) end
			ico:SetSize(64,64)
			ico:SetLookAt( center )
			ico:SetCamPos( center+Vector(dist,dist,dist) )
		
			ico:InvalidateLayout( true ) 
			ico:SetToolTip( Format( "Cost: $%s", tostring(hlth) ) ) 
			if v.GROUP then
				self.IconList[v.GROUP]:AddItem( ico )
			end
		end
		ent:Remove()
	end
end

function PANEL:Think()
	if self:GetParent():GetActiveTab():GetPanel() == self then
		self:GetParent():GetParent():SetSize(360+256,750)
	else 
		self:GetParent():GetParent():SetSize(360,350) 
	end
end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	self.Label:SetPos( 2, 2 )
	self.ListList:StretchToParent( 4, 26, 4, 4 ) 
 	self.ListList:InvalidateLayout() 
	for k,v in pairs (self.IconList) do
	--v:StretchToParent( 4, 26, 4, 4 ) 
	v:SizeToContents( )
 	v:InvalidateLayout() 
	end
end

vgui.Register( "onslaught_PropSpawn", PANEL, "DPanel" )