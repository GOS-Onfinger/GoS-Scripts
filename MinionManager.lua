local _all, _enemy, _ally, _jungle, _unknown = 1,2,3,4,5
local _minTbl = { {}, {}, {}, {}, {} }

function ObjectLoopEvent(Object,myHero)
		
		local Obj_Type = GetObjectType(Object)
		local Obj_networkID = GetNetworkID(Object)

		if Obj_Type == Obj_AI_Minion and not _minTbl[_all][Obj_networkID] then

		if IsObjectAlive(Object) then

			_minTbl[_all][Obj_networkID] = Object
			
			if GetTeam(myHero) == GetTeam(Object) then _minTbl[_ally][Obj_networkID] = Object
								
			elseif GetTeam(myHero) ~= GetTeam(Object) and GetTeam(Object) == 100 or 200 then _minTbl[_enemy][Obj_networkID] = Object
			
			elseif GetTeam(Object) == 300 then _minTbl[_jungle][Obj_networkID] = Object
			
			else _minTbl[_unknown][Obj_networkID] = Object
			
			end

		end
		
		end

end

function GetMinions(optmode, optrange, optobject)
  
	retObjs = {}
	
	if optobject == nil then optobject = GetMyHero() end
	
	rSqr = optrange * optrange
					
	
    if not _minTbl[optmode] then return end
	
	local origin = GetOrigin(optobject)
	
    for _, object in pairs(_minTbl[optmode]) do
		
	
        if IsObjectAlive(object) and GetDistanceSqr(origin, GetOrigin(object)) <= rSqr then
		
		DrawText('Minions In Range',20,150,280,0xffffffff)
		
            table.insert(retObjs, object)
			
        end
		
    end
	
	return retObjs
	
end

function GetDistanceSqr(p1, p2)

    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
	
end
