game.AddAmmoType({
	name = "PropArmor"
})

SWEP.PrintName = "Repair Tool"
SWEP.Base = "weapon_base"

SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"

SWEP.Author = "meharryp"
SWEP.Instructions = "Left Click: Repair a prop\nRight Click: Apply armor to a prop"
SWEP.HoldType = "melee"

SWEP.UseHands = true

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "PropArmor"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false

SWEP.Sound = Sound("ambient/energy/spark5.wav")
SWEP.ArmorSound = Sound("ambient/energy/weld1.wav")

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end

	local tr = util.TraceLine( {
		start = self.Owner:EyePos(),
		endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 100,
		filter = function(ent) return ent != self.Owner end
	})

	local buff = (self.Owner:Team() == TEAM_ENGINEER and .15 or .3)

	self:SetNextPrimaryFire(CurTime() + buff)

	if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_physics" then
		local max, cur = tr.Entity:getMaxHealth(), tr.Entity:getHealth()

		if max and cur and cur < max then
			if SERVER then
				local val = (25 > tr.Entity:getMaxHealth() / 30 and 25 or math.floor(tr.Entity:getMaxHealth() / 30))
				tr.Entity:setHealth(math.Clamp(tr.Entity:getHealth() + val, 0, tr.Entity:getMaxHealth()))

				if tr.Entity:getHealth() > tr.Entity:getMaxHealth() / 2 then
					tr.Entity:SetColor(Color(255, 255, 255, 255))
					tr.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
				end
			end

			local effect = EffectData()
			effect:SetOrigin(tr.HitPos)
			effect:SetNormal(tr.HitNormal)
			util.Effect("ManhackSparks", effect)
			self:EmitSound(self.Sound)
		end
	end
	--self:EmitSound()
end

function SWEP:SecondaryAttack()
	if self:Ammo2() > 0 then
		local tr = util.TraceLine( {
			start = self.Owner:EyePos(),
			endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 100,
			filter = function(ent) return ent != self.Owner end
		})

		if (not IsValid(tr.Entity)) then return end
		local max, cur = tr.Entity:getMaxHealth(), tr.Entity:getHealth()

		if max and cur and cur < max then
			if SERVER then
				tr.Entity:setHealth(tr.Entity:getHealth() + math.floor(tr.Entity:getMaxHealth() / 10))
			end

			local effect = EffectData()
			effect:SetOrigin(tr.HitPos)
			effect:SetNormal(tr.HitNormal)
			util.Effect("ManhackSparks", effect)
			self:EmitSound(self.ArmorSound)
			self:TakeSecondaryAmmo(1)
		end
	end
end

function SWEP:Initialize()
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
end
