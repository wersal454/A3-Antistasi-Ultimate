#include "..\defines.inc"
FIX_LINE_NUMBERS()

Info("Post Ambush Vehicle Event Init.");

private _vehicles = [];
private _groups = [];
private _others = [];

private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);

if (isNil "_player") exitWith {
    Error("No players found, aborting.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};

private _originPosition = position _player;

Info_2("%1 will be used as center of the event at %2 position.", name _player, str _originPosition);

private _spawnPosition = [_originPosition, 900, distanceSPWN, 0, 0] call BIS_fnc_findSafePos;
private _road = objNull;
private _radiusX = 5;

while {true} do {
    _road = _spawnPosition nearRoads _radiusX;
    if (count _road > 0 && {_road findIf {(position _x) distance2D _originPosition > 500} != -1}) exitWith {};
    _radiusX = _radiusX + 5;
};

private _roadcon = roadsConnectedto ((_road select {(position _x) distance2D _originPosition > 500}) select 0); //guaranteed due to top condition on road search
private _dirveh = if (count _roadcon > 0) then {[_road select 0, _roadcon select 0] call BIS_fnc_dirTo} else {random 360};
private _roadPosition = getPos (_road select 0);

private _crater = createVehicle ["CraterLong", _roadPosition, [], 0, "CAN_COLLIDE"];
_crater setDir _dirveh;
_crater setVectorUp surfaceNormal getPos _crater;
_others pushBack _crater;

private _marker = [(markersX select {sidesX getVariable [_x, sideUnknown] != teamPlayer}), _originPosition] call BIS_fnc_nearestPosition;
//probably should be a distance check, but who cares
private _side = sidesX getVariable [_marker, Occupants];
private _faction = Faction(_side);

private _isFia = if (random 10 > (tierWar + difficultyCoef)) then {true} else {false};
private _vehicleClass = if (_isFia) then {
     selectRandom ((_faction get "vehiclesMilitiaLightArmed") +  (_faction get "vehiclesMilitiaAPCs"));
} else {
    selectRandom ((_faction get "vehiclesAPCs") +  (_faction get "vehiclesIFVs") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesLightArmed"));
};

if (_vehicleClass == "") exitWith {
    Error("No vehicle class, aborting.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};

private _crewClass = if (_vehicleClass in (
    (_faction get "vehiclesAPCs") +  
    (_faction get "vehiclesIFVs") + 
    (_faction get "vehiclesLightTanks") + 
    (_faction get "vehiclesMilitiaAPCs")
)) then {
    _faction get "unitCrew"
} else {
    [(_faction get "unitRifle")] call SCRT_fnc_unit_getTiered
};


private _crashedVehicle = createVehicle [_vehicleClass, [_roadPosition select 0, _roadPosition select 1, 0.9], [], 0, "CAN_COLLIDE"];
_crashedVehicle setDir _dirveh;
_crashedVehicle setDamage 0.7;
_crashedVehicle setHit ["wheel_2_1_steering", 1];
_crashedVehicle setHit ["wheel_1_1_steering", 1];
_crashedVehicle setFuel 0;
[_crashedVehicle, _side] call A3A_fnc_AIVEHinit;
_vehicles pushBack _crashedVehicle;

for "_i" from 0 to (random [3,5,6]) do {
    _firePosition = [
        _roadPosition, 
        2,
        25,
        2
    ] call BIS_fnc_findSafePos;

    [_firePosition, 5000] remoteExec ["SCRT_fnc_effect_createBurningDebrisEffect", 0, _crashedVehicle];

    private _fireEffectEmitter = "#particlesource" createVehicle _firePosition;
    [_fireEffectEmitter, "SmallDestructionFire"] remoteExec ["setParticleClass", 0, _fireEffectEmitter];

    private _lightEffectEmitter = "#lightpoint" createVehicle _firePosition; 
    [_lightEffectEmitter, 0.3] remoteExec ["setLightBrightness", 0, _lightEffectEmitter];
    [_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightAmbient", 0, _lightEffectEmitter];
    [_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightColor", 0, _lightEffectEmitter];

    _others append [_fireEffectEmitter, _lightEffectEmitter];
};

private _groupCrew = createGroup _side;
for "_i" from 1 to 3 do {
    private _crew = [_groupCrew, _crewClass, _roadPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_crew] call A3A_fnc_NATOinit;

    if ((random 100) > 20) then {
        sleep 0.5;
        _crew setDamage 1;
        private _dir = [_crew,_crashedVehicle] call BIS_fnc_dirTo;
        _crew setDir (_dir - 180);
    } else {
        _crew removeItems "FirstAidKit";
        sleep 0.1;
        _crew setDamage 0.8;
    };
};
_groups pushBack _groupCrew;

private _timeOut = time + 1200;
waitUntil { 
    sleep 5; 
    time > _timeOut || 
    {!alive _crashedVehicle || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D (position _crashedVehicle) < distanceSPWN} == -1
}}};

{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
{deleteVehicle _x} forEach _others;

isEventInProgress = false;
publicVariableServer "isEventInProgress";

Info("Post Ambush Vehicle Event clean up complete.");