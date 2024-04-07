/*
    Author: [Unknown] [Hazey]
    Description:
        Create Ambient Civ Vehicles within city

    Arguments:
        <String> City Marker where you would like the Ambient Civilians traffic created.

    Return Value:
        N/A

    Scope: Any
    Environment: Any
    Public: No

    Example: 
        [[_marker], "A3A_fnc_createAmbientCivTraffic"] call A3A_fnc_scheduler;

    License: MIT License

    Note:
        The marker must be provided from citiesX
*/

if (!isServer and hasInterface) exitWith{};
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_markerX"];

private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false]; // if civs are not human, we don't want them drifting in their ford fiestas

if (_lowCiv) exitWith {};
if (_civNonHuman) exitWith {};

if (_markerX in destroyedSites) exitWith {};

// civ part of cities has a separate spawn state from the garrison
private _spawnKey = _markerX + "_civ";

private _groups = [];
private _vehiclesX = [];
private _groupsPatrol = [];
private _vehPatrol = [];
private _dataX = server getVariable _markerX;
private _area = [_markerX] call A3A_fnc_sizeMarker;
private _positionX = getMarkerPos (_markerX);
private _numCiv = (_dataX#0);
private _numVeh = (_dataX#1);
private _prestigeOPFOR = (_dataX#2);
private _prestigeBLUFOR = (_dataX#3);
private _typeCiv = "";
private _typeVehX = "";
private _dirVeh = 0;

private _roads = nearestTerrainObjects [getMarkerPos _markerX, ["MAIN ROAD", "ROAD", "TRACK"], 250, false, true];

// no bridges or junctions
_roads = _roads select { !(getRoadInfo _x # 8) and (count roadsConnectedTo [_x, true] <= 2) and (count (_x nearRoads 10) < 2)};

if (count _roads == 0) exitWith
{
    Error_1("Roads not found for marker %1", _markerX);
};
_roads = _roads call BIS_fnc_arrayShuffle;

private _maxRoads = count _roads;

_numCiv = 15 * sqrt _numCiv * (1 - tierWar / 20);
private _numParked = _numCiv * (1/60) * civTraffic;
private _numTraffic = _numCiv * (1/300) * civTraffic;

if ((daytime < 8) or (daytime > 21)) then {
    _numParked = _numParked * 1.5; 
    _numTraffic = _numTraffic / 4 ;
};
_numParked = 1 max (round _numParked) min _maxRoads;
_numTraffic = 1 max (round _numTraffic) min _maxRoads;

private _countParked = 0;
while {(spawner getVariable _spawnKey != 2) and (_countParked < _numParked)} do {
    private _p1 = _roads select _countParked;
    private _road = roadAt _p1;
    
    if (!isNull _road) then {
        if ((count (nearestObjects [_p1, ["Car", "Truck"], 5]) == 0) and !([50,1,_road,teamPlayer] call A3A_fnc_distanceUnits)) then {
            _dirveh = 0;
            private _roadcon = roadsConnectedTo [_road, true];

            if (count _roadcon != 0) then {
                private _p2 = getPosATL (_roadcon # 0);
                _dirveh = _p1 getDir _p2;
            };

            private _width = 3 max (getRoadInfo _road # 1 / 2 - 1);
            _pos = [_p1, _width, _dirveh + 90] call BIS_Fnc_relPos;
            _typeVehX = selectRandomWeighted civVehiclesWeighted;

            private _veh = _typeVehX createVehicle _pos;
            _veh setDir _dirveh;
            _veh setFuel random [0.10, 0.30, 0.50];

            // Magazine, Weapon, Item, Backpack, True = Clear
            [_veh, true, true, true, true] call A3A_fnc_clearVehicleCargo;

            _vehiclesX pushBack _veh;
            [_veh, civilian] spawn A3A_fnc_AIVEHinit;
            _veh setVariable ["originalPos", getPosATL _veh];
            };
        };

    sleep 0.5;
    _countParked = _countParked + 1;
};

private _mrkMar = seaSpawn select {getMarkerPos _x inArea _markerX};
if (count _mrkMar > 0) then {
    for "_i" from 0 to (round (random 3)) do {
        if (spawner getVariable _spawnKey != 2) then {
            _typeVehX = selectRandomWeighted civBoatsWeighted;

            // Getting spawn positions can sometimes return empty array.
            // We keep trying to get a safe pos until one is found.
            private _spawnPosition = [];
            _spawnPosition = [(getMarkerPos (_mrkMar select 0)), 5, 50, 5, 2, 0, 0] call A3A_fnc_getSafePos;
            if (_spawnPosition isEqualTo [0,0]) then {
                Debug_1("%1 could not be spawned because no valid spawn position was found.", _typeVehX);
                continue;
            };

            private _veh = _typeVehX createVehicle _spawnPosition;
            _veh setDir (random 360);

            // Magazine, Weapon, Item, Backpack, True = Clear
            [_veh, true, true, true, true] call A3A_fnc_clearVehicleCargo;

            _vehiclesX pushBack _veh;
            [_veh, civilian] spawn A3A_fnc_AIVEHinit;
            _veh setVariable ["originalPos", getPosATL _veh];

            sleep 1;
        };
    };
};

if ([_markerX,false] call A3A_fnc_fogCheck > 0.2) then {
    private _countTraffic = 0;
    private _patrolCities = [_markerX] call A3A_fnc_citiesToCivPatrol;

    if (count _patrolCities > 0) then {
        while {(spawner getVariable _spawnKey != 2) and (_countTraffic < _numTraffic)} do {
            private _p1 = selectRandom _roads;
            private _road = roadAt _p1;
            
            if (!isNull _road) then {
                if (count (nearestObjects [_p1, ["Car", "Truck"], 5]) == 0) then {

                    // Create group and add them to patrol array for deletion later
                    private _groupP = createGroup civilian;
                    _groupsPatrol = _groupsPatrol + [_groupP];

                    // Get connected road and direction for use with facing the vehicle.
                    private _roadcon = roadsConnectedto _road;
                    private _p2 = getPosATL (_roadcon select 0);

                    // Face Vehicle to road direction.
                    _dirveh = [_p1, _p2] call BIS_fnc_DirTo;

                    // Get vehicle type based on weighted value.
                    _typeVehX = selectRandomWeighted civVehiclesWeighted;

                    // Create Civilian Vehicle
                    private _veh = _typeVehX createVehicle (getPosATL _p1);

                    // Set Vehicle direction to that of the road.
                    _veh setDir _dirveh;

                    // Magazine, Weapon, Item, Backpack, True = Clear
                    [_veh, true, true, true, true] call A3A_fnc_clearVehicleCargo;

                    // Add vehicle to currently spawned vehicles patrolling array. Used for deletion later.
                    _vehPatrol = _vehPatrol + [_veh];

                    // Creat AI Unit to add into Civilian Vehicle
                    private _civ = [_groupP, FactionGet(civ, "unitMan"), (getPosATL _p1), [],0, "NONE"] call A3A_fnc_createUnit;

                    // Add Event Handlers to Civilian inside vehicle
                    [_civ] spawn A3A_fnc_civilianInitEH;

                    // Move drive into the vehicle
                    _civ moveInDriver _veh;

                    // Add event handlers to vehicle
                    [_veh, civilian] call A3A_fnc_AIVEHInit;

                    // Add Civilian to vehicle
                    _groupP addVehicle _veh;

                    // Setup Vehicle Bahaviour
                    _groupP setBehaviour "CARELESS";
                    _veh limitSpeed 50;


                    // Create Vehicle waypoints
                    _posDestination = getPosATL (selectRandom (nearestTerrainObjects [getMarkerPos (selectRandom _patrolCities), ["ROAD", "TRACK"], 250, false, true]));
                    private _wp = _groupP addWaypoint [_posDestination,0];
                    _wp setWaypointType "MOVE";
                    _wp setWaypointSpeed "LIMITED";
                    _wp setWaypointTimeout [30, 45, 60];
                    _wp = _groupP addWaypoint [_positionX,1];
                    _wp setWaypointType "MOVE";
                    _wp setWaypointTimeout [30, 45, 60];
                    private _wp1 = _groupP addWaypoint [_positionX,2];
                    _wp1 setWaypointType "CYCLE";
                    _wp1 synchronizeWaypoint [_wp];
                };
            };
            _countTraffic = _countTraffic + 1;
            sleep 5;
        };
    };
};

if (spawner getVariable _spawnKey != 2) then {
    [_markerX] call SCRT_fnc_rivals_trySpawnCarDemo;
};

waitUntil {sleep 1; (spawner getVariable _spawnKey == 2)};
{deleteGroup _x} forEach _groups;

{
    // delete all parked vehicles that haven't been stolen
    if (_x getVariable "ownerSide" == civilian) then {
        if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
        else { [_x] spawn A3A_fnc_VEHdespawner };
    };
} forEach _vehiclesX;

// Chuck all the civ vehicle patrols into the despawners
{ [_x] spawn A3A_fnc_groupDespawner } forEach _groupsPatrol;
{ [_x] spawn A3A_fnc_VEHdespawner } forEach _vehPatrol;
