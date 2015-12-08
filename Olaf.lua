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
	--	OlafMenu.Combo:Boolean("useR", "Use R", true)
		OlafMenu.Combo:Boolean("useItems", "Use Items", true)
	OlafMenu:Menu("Harass", "Haras Setings")
		OlafMenu.Harass:Boolean("QHarass", "Use Q", true)
	--	OlafMenu.Harass:Boolean("WHarass", "Use W", true)
		OlafMenu.Harass:Boolean("EHarass", "Use E", true)
	OlafMenu:Menu("LaneClear", "Lane Clear Setings")
		OlafMenu.LaneClear:Boolean("QLaneClear", "Use Q", true)
		OlafMenu.LaneClear:Slider("QMana", "if Mana % is More than", 80, 0, 100, 1)
		OlafMenu.LaneClear:Boolean("WLaneClear", "Use W", true)
		OlafMenu.LaneClear:Slider("WMana", "if Mana % is More than", 80, 0, 100, 1)
		OlafMenu.LaneClear:Boolean("ELaneClear", "Use E", true)
		OlafMenu.LaneClear:Slider("EMana", "if Mana % is More than", 80, 0, 100, 1)
	OlafMenu:Menu("JungleClear", "Jungle Clear Setings")
		OlafMenu.JungleClear:Boolean("QJungleClear", "Use Q", true)
		OlafMenu.JungleClear:Slider("JMana", "if Mana % is More than", 30, 0, 100, 1)		
	OlafMenu:Menu("Survival", "HP Regeneration")
		OlafMenu.Survival:Boolean("WHPRegen", "Use W Heal", true)
		OlafMenu.Survival:Slider("WHP", "if HP % is Less than", 80, 0, 100, 1)
	OlafMenu:Menu("Killsteal", "Killsteal")
		OlafMenu.Killsteal:Boolean("QKill", "Killsteal with Q", true)
		OlafMenu.Killsteal:Boolean("EKill", "Killsteal with E", true)
	--OlafMenu:Menu("Skinchange", "Set Hero Skin")
	--	OlafMenu.Skinchange:Slider("SetSkin", "Skin ID", 0, 0, 5, 1)

  	OnTick(function(myHero) self:OnTick(myHero) end)
  	--OnDraw(function(myHero) self:OnDraw(myHero) end)
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
	self:Settings()
	self:Killsteal()
end

--function Olaf:OnDraw()
--HeroSkinChanger(GetMyHero(),OlafMenu.Skinchange.SetSkin:Value())
--end

function Olaf:Settings()
	unit = GetCurrentTarget()
	uItems = OlafMenu.Combo.useItems:Value()
	LNQ = OlafMenu.LaneClear.QLaneClear:Value()
	LNW = OlafMenu.LaneClear.WLaneClear:Value()
	LNE = OlafMenu.LaneClear.ELaneClear:Value()
	QMana = OlafMenu.LaneClear.QMana:Value()
	WMana = OlafMenu.LaneClear.WMana:Value()
	EMana = OlafMenu.LaneClear.EMana:Value()
	JCMana = OlafMenu.JungleClear.JMana:Value()
	QHarass = OlafMenu.Harass.QHarass:Value()
	EHarass = OlafMenu.Harass.EHarass:Value()
	Qkill = OlafMenu.Killsteal.QKill:Value()
	Ekill = OlafMenu.Killsteal.EKill:Value()
	Hydra = GetItemSlot(myHero,3074)
	Tiamat = GetItemSlot(myHero,3077)
	Yommus = GetItemSlot(myHero,3142)
	Bork = GetItemSlot(myHero,3153)
	Cutlass = GetItemSlot(myHero,3144)
	HPercentage = GetCurrentHP(myHero)/GetMaxHP(myHero) * 100
	WHP = OlafMenu.Survival.WHP:Value()
	MousePos = GetMousePos()
	myMana = GetCurrentMana(myHero)/GetMaxMana(myHero) * 100
--CastStartPosVec,EnemyChampionPtr,EnemyMoveSpeed,YourSkillshotSpeed,SkillShotDelay,SkillShotRange,SkillShotWidth,MinionCollisionCheck,AddHitBox
	QPred = GetPredictionForPlayer(GetOrigin(myHero), unit, GetMoveSpeed(unit),2200,250,1300,90,false,false)
end

function Olaf:useItems(unit)
	if ValidTarget(unit, 400) then
		if uItems and CanUseSpell(myHero, Hydra) == READY and Hydra ~= 0 and GetDistance(unit) < 300 then
			CastSpell(Hydra)
		elseif uItems and CanUseSpell(myHero, Tiamat) == READY and Tiamat ~= 0 and GetDistance(unit) < 300 then
			CastSpell(Tiamat)
		elseif uItems and CanUseSpell(myHero, Bork) == READY and Bork ~= 0 then
			CastTargetSpell(unit, Bork)
		elseif uItems and CanUseSpell(myHero, Cutlass) == READY and Cutlass ~= 0 then
			CastTargetSpell(unit, Cutlass)		
		end
	end
end

function Olaf:Harass()
	if QHarass and ValidTarget(unit, GetCastRange(myHero, _Q)) then
    	self:ThrollAxe(unit)
    end
    if EHarass and ValidTarget(unit, GetCastRange(myHero, _E)) then
	    if CanUseSpell(myHero, _E) == READY then
	    	CastTargetSpell(unit, _E)
	    end
  	end
end

function Olaf:Combo()
	if GotBuff(myHero,"OlafRagnarok") == 1 then
		if CanUseSpell(myHero, Yommus) == READY and Yommus ~= 0 and GetDistance(unit) > 600 then
			CastSpell(Yommus)
		elseif CanUseSpell(myHero, Yommus) == READY and Yommus ~= 0 and GetDistance(unit) > 600 then
			CastSpell(Yommus)
		end
	end

	if ValidTarget(unit, GetCastRange(myHero, _Q)) then
    	self:ThrollAxe(unit)
    end

    if ValidTarget(unit, GetCastRange(myHero,_W)) then
		if CanUseSpell(myHero, _W) == READY then
			DelayAction(function() CastSpell(_W) end, 5)
		end
	end

    if ValidTarget(unit, GetCastRange(myHero, _E)) then
	    if CanUseSpell(myHero, _E) == READY then
	    	DelayAction(function() CastTargetSpell(unit, _E) end, 10)
	    end
  	end
    self:useItems(unit)
end

function Olaf:ThrollAxe(unit)
	if ValidTarget(unit, GetCastRange(myHero, _Q)) then
    	local PredPos = Vector(QPred.PredPos)
    	local HeroPos = Vector(myHero)
    	local maxQRange = PredPos - (PredPos - HeroPos) * ( - 100 / GetDistance(QPred.PredPos))		
          if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 then
          	CastSkillShot3(_Q,HeroPos,maxQRange)
          end
	end
end

function Olaf:LaneClear()
    for m, minion in pairs(minionManager.objects) do
		local Mpred = GetPredictionForPlayer(GetOrigin(GetMyHero()), minion, GetMoveSpeed(minion), 2200,250,1300,80,false,false)
      	if GetTeam(minion) == MINION_ENEMY then
			if uItems and CanUseSpell(myHero, Hydra) == READY and Hydra ~= 0 then
				CastSpell(Hydra)
			elseif uItems and CanUseSpell(myHero, Tiamat) == READY and Tiamat ~= 0 then
				CastSpell(Tiamat)
			end
	        if ValidTarget(minion, GetCastRange(myHero,_Q)) and myMana > QMana then
				MinionPos = GetOrigin(minion)
					if CanUseSpell(myHero, _Q) == READY and LNQ then
						CastSkillShot(_Q,MinionPos.x,MinionPos.y,MinionPos.z)
					end
	        end
	        if LNW and IsReady(_W) and ValidTarget(minion, GetCastRange(myHero,_W)) and myMana > WMana and HPercentage < WHP then
	        	DelayAction(function() CastSpell(_W) end, 10)
	        end
	        if LNE and IsReady(_E) and ValidTarget(minion, GetCastRange(myHero,_E)) and myMana > EMana then
	            DelayAction(function() CastTargetSpell(minion,_E) end, 20)
	        end
    	end
	end
end 

function Olaf:JungleClear()
    for j,jMob in pairs(minionManager.objects) do
    	local Jpred = GetPredictionForPlayer(GetOrigin(GetMyHero()), jMob, GetMoveSpeed(jMob), 2200,250,1300,80,false,false)
     	if GetTeam(jMob) == MINION_JUNGLE then
				if uItems and CanUseSpell(myHero, Hydra) == READY and Hydra ~= 0 then
					CastSpell(Hydra)
				elseif uItems and CanUseSpell(myHero, Tiamat) == READY and Tiamat ~= 0 then
					CastSpell(Tiamat)
				end
			if ValidTarget(jMob, GetCastRange(myHero,_Q)) and myMana > JCMana then
				JungleMobPos = GetOrigin(jMob)	        
				if CanUseSpell(myHero, _Q) == READY and OlafMenu.JungleClear.QJungleClear:Value() then
					CastSkillShot(_Q,JungleMobPos.x,JungleMobPos.y,JungleMobPos.z)
				end
		    end
		        if IsReady(_W) and ValidTarget(jMob, GetCastRange(myHero,_W)) and HPercentage < WHP then
		        	DelayAction(function() CastSpell(_W) end, 10)
		        end
		        if IsReady(_E) and ValidTarget(jMob, GetCastRange(myHero,_E)) then
		            DelayAction(function() CastTargetSpell(jMob,_E) end, 20)
		        end
     	end
    end
end

function Olaf:Killsteal()
	for i,unit in pairs(GetEnemyHeroes()) do
		if Qkill and CanUseSpell(myHero,_Q) and ValidTarget(unit,GetCastRange(myHero,_Q)) and GetCurrentHP(unit) < getdmg("Q",unit,myHero,3) then 
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
		elseif Ekill and CanUseSpell(myHero,_E) and ValidTarget(unit,GetCastRange(myHero,_E)) and GetCurrentHP(unit) < getdmg("E",unit,myHero,3) then 
			CastTargetSpell(unit, _E)
		end
	end
end

if GetObjectName(myHero) == "Olaf" then Olaf() end
PrintChat("<font color='#e3ff00'>Scaring - Olaf the Viking</font> <> <font color='#00d12d'>Loaded!</font>")
