#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

private _unit = _this select 0;
if (debug) then {
    Debug_1("Unit: %1", _unit);
};
if ((isNil "_unit") || (isNull _unit)) exitWith {
    Error_1("Problem with NATO Param: %1", _this);
};
private  _markerX = "";
if (count _this > 1) then {
	_markerX = _this select 1;
	_unit setVariable ["markerX",_markerX,true];
	if ((spawner getVariable _markerX != 0) and (vehicle _unit != _unit)) then {
		[_unit,false] remoteExec ["enableSimulationGlobal",2];
	};
};

[_unit] call A3A_fnc_initRevive;
_unit allowFleeing 0;

private _typeX = _unit getVariable "unitType";
private _skill = (0.1 + 0.1*A3A_rebelSkillMul + 0.015 * skillFIA);
_unit setSkill _skill;

if (_typeX isEqualTo FactionGet(reb,"unitSL")) then {
	_unit setskill ["courage",_skill + 0.2];
	_unit setskill ["commanding",_skill + 0.2];
};
if (_typeX isEqualTo FactionGet(reb,"unitSniper")) then {
	_unit setskill ["aimingAccuracy",_skill + 0.2];
	_unit setskill ["aimingShake",_skill + 0.2];
};

[_unit, 2] call A3A_fnc_equipRebel;			// 2 = garrison unit
_unit selectWeapon (primaryWeapon _unit);

private _killedEhId = _unit addEventHandler ["killed", {
	_victim = _this select 0;
	_killer = _this select 1;
	[_victim] remoteExec ["A3A_fnc_postmortem",2];
    [side _killer, -1, 30] remoteExec ["A3A_fnc_addAggression", 2];
	if (side _killer == Occupants) then
	{
		[0,-0.25,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
	};
	_markerX = _victim getVariable "markerX";
	if (!isNil "_markerX") then {
		if (sidesX getVariable [_markerX,sideUnknown] == teamPlayer) then {
			[_victim getVariable "unitType",teamPlayer,_markerX,-1] remoteExec ["A3A_fnc_garrisonUpdate",2];
			_victim setVariable [_markerX,nil,true];
		};
	};
}];

//Reveals all air vehicles to the unit, if it is either gunner of a vehicle or equipped with a launcher
if (_unit == gunner objectParent _unit or {(secondaryWeapon _unit) in allAA}) then {
    {
        if (!isNull driver _x) then { _unit reveal [_x, 1.5] };
    } forEach (_unit nearEntities ["Air", distanceSPWN*2]);
};
