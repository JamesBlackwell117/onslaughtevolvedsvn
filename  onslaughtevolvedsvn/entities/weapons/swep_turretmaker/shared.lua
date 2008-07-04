if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Turret Spawner"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

--Swep info and other stuff
SWEP.Author	= "Conman420"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Makes freindly turrets"
SWEP.Instructions = "look and spawn"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_hands.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"
SWEP.LastReload = CurTime()

function SWEP:Initialize( )

end

function SWEP:Deploy()
	if SERVER then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.owner:Message("Fire: Spawn turret.")
		self.owner:Message("Alt Fire: Delete turret.")
		self.owner:Message("Reload: Delete all turrets.")
		return true
	end
end

function SWEP:CanSpawnBuilding( )
	if TURRET_COST > self.owner:GetNetworkedInt( "money") then
		self.owner:Message("Insufficient funds!", Color(255,100,100,255))
		return false
	end
	local c = 0
	for k,v in pairs( self.owner.Buildings ) do
		if not ValidEntity( v ) then
			table.remove( self.owner.Buildings, k )
		elseif v:GetClass( ) == "npc_turret_floor" then
			c = c + 1
		end
	end
	return c < 2
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end
	if not self:CanSpawnBuilding( ) then
		self.owner:Message("You can't spawn any more turrets!", Color(255,100,100,255))
		return
	end
	local trace = {}
	trace.start = self.owner:GetShootPos()
	trace.endpos = trace.start + (self.owner:GetAimVector() * 200)
	trace.filter = self.owner
	local trc = util.TraceLine(trace)
	if !trc.Hit then return end
	
	local trt = ents.Create("npc_turret_floor")
	trt:SetPos(trc.HitPos + Vector(0,0,1))
	local ang = self.owner:EyeAngles()
	trt:SetAngles(Angle(0,ang.yaw,0))
	trt:SetKeyValue("spawnflags","512")
	trt.owner = self.owner
	trt:Spawn()
	trt:Activate()
	table.insert(self.owner.Buildings,trt)
	trt:GetPhysicsObject():EnableMotion(false)
	trt.owner = self.owner
	trt:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	trt:SetNetworkedEntity("owner",self.owner)
	local trtctrl = ents.Create("sent_turretcontroller") --this entity controls the turrets health and kills it etc.
	trtctrl:SetPos(trt:GetPos())
	trtctrl:SetParent(trt)
	trtctrl:Spawn()
	trtctrl:Activate()
	trtctrl.owner = self.owner
	trt.Controller = trtctrl
	trt:SetNWInt("health",trtctrl.Shealth)
	self.owner:EmitSound( "npc/scanner/scanner_siren1.wav" )
	self.owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_siren1.wav" )]] )
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.owner:Message((TURRET_COST * -1).." [Spawned Turret]", Color(255,100,100,255))
	self.owner:SetNetworkedInt( "money", self.owner:GetNetworkedInt( "money" ) - TURRET_COST )
end

function SWEP:SecondaryAttack( )

	if CLIENT then
		return
	end

	local trace = { }
	trace.start = self.owner:GetShootPos( )
	trace.endpos = trace.start + ( self.owner:GetAimVector( ) * 1000 )
	trace.filter = self.owner
	local tr = util.TraceLine( trace )
	
	if not tr.Hit then return end
	if not ValidEntity( tr.Entity ) then return end
	if not table.HasValue( self.owner.Buildings, tr.Entity ) then return end
	
	
	for k,v in pairs( self.owner.Buildings ) do
		if v == tr.Entity then
			table.remove( self.owner.Buildings, k )
			break
		end
	end
	
	tr.Entity.Controller:Remove( )
	tr.Entity:Remove( )
	
	self.owner:EmitSound( "npc/scanner/scanner_siren1.wav" )
	self.owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_siren1.wav" )]] )
	self.Weapon:SetNextSecondaryFire( CurTime( ) + 2 )

end

function SWEP:Reload()
	if SERVER then
		if !self.owner.Buildings then return end
		if self.LastReload + 1 < CurTime() then
			for k,v in pairs( self.owner.Buildings ) do
				if v:GetClass() == "npc_turret_floor" then
					v:Remove()
					table.remove( self.owner.Buildings, k )
				end
			end
		self.LastReload = CurTime()
		self.owner:Message("Deleted all turrets.", Color(100,255,100,255))
		end
	end
end
