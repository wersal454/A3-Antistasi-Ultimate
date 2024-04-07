params ["_veh"];


if !(alive _veh) exitWith {};
if !(local _veh) exitWith {};

private _smoked = _veh getVariable ["smoked",0];

if (time < _smoked) exitWith {};

_veh setVariable ["smoked",time + 120];

if ((allTurrets _veh) findIf {"SmokeLauncher" in (_veh weaponsTurret _x)} != -1) then {
	[_veh,"SmokeLauncher"] call BIS_fnc_fire;
};
