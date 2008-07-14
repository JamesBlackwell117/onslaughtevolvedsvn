//garry -- need this but deriving from sandbox creates a huge performance drop

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
 
if ( iSkin && iSkin > 0 ) then 
	self:SetToolTip( Format( "%s (Skin %i)", mdl, iSkin+1 ) ) 
else 
	self:SetToolTip( Format( "%s", mdl ) ) 
end 

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

// Xera

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

