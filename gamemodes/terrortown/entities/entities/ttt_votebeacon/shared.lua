if SERVER then
  AddCSLuaFile()
  resource.AddFile("models/gamefreak/frenchie/bulkytotem.mdl")
  resource.AddFile("materials/frenchie/bulkytotem/ed3555af.vmt")
  resource.AddFile("materials/frenchie/bulkytotem/a4c3dbeb.vmt")
  resource.AddFile("materials/frenchie/bulkytotem/6348b211.vmt")
end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = Model("models/gamefreak/frenchie/bulkytotem.mdl")
ENT.CanUseKey = true
ENT.CanPickup = true

function ENT:Initialize()
  self:SetModel(self.Model)

  if SERVER then
    self:PhysicsInit(SOLID_VPHYSICS)
  end

  self:SetMoveType(MOVETYPE_NONE)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
  self:SetHealth(self:GetOwner():GetNWInt("VoteBeaconHealth",100))

  if SERVER then
    self:SetMaxHealth(100)
    self:SetUseType(SIMPLE_USE)
  end

  self:PhysWake()
end

function ENT:AddHalos()
  local owner = self:GetOwner()
 if SERVER and owner:IsValid() and owner:GetNWInt("VoteCounter",0) >= 3 then
   net.Start("TTTVoteAddHalos")
   net.WriteBool(false)
   net.WriteEntity(self)
   net.Broadcast()
 end
end

function ENT:RemoveHalos()
  local owner = self:GetOwner()
 if SERVER and owner:IsValid() and owner:GetNWInt("VoteCounter",0) >= 3 then
    net.Start("TTTVoteRemoveHalos")
    net.WriteBool(false)
    net.WriteEntity(self)
    net.Broadcast()
    net.Start("TTTVoteBeacon")
    net.WriteInt(7,8)
    net.WriteEntity(owner)
    net.Broadcast()
    TTTVote.AddHalos(owner)
 end
end

function ENT:UseOverride(activator)
  if IsValid(activator) and activator:IsTerror() and self:GetOwner() == activator then
    activator:SetNWBool("CanSpawnVoteBeacon",true)
    activator:SetNWBool("PlacedBeacon", false)
    activator:SetNWInt("VoteBeaconHealth",self:Health())
    activator:SetNWEntity("VoteBeacon",NULL)
    net.Start("TTTVoteBeacon")
    net.WriteInt(4,8)
    net.Send(activator)
    self:RemoveHalos()
    self:Remove()
    if SERVER then TTTVote.VoteBeaconUpdate() end
  end
end

local zapsound = Sound("npc/assassin/ball_zap1.wav")
function ENT:OnTakeDamage(dmginfo)
  if GetRoundState() != ROUND_ACTIVE then return end
  if dmginfo:GetInflictor() == self:GetOwner() or dmginfo:GetAttacker() == self:GetOwner() then return end
  self:TakePhysicsDamage(dmginfo)

  self:SetHealth(self:Health() - dmginfo:GetDamage())
  if self:Health() <= 0 then

    if SERVER and self:GetOwner():IsValid() and dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():IsPlayer() then
      net.Start("TTTVoteBeacon")
      net.WriteInt(5,8)
      net.WriteEntity(self:GetOwner())
      net.WriteEntity(dmginfo:GetAttacker())
      net.Broadcast()
    end

    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("cball_explode", effect)
    sound.Play(zapsound, self:GetPos())
    self:GetOwner():SetNWEntity("VoteBeacon",NULL)
    self:RemoveHalos()
    self:Remove()
    if SERVER then TTTVote.VoteBeaconUpdate() end
  end
end

if CLIENT then
  hook.Add("HUDDrawTargetID", "DrawVoteBeacon", function()
    local e = LocalPlayer():GetEyeTrace().Entity

    if IsValid(e) and e:GetClass() == "ttt_votebeacon" then
      local owner = e:GetOwner():Nick()

      if string.EndsWith(owner, "s") or string.EndsWith(owner, "x") or string.EndsWith(owner, "z") or string.EndsWith(owner, "ß") then
        draw.SimpleText(e:GetOwner():Nick() .. "' Totem", "TargetID", ScrW() / 2.0 + 1, ScrH() / 2.0 + 41, COLOR_BLACK, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(e:GetOwner():Nick() .. "' Totem", "TargetID", ScrW() / 2.0, ScrH() / 2.0 + 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      else
        draw.SimpleText(e:GetOwner():Nick() .. "s Totem", "TargetID", ScrW() / 2.0 + 1, ScrH() / 2.0 + 41, COLOR_BLACK, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(e:GetOwner():Nick() .. "s Totem", "TargetID", ScrW() / 2.0, ScrH() / 2.0 + 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end

      local _, color = util.HealthToString(e:Health(), e:GetMaxHealth())
      draw.SimpleText(e:Health() .. " HP ", "TargetIDSmall2", ScrW() / 2.0 + 1, ScrH() / 2.0 + 61, COLOR_BLACK, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText(e:Health() .. " HP ", "TargetIDSmall2", ScrW() / 2.0, ScrH() / 2.0 + 60, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
  end)
end
