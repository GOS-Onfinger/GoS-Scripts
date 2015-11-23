if GetObjectName(GetMyHero()) ~= "Olaf" then return end

require("Inspired")
require("DamageLib")

class "Olaf"
function Olaf:__init()
	OlafMenu = MenuConfig("Olaf", "Olaf")
	OlafMenu:Menu("Combo", "Combo Setings")
		OlafMenu.Combo:Boolean("useQ", "Use Q", true)
		OlafMenu.Combo:Boolean("useW", "Use W", true)
		OlafMenu.Combo:Boolean("useE", "Use E", true)
		--OlafMenu.Combo:Boolean("useR", "Use R", true)
		OlafMenu.Combo:Boolean("useItems", "Use Items", true)
	OlafMenu:Menu("Harass", "Haras Setings")
		OlafMenu.Harass:Boolean("QHarass", "Use Q", true)
		OlafMenu.Harass:Boolean("WHarass", "Use W", true)
		OlafMenu.Harass:Boolean("EHarass", "Use E", true)
	OlafMenu:Menu("LaneClear", "Lane Clear Setings")
		OlafMenu.LaneClear:Boolean("QLaneClear", "Use Q", true)
		OlafMenu.LaneClear:Slider("QMana", "if Mana % is More than", 30, 0, 80, 1)
		OlafMenu.LaneClear:Boolean("WLaneClear", "Use W", true)
		OlafMenu.LaneClear:Slider("WMana", "if Mana % is More than", 30, 0, 80, 1)
		OlafMenu.LaneClear:Boolean("ELaneClear", "Use E", true)
		OlafMenu.LaneClear:Slider("EMana", "if Mana % is More than", 30, 0, 80, 1)
	OlafMenu:Menu("Killsteal", "Killsteal")
		OlafMenu.Killsteal:Boolean("QKill", "Killsteal with Q", true)
		OlafMenu.Killsteal:Boolean("EKill", "Killsteal with E", true)
  	OnTick(function(myHero) self:OnTick(myHero) end)
  	OnDraw(function(myHero) self:OnDraw(myHero) end)
end

function Olaf:OnTick()
	if IOW:Mode() == "Combo" then
		self:Combo()
	end

	if IOW:Mode() == "Harass" then
		self:Harass()
	end
	
	if IOW:Mode() == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	end

end

function Olaf:OnDraw()
	self:Settings()
	self:Killsteal()
end

function Olaf:Settings()
	unit = GetCurrentTarget()
	myRange = GetRange(myHero)
	Hydra = GetItemSlot(myHero,3074)
	Tiamat = GetItemSlot(myHero,3077)
	Yommus = GetItemSlot(myHero,3142)
	Bork = GetItemSlot(myHero,3153)
	HPercentage = GetCurrentHP(myHero)/GetMaxHP(myHero) * 100
	MousePos = GetMousePos()
--CastStartPosVec,EnemyChampionPtr,EnemyMoveSpeed,YourSkillshotSpeed,SkillShotDelay,SkillShotRange,SkillShotWidth,MinionCollisionCheck,AddHitBox
	QPred = GetPredictionForPlayer(GetOrigin(myHero), unit, GetMoveSpeed(unit),2200,250,1300,90,false,false)
end

function Olaf:useItems(unit)
uItems = OlafMenu.Combo.useItems:Value()
	if ValidTarget(unit, 800) then
		if uItems and CanUseSpell(myHero, Hydra) == READY and Hydra ~= 0 then
			CastSpell(Hydra)
		elseif uItems and CanUseSpell(myHero, Tiamat) == READY and Tiamat ~= 0 then
			CastSpell(Tiamat)
		elseif uItems and CanUseSpell(myHero, Bork) == READY and Bork ~= 0 and HPercentage < 80 then
			CastTargetSpell(unit, Bork)
		end
	end
end

function Olaf:Harass()
	QHarass = OlafMenu.Harass.QHarass:Value()
	EHarass = OlafMenu.Harass.EHarass:Value()

	if QHarass and ValidTarget(unit, GetCastRange(myHero, _Q)) then
    	self:ThrollAxe(unit)
    end

    if EHarass and ValidTarget(unit, GetCastRange(myHero, _E)+50) then
	    if CanUseSpell(myHero, _E) == READY then
	    	CastTargetSpell(unit, _E)
	    end
  	end
end

function Olaf:Combo()
	if GotBuff(myHero,"OlafRagnarok") then
		if CanUseSpell(myHero, Yommus) == READY and Yommus ~= 0 and GetDistance(unit) > 400 then
			CastSpell(Yommus)
		end
	end

	if ValidTarget(unit, GetCastRange(myHero, _Q)) then
    	self:ThrollAxe(unit)
    end

    if ValidTarget(unit, 350) then
		if CanUseSpell(myHero, _W) == READY then
			DelayAction(function() CastSpell(_W) end, 10)
		end
	end

    if ValidTarget(unit, GetCastRange(myHero, _E)+50) then
	    if CanUseSpell(myHero, _E) == READY then
	    	DelayAction(function() CastTargetSpell(unit, _E) end, 15)
	    end
  	end
        self:useItems(unit)
end

function Olaf:ThrollAxe(unit)
	if ValidTarget(unit, GetCastRange(myHero, _Q)) then
		if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 then
			CastSkillShot(_Q, QPred.PredPos.x, QPred.PredPos.y, QPred.PredPos.z)
		end
	end
end

function Olaf:LaneClear()
LNQ = OlafMenu.LaneClear.QLaneClear:Value()
LNW = OlafMenu.LaneClear.WLaneClear:Value()
LNE = OlafMenu.LaneClear.ELaneClear:Value()
QMana = OlafMenu.LaneClear.QMana:Value()
WMana = OlafMenu.LaneClear.WMana:Value()
EMana = OlafMenu.LaneClear.EMana:Value()
LNMana = GetCurrentMana(myHero)/GetMaxMana(myHero) * 100
    for m, minion in pairs(minionManager.objects) do
      	if GetTeam(minion) == MINION_ENEMY then
	        if LNQ and IsReady(_Q) and ValidTarget(minion, 400) and LNMana > QMana then
				if uItems and CanUseSpell(myHero, Hydra) == READY and Hydra ~= 0 then
					CastSpell(Hydra)
				elseif uItems and CanUseSpell(myHero, Tiamat) == READY and Tiamat ~= 0 then
					CastSpell(Tiamat)
				end
				local Mpred = GetPredictionForPlayer(GetOrigin(GetMyHero()), minion, GetMoveSpeed(minion), 2200,250,1300,90,false,false)
	        	if Mpred.HitChance == 1 then
	        		CastSkillShot(_Q, Mpred.PredPos.x, Mpred.PredPos.y, Mpred.PredPos.z)
	        	end
	        end
	        if LNW and IsReady(_W) and ValidTarget(minion, 400) and LNMana > WMana and HPercentage < 40  then
	        	DelayAction(function() CastSpell(_W) end, 10)
	        end
	        if LNE and IsReady(_E) and ValidTarget(minion, 400) and LNMana > EMana then
	            DelayAction(function() CastTargetSpell(minion,_E) end, 20)
	        end
    	end
	end
end 

function Olaf:JungleClear()
    for j,jMob in pairs(minionManager.objects) do
     	if GetTeam(jMob) == MINION_JUNGLE then
		if LNQ and IsReady(_Q) and ValidTarget(jMob, 400) and LNMana > QMana then
			if uItems and CanUseSpell(myHero, Hydra) == READY and Hydra ~= 0 then
				CastSpell(Hydra)
			elseif uItems and CanUseSpell(myHero, Tiamat) == READY and Tiamat ~= 0 then
				CastSpell(Tiamat)
			end
	        if IsReady(_Q) and ValidTarget(jMob, GetCastRange(myHero, _Q)) then
				local Jpred = GetPredictionForPlayer(GetOrigin(GetMyHero()), jMob, GetMoveSpeed(jMob), 2200,250,1300,90,false,false)
	        	if Jpred.HitChance == 1 then
	        		CastSkillShot(_Q, Jpred.PredPos.x, Jpred.PredPos.y, Jpred.PredPos.z)
	        	end
	        end
	        if IsReady(_W) and ValidTarget(jMob, 400) and HPercentage < 80 then
	        	DelayAction(function() CastSpell(_W) end, 10)
	        end
	        if IsReady(_E) and ValidTarget(jMob, 400) then
	            DelayAction(function() CastTargetSpell(jMob,_E) end, 20)
	        end
     	end
     	end
    end
end

function Olaf:Killsteal()
Qkill = OlafMenu.Killsteal.QKill:Value()
Ekill = OlafMenu.Killsteal.EKill:Value()
	for i,unit in pairs(GetEnemyHeroes()) do
		if Qkill and CanUseSpell(myHero,_Q) and ValidTarget(unit,GetCastRange(myHero,_Q)) and GetCurrentHP(unit) < getdmg("Q",unit,myHero,3) then 
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
		elseif Ekill and CanUseSpell(myHero,_E) and ValidTarget(unit,GetCastRange(myHero,_E)+50) and GetCurrentHP(unit) < getdmg("E",unit,myHero,3) then 
			CastTargetSpell(unit, _E)
		end
	end
end

if GetObjectName(myHero) == "Olaf" then Olaf() end
