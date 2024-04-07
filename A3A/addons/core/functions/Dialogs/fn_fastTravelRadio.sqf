private _markersX = markersX + [respawnTeamPlayer];

if (!isNil "traderMarker") then {
	_markersX pushBack traderMarker;
};

if (!isNil "isRallyPointPlaced" && {isRallyPointPlaced}) then {
	_markersX pushBack rallyPointMarker;
};

private _esHC = false;
if (count hcSelected player > 1) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_error_only_one_hc"] call SCRT_fnc_misc_deniedHint
};

private _groupX = nil;
if (count hcSelected player == 1) then {
	_groupX = hcSelected player select 0; 
	_esHC = true;
} else {
	_groupX = group player;
};
private _checkForPlayer = false;
if (!_esHC and {limitedFT}) then {_checkForPlayer = true};
private _boss = leader _groupX;

if (_boss != player and {!_esHC}) then {_groupX = player};

if (_esHC && {{isPlayer _x} count units _groupX > 1}) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_error_player"] call SCRT_fnc_misc_deniedHint;
};

if (player != player getVariable ["owner",player]) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_controlai"] call SCRT_fnc_misc_deniedHint;
};

if (!_esHC and !isNil {vehicle player getVariable "SA_Tow_Ropes"}) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_towing"] call SCRT_fnc_misc_deniedHint;
};

if (!isNil "A3A_FFPun_Jailed" && {(getPlayerUID player) in A3A_FFPun_Jailed}) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_ff"] call SCRT_fnc_misc_deniedHint;
};

private _units = units _groupX;

if (_units findIf {
	vehicle _x != _x and ((!isPlayer (driver vehicle _x) && isNull (driver vehicle _x)) or !canMove vehicle _x or vehicle _x isKindOf "Boat")
} != -1) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_multiple"] call SCRT_fnc_misc_deniedHint;
};

positionTel = [];

[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_click"] call A3A_fnc_customHint;
if (!visibleMap) then {openMap true};
showCommandingMenu "";
onMapSingleClick "positionTel = _pos; true";

waitUntil {sleep 1; (count positionTel > 0) or {not visiblemap}};
onMapSingleClick "";

private _positionTel = positionTel;
private _earlyEscape = false;

if (count _positionTel > 0) then {
	private _base = [_markersX, _positionTel] call BIS_fnc_nearestPosition;
	if (!isNil "rallyPointMarker" && {_base == rallyPointMarker}) then {
		[] spawn SCRT_fnc_rally_travelToRallyPoint;
		openMap false;
		_earlyEscape = true;
	};
};

if (_earlyEscape) exitWith {};

private _areEnemiesNearby = false;

if (!fastTravelEnemyCheck && {[getPosATL player] call A3A_fnc_enemyNearCheck}) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_enemiesnear_individual"] call SCRT_fnc_misc_deniedHint;
};

if (fastTravelEnemyCheck && {_units findIf {[getPosATL _x] call A3A_fnc_enemyNearCheck} != -1}) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_enemiesnear_group"] call SCRT_fnc_misc_deniedHint;
};

if (vehicle player != player && {driver vehicle player != player}) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_only_drivers"] call SCRT_fnc_misc_deniedHint;
};

if (_positionTel isEqualTo []) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_missclick"] call SCRT_fnc_misc_deniedHint;
};

private _base = [_markersX, _positionTel] call BIS_Fnc_nearestPosition;

private _rebelMarkers = if (!isNil "traderMarker") then {["Synd_HQ", traderMarker]} else {["Synd_HQ"]};
if (_checkForPlayer && {!(_base in (_rebelMarkers + airportsX + milbases))}) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_limited"] call SCRT_fnc_misc_deniedHint;
};

if ((sidesX getVariable [_base,sideUnknown]) in [Occupants, Invaders]) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_enemy_zone"] call SCRT_fnc_misc_deniedHint; 
	openMap [false,false];
};
if (_base in forcedSpawn) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_enemy_attack"] call SCRT_fnc_misc_deniedHint; 
	openMap [false,false];
};

if ([getMarkerPos _base] call A3A_fnc_enemyNearCheck) exitWith {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_enemy_surrounding"] call A3A_fnc_customHint; 
	openMap [false,false];
};

if (_positionTel distance getMarkerPos _base < 50) then {
	private _positionX = [getMarkerPos _base, 10, random 360] call BIS_Fnc_relPos;
	private _distanceX = round (((position _boss) distance _positionX)/200);
	private _forcedX = false;
	
	if (!_esHC) then {
		disableUserInput true; 
		cutText [format [localize "STR_hints_FT_timer", _distanceX],"BLACK",1]; 
		sleep 1;
	} else {
		[localize "STR_A3A_Dialogs_fast_travel_header", format [localize "STR_A3A_Dialogs_fast_travel_moving_hc_group",groupID _groupX]] call A3A_fnc_customHint; 
		sleep _distanceX;
	};
	
	if (!_esHC) then {
		private _timePassed = 0;
		while {_timePassed < _distanceX} do {
			cutText [format [localize "STR_hints_FT_timer", (_distanceX - _timePassed)],"BLACK",0.0001];
			sleep 1;
			_timePassed = _timePassed + 1;
		};
	};
	private _exit = false;
	if (limitedFT) then {
		_vehicles = [];
		{if (vehicle _x != _x) then {_vehicles pushBackUnique (vehicle _x)}} forEach units _groupX;
		{if ((vehicle _x) in _vehicles) exitWith {_checkForPlayer = true}} forEach (call A3A_fnc_playableUnits);
	};

	if (_checkForPlayer and {!(_base in (_rebelMarkers + airportsX + milbases))}) exitWith {
		[localize "STR_A3A_Dialogs_fast_travel_header", format [localize "STR_A3A_Dialogs_fast_travel_cancel",groupID _groupX]] call A3A_fnc_customHint;
	};

	private _movedUnits = units _groupX;

	{
		private _unit = _x;
		if (!isPlayer _unit or {_unit == player}) then {
			_unit allowDamage false;
			if (_unit != vehicle _unit) then {
				if (driver vehicle _unit == _unit) then {
					sleep 3;
					_radiusX = 10;
					private _roads = [];
					while {true} do {
						_roads = _positionX nearRoads _radiusX;
						if (count _roads > 0) exitWith {};
						_radiusX = _radiusX + 10;
					};
					_road = _roads select 0;
					private _pos = position _road findEmptyPosition [10,100,typeOf (vehicle _unit)];
					vehicle _unit setPos _pos;
				};
				if ((vehicle _unit isKindOf "StaticWeapon") and (!isPlayer (leader _unit))) then {
				private _pos = _positionX findEmptyPosition [10,100,typeOf (vehicle _unit)];
				vehicle _unit setPosATL _pos;
				};
			} else {
				if (!(_unit getVariable ["incapacitated",false])) then {
					_positionX = _positionX findEmptyPosition [1,50,typeOf _unit];
					_unit setPosATL _positionX;
					if (isPlayer leader _unit) then {_unit setVariable ["rearming",false]};
					_unit doWatch objNull;
					_unit doFollow leader _unit;
				} else {
					_positionX = _positionX findEmptyPosition [1,50,typeOf _unit];
					_unit setPosATL _positionX;
				};
			};
		};
	} forEach _movedUnits;
	if (!_esHC) then {
		disableUserInput false;
		cutText [localize "STR_hints_FT_dest","BLACK IN",1]
	} else {
		[localize "STR_A3A_Dialogs_fast_travel_header", format [localize "STR_A3A_Dialogs_fast_travel_arrived_hc",groupID _groupX]] call A3A_fnc_customHint;
	};

	if (_forcedX) then {
		forcedSpawn deleteAt (forcedSpawn find _base);
	};
	
	sleep 5;
	{_x allowDamage true} forEach _movedUnits;
} else {
	[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_missclick"] call SCRT_fnc_misc_deniedHint;
};

if (!_esHC) then { openMap false };
