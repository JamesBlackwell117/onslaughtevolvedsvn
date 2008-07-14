local PANEL = { }

function PANEL:Init( )
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Click on an icon to spawn a prop." )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SizeToContents( )
	
	self.IconList = vgui.Create( "DPanelList", self )
	self.IconList:EnableVerticalScrollbar( true ) 
 	self.IconList:EnableHorizontal( true ) 
 	self.IconList:SetPadding( 4 ) 
	self.IconList:SetVisible( true ) 
	self.IconList:NoClipping(false)
	
	for k,v in pairs( MODELS ) do
		local ico = vgui.Create( "DModelPanel", self )
		ico:SetModel(k)
		ico.DoClick = function( ico ) RunConsoleCommand("gm_spawn", k, 0) end
		ico:SetSize(64,64)

			local ent = ents.Create("prop_physics")
			ent:SetAngles(Angle(0,0,0))
			ent:SetPos(Vector(0,0,0))
			ent:SetModel(k)
			ent:Spawn()
			ent:Activate()
			ent:PhysicsInit( SOLID_VPHYSICS )    

			
			local center = ent:OBBCenter()
			local dist = ent:BoundingRadius()*1.2
			local hlth = math.Round(math.Clamp(ent:GetPhysicsObject():GetMass() * (ent:OBBMins():Distance(ent:OBBMaxs())) / 100,200,800)*1.05)
			
			ent:Remove()
		
		ico:SetLookAt( center )
		ico:SetCamPos( center+Vector(dist,dist,dist) )
		
		ico:InvalidateLayout( true ) 
		ico:SetToolTip( Format( "Cost: $%s", tostring(hlth) ) ) 
		self.IconList:AddItem( ico )
	end
end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	self.Label:SetPos( 2, 2 )
	self.IconList:StretchToParent( 4, 26, 4, 4 ) 
 	self.IconList:InvalidateLayout() 
end

vgui.Register( "onslaught_PropSpawn", PANEL, "DPanel" )