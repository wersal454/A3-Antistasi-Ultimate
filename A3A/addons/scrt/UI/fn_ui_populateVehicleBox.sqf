#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
	["_category", "", [""]]
];

private _buyableVehiclesList = [];
private _vehicleClasses = [];
private _isCivilian = false;

switch (_category) do {
    case "civilian": {
        private _civilianVehicles = 
			(A3A_faction_reb get 'vehiclesCivCar') +
			(A3A_faction_reb get 'vehiclesCivTruck') +
			(A3A_faction_reb get 'vehiclesCivBoat') select {_x isNotEqualTo ""};
		
		private _civAircrafts = (A3A_faction_reb get "vehiclesCivHeli") + (A3A_faction_reb get 'vehiclesCivPlane');
		if (_civAircrafts isNotEqualTo [] && {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0}) then {
			_civilianVehicles append _civAircrafts;
		};

		_isCivilian = true;
		_vehicleClasses = _civilianVehicles;
    };
	case "military": {
		private _militaryVehicles = 
			(A3A_faction_reb get 'vehiclesBasic') + 
			(A3A_faction_reb get 'vehiclesTruck') + 
			(A3A_faction_reb get 'vehiclesLightUnarmed') +
			(A3A_faction_reb get 'vehiclesBoat') + 
			(A3A_faction_reb get 'vehiclesMedical')
		select {_x isNotEqualTo []};

		if (tierWar > 2) then {
			private _availableVehs = (A3A_faction_reb get 'vehiclesLightArmed') select {_x isNotEqualTo ""};
			_militaryVehicles append _availableVehs;
		};

		if (tierWar > 3) then {
			private _availableVehs = 
				(A3A_faction_reb get 'vehiclesAT') + 
				(A3A_faction_reb get 'vehiclesAA') select {_x isNotEqualTo []};
			_militaryVehicles append _availableVehs;
		};

		private _milAircrafts = A3A_faction_reb get "vehiclesPlane";
		if (_milAircrafts isNotEqualTo [] && {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0}) then {
			_militaryVehicles append _milAircrafts;
		};

		_vehicleClasses = _militaryVehicles;
	};
	case "static": {
		private _statics = [];
		
		if (tierWar > 2) then {
			private _availableVehs = (A3A_faction_reb get 'staticMGs') select {_x isNotEqualTo []};
			_statics append _availableVehs;
		};

		 (A3A_faction_reb get 'staticMGs') select {_x isNotEqualTo []};

		if (tierWar > 3) then {
			private _availableVehs = 
				(A3A_faction_reb get 'staticAT') +
				(A3A_faction_reb get 'staticAA') select {_x isNotEqualTo []};
			_statics append _availableVehs;
		};

		if (tierWar > 4) then {
			private _mortars = A3A_faction_reb get 'staticMortars';
			if (_mortars isNotEqualTo []) then {
				_statics append _mortars;
			};
		};

		_vehicleClasses = _statics;
	};
	default {
		Error_1("Invalid vehicle category, given was %1", _category);
	};
};

{
	private _vehiclePrice = [_x] call A3A_fnc_vehiclePrice;
	_buyableVehiclesList pushBack [_x, _vehiclePrice, _isCivilian];
} forEach _vehicleClasses;

_buyableVehiclesList;