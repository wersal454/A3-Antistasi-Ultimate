params ["_unit", "_player", "_actionID"];

//Removing action
[_unit, _actionID] remoteExec ["removeAction", [teamPlayer, civilian], _unit];

if (!alive _unit) exitWith {};
if (_unit getVariable ["interrogated", false]) exitWith {};
_unit setVariable ["interrogated", true, true];

_player globalChat localize "STR_reveal_text";
private _chance = 0;
private _side = side (group _unit);
if (_side == Occupants) then {
	_chance = 100 - aggressionOccupants;
}
else {
	_chance = 100 - aggressionInvaders;
};

_chance = _chance + 10;

sleep 5;

if ((round (random 100)) < _chance) then {
    [(position _unit), 100, 30, true] spawn SCRT_fnc_common_recon;
} else {
	_unit globalChat localize "STR_recruit_fail_text";
};
