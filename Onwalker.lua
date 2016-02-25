require 'inspired'

class 'Onwalker'
_minions = { {}, {}, {}, {}, {} }
MINION_ALL = 1
MINION_ENEMY = 2
MINION_ALLY = 3
MINION_JUNGLE = 4
MINION_OTHER = 5
MINION_SORT_HEALTH_ASC = function(a, b) return a.health < b.health end
MINION_SORT_HEALTH_DEC = function(a, b) return a.health > b.health end
MINION_SORT_MAXHEALTH_ASC = function(a, b) return a.maxHealth < b.maxHealth end
MINION_SORT_MAXHEALTH_DEC = function(a, b) return a.maxHealth > b.maxHealth end
MINION_SORT_AD_ASC = function(a, b) return a.ad < b.ad end
MINION_SORT_AD_DEC = function(a, b) return a.ad > b.ad end

function Onwalker:__init()
	self.allyMinions = {}
	self.enemyMinions = {}
	self.incomingDetails = {}
	self.AfterAttackCallbacks = {}
	self.OnAttackCallbacks = {}
	self.BeforeAttackCallbacks = {}
	self.lastAttack = 0
	self.lastWindUpTime = 0
	self.lastAttackCD = 0
	self.Attacks = true
	self.Move = true
	OnTick(function() self:OnTick() end)
	OnTick(function() self:miniOnTick() end)
	OnDraw(function() self:OnDraw() end)
	OnProcessSpell(function(unit, spell) self:OnProcessAttack(unit,spell) end)
	OnAnimation(function(object,animation) self:OnAnimation(unit,animation) end)
end


function Onwalker:LoadToMenu(m)
	if not m then
		self.menu = MenuConfig("Onfinger", "Onfinger")
	else
		self.menu = MenuConfig(m, "Onfinger")
	end
	self.menu:Menu("enab","Enable")
	self.menu.enab:Boolean("Enabled","Enable",true)
	self.menu.enab:Slider("holdzone","Hold Position",120,0,200)
	self.menu.enab:Boolean("magnet", "Move to Target",false)
	if myHero.isMelee then
		self.menu.enab:Slider("stick", "Stickyradius (target)",125,100,300)
	end
	self.menu:SubMenu("HKey", "Hotkeys")
	self.menu.HKey:KeyBinding("Combo", "Combo!", 32)
	self.menu.HKey:KeyBinding("Harass", "Harass!", string.byte("C"))
	self.menu.HKey:KeyBinding("LaneClear", "LaneClear!", string.byte("V"))
	self.menu.HKey:KeyBinding("LastHit", "Last hit!", string.byte("X"))
	self.menu:Menu("misc", "Miscelaneous")
	self.sts = TargetSelector(GetRange(myHero), TARGET_LESS_CAST, DAMAGE_PHYSICAL)
	self.menu.misc:TargetSelector("sts", "TargetSelector", self.sts)

end

function Onwalker:Mode()
	if self.menu.HKey.Combo:Value() then
		return "Combo"
	elseif self.menu.HKey.Harass:Value() then
		return "Harass"
	elseif self.menu.HKey.LaneClear:Value() then
		return "LaneClear"
	elseif self.menu.HKey.LastHit:Value() then
		return "LastHit"
	end
end

function Onwalker:OnTick()
self.sts.range = self:TrueRange()
	if self:Dorb() then
		self:Orbwalk()
	 end
end

function Onwalker:Dorb()
	return self:Mode() ~= ""
end
-- if not self.menu.enab.Enabled:Value() then return end
-- 	mousePos = GetMousePos()
-- 	if self:Mode() == "Combo" then
-- 		target = GetCurrentTarget()
-- 		if ValidTarget(target) and GetDistance(target) < self:TrueRange() then
-- 			if self:CanShoot() then
-- 				self:Attack(target)
-- 			elseif self:CanMove() then
-- 				self:MoveTo()
-- 			end
-- 		elseif GetDistance(mousePos) > self.menu.enab.holdzone:Value() then
-- 			self:MoveTo()
-- 		end
-- 	end

function Onwalker:Orbwalk()
mousePos = GetMousePos()
self.target = self.sts:GetTarget()
	if self:Mode() == "Combo" then
		if ValidTarget(self.target) and GetDistance(self.target) < self:TrueRange() then
			if self:CanShoot() then
				self:Attack(self.target)
			elseif self:CanMove() then
				self:MoveTo()
			end
		elseif GetDistance(mousePos) < self.menu.enab.holdzone:Value() then
			HoldPosition()
		else
			self:MoveTo()
		end
	end
end

function Onwalker:GetOrbMode()
	if self:Mode() == "Combo" then
		return self:CanOrb(self.Target) and (GetObjectType(self.target) == GetObjectType(myHero)) and self.target or self.sts:GetTarget()
--		return self:CanOrb(self.forceTarget) and self.forceTarget or (self.menu.enab.magnet:Value() and self:CanOrb(self.target) and GetObjectType(self.target) == GetObjectType(myHero)) and self.target or self.sts:GetTarget()
	elseif self:Mode() == "Harass" then
		return self:GetLastHit() or self:CanOrb(self.forceTarget) and self.forceTarget or (self.menu.enab.magnet:Value() and self:CanOrb(self.target) and GetObjectType(self.target) == GetObjectType(myHero)) and self.target or self.sts:GetTarget()
	elseif self:Mode() == "LastHit" then
		return self:GetLastHit()
	elseif self:Mode() == "LaneClear" then
		return self:GetLastHit() or self:GetLaneClear() or self:GetJungleClear()
	else
		return nil
	end
end

function Onwalker:CanOrb(t)
	local r = self:TrueRange()
		if t == nil or t.pos == nil or not t.IsTargetable or IsImmune(t,myHero) or t.IsDead or not t.IsVisible or (r and GetDistanceSqr(t.pos, myHero.pos) > r^2) then
			return false
		end
	return true
end

function Onwalker:TrueRange()
	return myHero.range+myHero.boundingRadius
end

function Onwalker:EnableAttacks()
	self.Attacks = true
end

function Onwalker:EnableMovement()
	self.move = true
end

function Onwalker:DisableAttacks()
	self.Attacks = false
end

function Onwalker:OnAnimation(unit,animation)

end

function Onwalker:DisableMovement()
	self.move = false
end

function Onwalker:GetTime()
	return os.clock()
end

function Onwalker:CanMove()
	return (GetTickCount() + GetLatency() * 0.5 > lastAttack + lastWindUpTime + 20)
end 

function Onwalker:CanShoot()
	return (GetTickCount() + GetLatency() * 0.5 > lastAttack + lastAttackCD)
end 

function Onwalker:MoveTo()
	if GetDistance(mousePos) > 1 then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * (312 + GetLatency())
		myHero:Move(moveToPos.x, moveToPos.z)
	end 
end

function Onwalker:GetHitBox(unit)
    if self.nohitboxmode and unit.type and unit.type == myHero.type then
        return 0
    end
    return unit.boundingRadius or 65
end

function Onwalker:Attack(target)
	self.lastAttack = self:GetTime() + self:Latency()
	myHero:Attack(target)
end

function Onwalker:Latency()
	return GetLatency() / 2000
end

function Onwalker:BeforeAttack(target)
	local result = false
	for i, cb in ipairs(self.BeforeAttackCallbacks) do
		local ri = cb(target, self.mode)
		if ri then
			result = true
		end
	end
	return result
end

function Onwalker:RegisterBeforeAttackCallback(f)
	table.insert(self.BeforeAttackCallbacks, f)
end

function Onwalker:OnAttack(target)
	for i, cb in ipairs(self.OnAttackCallbacks) do
		cb(target, self.mode)
	end
end

function Onwalker:RegisterOnAttackCallback(f)
	table.insert(self.OnAttackCallbacks, f)
end

function Onwalker:AfterAttack(target)
	for i, cb in ipairs(self.AfterAttackCallbacks) do
		cb(target, self.mode)
	end
end

function Onwalker:RegisterAfterAttackCallback(f)
	table.insert(self.AfterAttackCallbacks, f)
end

function Onwalker:miniOnTick()
	for _, mob in pairs(minionManager.objects) do
		if GetTeam(mob) == MINION_ENEMY and ValidTarget(mob,2000) then
			PrintChat(mob.charName.. " - " ..mob.health)
		end
	end
end

function Onwalker:OnDraw()
	DrawCircle3D(myHero.x,myHero.y,myHero.z,self:TrueRange(), 1, ARGB(255,255,255,255), 128)
end

function Onwalker:OnProcessAttack(unit, spell)
	if unit and unit.isMe and spell.name:lower():find("attack") then
		lastAttack = GetTickCount() - GetLatency() * 0.5
		lastWindUpTime = spell.windUpTime * 1000
		lastAttackCD = spell.animationTime * 1000		 
	end
	DelayAction(function(t) self:AfterAttack(t) end, --[[self:WindUpTime()]] myHero.windUp - self:Latency(), {spell.target})
	-- if self.resetAttacks[spellName] then
	--   self:ResetAA()
	-- end
end

PrintChat("Onfinger - Orbwalker")
-- Onwalker()
-- Onwalker:LoadToMenu("MyOrbwalker")