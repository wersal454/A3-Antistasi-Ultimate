params ["_unit", "_eny"];

if ({isPlayer _x} count (units group _unit) > 0) exitWith {};
if (time < _unit getVariable ["supressing",time - 1]) exitWith {};
if (([objNull, "VIEW"] checkVisibility [eyePos _eny, eyePos _unit]) == 0) exitWith {};

_unit setVariable ["supressing",time + 60];
_unit commandSuppressiveFire _eny;
_unit suppressFor 10;
