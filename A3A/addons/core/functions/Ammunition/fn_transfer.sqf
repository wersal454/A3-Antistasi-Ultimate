private _truckX = vehicle player;
private _objectsX = [];
private _todo = [];

[driver _truckX,"remove"] remoteExec ["A3A_fnc_flagaction",driver _truckX];

_objectsX = nearestObjects [_truckX, ["ReammoBox_F"], 20];

if (_objectsX isEqualTo []) exitWith {};
private _boxX = _objectsX select 0;

if (_boxX == boxX and {player!=theBoss}) exitWith {
	[localize "STR_A3A_ammunition_transfer_header", localize "STR_A3A_ammunition_transfer_reject_only_commander"] call A3A_fnc_customHint; 
	[driver _truckX,"truckX"] remoteExec ["A3A_fnc_flagaction",driver _truckX]
};


private _weaponsX = weaponCargo _boxX;
private _ammunition = magazineCargo _boxX;
private _items = itemCargo _boxX;
private _backpcks = [];
private _proceed = false;

_todo = _weaponsX + _ammunition + _items + _backpcks;
private _countX = count _todo;

if (_countX < 1) then {
	[localize "STR_A3A_ammunition_transfer_header", localize "STR_A3A_ammunition_transfer_reject_closest_ammobox_empty"] call A3A_fnc_customHint;
	_proceed = true;
};

if (_countX > 0) then {
	if (_boxX == boxX) then {
		if ("DEF_HQ" in A3A_activeTasks) then {_countX = round (_countX / 10)} else {_countX = round (_countX / 100)};
	} else {
		_countX = round (_countX / 5);
	};
	if (_countX < 1) then {_countX = 1};

	while {_truckX == vehicle player and {speed _truckX == 0 and {_countX > 0}}} do {
		[localize "STR_A3A_ammunition_transfer_header", format [localize "STR_A3A_ammunition_transfer_truck_loading", _countX]] call A3A_fnc_customHint;
		_countX = _countX -1;
		sleep 1;
		if (_countX == 0) then {
			[_boxX,_truckX] remoteExec ["A3A_fnc_ammunitionTransfer",2];
			_proceed = true;
		};
		if ((_truckX != vehicle player) or (speed _truckX != 0)) then {
			[localize "STR_A3A_ammunition_transfer_header", localize "STR_A3A_ammunition_transfer_abort_truck_movement"] call A3A_fnc_customHint;
			_proceed = true;
		};
	};
};

if (_proceed) then {[driver _truckX,"truckX"] remoteExec ["A3A_fnc_flagaction",driver _truckX]};
