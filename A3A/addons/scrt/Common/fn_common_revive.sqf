/*
    Instant revive of target via Self-Revive Kit.

Arguments:
    <OBJECT> Reviver - person who revives
    <OBJECT> Revivee - revivable person

Return Value:
    <NIL>

Scope: Local
Environment: Any
Public: Yes
Dependencies:
    NONE

Example:
[player, _unit] call SCRT_fnc_common_revive;
*/

params [
	["_reviver", objNull, [objNull]],
	["_revivee", objNull, [objNull]]
];

_reviver removeItem "A3AP_SelfReviveKit";

_revivee setVariable ["incapacitated",false,true]; 
_revivee setDamage 0.25;

[localize "STR_A3AP_items_crrk_name", localize "STR_antistasi_actions_crk_used"] call A3A_fnc_customHint;
playSound "A3AP_UiSuccess";
