/****************************************************************
File: A3A_fnc_isBuildingPosition.sqf
Author: Azroul13

Description:
	 Check if the AI is in a building.

Parameter(s):
	<--- Unit
Returns:
	boolean
****************************************************************/
params ["_pos"];

if ((_pos select 2) == 0) then {_pos = ATLtoASL _pos};

private _Inbuilding = false;
private _Roof = lineIntersectsWith [_pos, [(_pos select 0), (_pos select 1), (_pos select 2) + 20]];

If (count _Roof > 0) then
{
	_Inbuilding = (_Roof select 0) isKindOf "BUILDING";
};

If (!_Inbuilding) then
{
	private _Down = lineIntersectsWith [_pos, [(_pos select 0), (_pos select 1), (_pos select 2) - 20]];
	if (count _Down > 0) then
	{
		_Inbuilding = (_Down select 0) isKindOf "BUILDING";
	};
};

_Inbuilding