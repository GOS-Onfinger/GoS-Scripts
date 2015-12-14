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
	OlafMenu:Menu("Misc", "Miscelaneous")
	if Ignite ~= nil then OlafMenu.Misc:Boolean("Autoignite", "Auto Ignite", true) end
		OlafMenu.Misc:Boolean("Autolvl", "Auto level", false)
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
	self:Autolevel()
	self:Autoignite()
end

--function Olaf:OnDraw()
--HeroSkinChanger(GetMyHero(),OlafMenu.Skinchange.SetSkin:Value())
--end

function Olaf:Settings()
	unit = GetCurrentTarget()
	uItems = OlafMenu.Combo.useItems:Value()
	lastlevel = GetLevel(myHero)-1
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
		if uItems and CanUseSpell(myHero, Hydra) == READY and Hydra ~= 0 and GetDistance(unit) < 200 then
			CastSpell(Hydra)
		elseif uItems and CanUseSpell(myHero, Tiamat) == READY and Tiamat ~= 0 and GetDistance(unit) < 200 then
			CastSpell(Tiamat)
		elseif uItems and CanUseSpell(myHero, Bork) == READY and Bork ~= 0 then
			CastTargetSpell(unit, Bork)
		elseif uItems and CanUseSpell(myHero, Cutlass) == READY and Cutlass ~= 0 then
			CastTargetSpell(unit, Cutlass)		
		end
	end
end

function Olaf:Harass()
	if OlafMenu.Harass.QHarass:Value() and ValidTarget(unit, GetCastRange(myHero, _Q)) then
    	self:ThrollAxe(unit)
    end
    if OlafMenu.Harass.EHarass:Value() and ValidTarget(unit, GetCastRange(myHero, _E)) then
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

    if ValidTarget(unit, GetCastRange(myHero, _E)) then
	    if CanUseSpell(myHero, _E) == READY then
	    	DelayAction(function() CastTargetSpell(unit, _E) end, 10)
	    end
  	end

	if ValidTarget(unit, GetCastRange(myHero, _Q)) then
    	DelayAction(function() self:ThrollAxe(unit) end, 20)
    end

    if ValidTarget(unit, GetCastRange(myHero,_W)) then
		if CanUseSpell(myHero, _W) == READY then
			DelayAction(function() CastSpell(_W) end, 30)
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
	        if ValidTarget(minion, GetCastRange(myHero,_Q)) and myMana > OlafMenu.LaneClear.QMana:Value() then
				MinionPos = GetOrigin(minion)
					if CanUseSpell(myHero, _Q) == READY and OlafMenu.LaneClear.QLaneClear:Value() then
						CastSkillShot(_Q,MinionPos.x,MinionPos.y,MinionPos.z)
					end
	        end
	        if OlafMenu.LaneClear.WLaneClear:Value() and IsReady(_W) and ValidTarget(minion, GetCastRange(myHero,_W)) and myMana > OlafMenu.LaneClear.WMana:Value() and HPercentage < WHP then
	        	DelayAction(function() CastSpell(_W) end, 10)
	        end
	        if OlafMenu.LaneClear.ELaneClear:Value() and IsReady(_E) and ValidTarget(minion, GetCastRange(myHero,_E)) and myMana > OlafMenu.LaneClear.EMana:Value() then
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
			if ValidTarget(jMob, GetCastRange(myHero,_Q)) and myMana > OlafMenu.JungleClear.JMana:Value() then
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

function Olaf:Autolevel()
	if OlafMenu.Misc.Autolvl:Value() then  
	  if GetLevel(myHero) > lastlevel then
	    if Smite ~= nil then
	    	leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
	    else 
	    	leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
	    end
	    DelayAction(function() LevelSpell(leveltable[GetLevel(myHero)]) end, math.random(1000,3000))
	    lastlevel = GetLevel(myHero)
	  end
	end
end

function Olaf:Autoignite()
    for i,enemy in pairs(GetEnemyHeroes()) do
		if Ignite and OlafMenu.Misc.Autoignite:Value() then
	          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*2.5 and ValidTarget(enemy, 600) then
	          CastTargetSpell(enemy, Ignite)
	          end
	    end
	end
end

if GetObjectName(myHero) == "Olaf" then Olaf() end
PrintChat("<font color='#e3ff00'>Scaring - Olaf the Viking</font> <> <font color='#00d12d'>Loaded!</font>")
