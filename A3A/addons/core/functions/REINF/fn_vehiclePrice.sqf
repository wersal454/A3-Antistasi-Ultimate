#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_typeX"];

private _costs = server getVariable _typeX;

private _defaultPrice = 100;

_costs = if (isNil "_costs") then {
	Error_1("Invalid vehicle price :%1.", _typeX);

	0
} else {
	private _multiplier = if (count seaports > 0) then {
		{sidesX getVariable [_x,sideUnknown] == teamPlayer} count seaports;
	} else {
		{sidesX getVariable [_x,sideUnknown] == teamPlayer} count resourcesX;
	};

	round (_costs - (_costs * (0.1 * _multiplier)))
};

if (_costs < _defaultPrice) then { // if the cost is less than the default (lowest) price
	[format ["%1 was an invalid price. Defaulting to %2", _costs, _defaultPrice], _fnc_scriptName] call A3U_fnc_log;
	_costs = _defaultPrice; // reset the cost to the default (lowest) price
};

_costs
