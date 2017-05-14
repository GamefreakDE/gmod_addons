AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )
function ENT:Explode()
	local radius = 200
	local damage = 300
	local pos = self:GetPos()

	local explosion = ents.Create("env_explosion")
	if IsValid(explosion) then
		explosion:SetPos( pos )
		explosion:Spawn()
		explosion:SetKeyValue( "iMagnitude", damage )
		explosion:SetKeyValue( "iRadiusOverride", radius )
		explosion:SetOwner( self.Owner )
		explosion:Fire( "Explode", 0, 0 )
	end
	self:Remove()
end


function ENT:PhysicsCollide( data, phys )
	self:Explode()
end

function ENT:OnTakeDamage(dmginfo)
  if dmginfo:IsBulletDamage() then
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    if self:Health() <= 0 then
      self:Explode()
    end
  end
end

