params ["_markerX"];

private _positionX = getMarkerPos _markerX;
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _buildings = _positionX nearobjects ["house",_size];

{
	if (random 100 < 70) then {
		for "_i" from 1 to 7 do {
			_x setHit [format ["dam%1",_i],1];
			_x setHit [format ["dam %1",_i],1];
		};
	};
} forEach _buildings;

[_markerX,false] spawn A3A_fnc_blackout;