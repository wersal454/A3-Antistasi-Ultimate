#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

private _buyableVehiclesList = [];

private _stock = (A3A_faction_reb get "blackMarketStock") select {
	private _fnc_isAvailable = _x select 3;
	
	call _fnc_isAvailable
};

if (_stock isEqualTo []) exitWith {_buyableVehiclesList};

_stock = _stock apply {_x select 0};

{
	private _vehiclePrice = [_x] call A3A_fnc_vehiclePrice;
	_buyableVehiclesList pushBack [_x, _vehiclePrice, false];
} forEach _stock;


_buyableVehiclesList;