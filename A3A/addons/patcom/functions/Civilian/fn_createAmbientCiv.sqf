/*
    Author: [Hazey]
    Description:
        Create Ambient Civ's within city

    Arguments:
        <String> City Marker where you would like the Ambient Civilians created.
        Note, the marker must be provided from citiesX

    Return Value:
        N/A

    Scope: Any
    Environment: Any
    Public: No

    Example: 
        [[_marker], "A3A_fnc_createAmbientCiv"] call A3A_fnc_scheduler;

    License: MIT License
*/

#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_markerX"];

// We only want to run on the server and not on the players
if (!isServer and hasInterface) exitWith {};

if (_markerX in destroyedSites) exitWith {};

private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];

if (_lowCiv) exitWith {};
if ("seaport" in _markerX && {_civNonHuman}) exitWith {};

private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _faction = Faction(_sideX);

private _groupSide = civilian;

private _spawnKey = _markerX + "_civ";
private _civilianGroups = [];
private _soundSources = [];
private _lightSources = [];
private _civilians = [];
private _special = [];
private _buildings = [];
private _building = objNull;
private _positionX = getMarkerPos (_markerX);
private _locationRadius = [_markerX] call A3A_fnc_sizeMarker;
private _dayState = [] call A3A_fnc_getDayState;

_buildings = nearestObjects [_positionX, ["House"], _locationRadius];

Info_2("Spawning City Civilians in %1 with a radius of %2", _markerX, _locationRadius);

private _city = if (_positionX isEqualType "") then {_positionX} else {[citiesX, _positionX] call BIS_fnc_nearestPosition};
private _cityData = server getVariable _city;
private _numCiv = round (1.5 * sqrt (_cityData # 0) * (1 - tierWar / 20));

// We don't want to add too many civ's.
if (_numCiv > maxCiviliansPerTown) then {
    _numCiv = maxCiviliansPerTown;
};

if (_faction isEqualTo A3A_faction_reb && {_civNonHuman}) exitWith {
    if (count units civilian >= globalCivilianMax) exitWith {
        Info("Global Civilian spawn limit reached! - Exiting");
    };

    for "_i" from 1 to _numCiv do {
        private _groupX = createGroup _groupSide;
        private _spawnPosition = [_positionX, 10, 150, 3, 0, -1, 0] call A3A_fnc_getSafePos;
        private _civUnit = [_groupX, FactionGet(civ, "unitMan"), _spawnPosition, [],0, "NONE"] call A3A_fnc_createUnit;
        _civUnit setPosATL _spawnPosition;
        _civilianGroups pushBack _groupX;
        _civilians pushBack _civUnit;
        [_civUnit] spawn A3A_fnc_civilianInitEH;
        [_groupX] call A3A_fnc_patrolLoop;
    };

    // need to repaste this so civs actually get removed
    waitUntil {sleep 1;(spawner getVariable _spawnKey == 2)};
    {if (alive _x) then {deleteVehicle _x};} forEach _civilians;
    { deleteGroup _x } forEach _civilianGroups;
    {deleteVehicle _x} forEach _soundSources;
    {deleteVehicle _x} forEach _lightSources;
}; // we don't want enemies spawning in friendly cities, call them "safe havens"

// Disregard the above statement if civs aren't human
if (_civNonHuman) exitWith
{
    if (count _special >= (globalCivilianMax * 2) && {zombiesUncapped isEqualTo false}) exitWith {
        Info("Global spawn limit reached! - Exiting");
    };

    // if (_numCiv < 5) then {_numCiv = _numCiv * 2}; // we want the cities to be infested, no?
    if (maxCiviliansPerTown <= 10) then {
        _numCiv = random [6, 8, 10];
    };

    if (zombiesUncapped isEqualTo true) then {
        _numCiv = _numCiv * (selectRandom [2,3]);
    };
    
    switch _faction do
    {
        case A3A_faction_occ : 
        {
            _groupSide = east; // if city is occupant, make the zombies invader
        };
        case A3A_faction_inv : 
        {
            _groupSide = west; // if city is invader, make the zombies occupant
        };
    };

    for "_i" from 1 to _numCiv do {
        private _groupX = createGroup _groupSide;
        private _spawnPosition = [_positionX, 10, 30, 3, 0, -1, 0] call A3A_fnc_getSafePos;

        private _civUnit = [_groupX, FactionGet(civ, "unitSpecial"), _spawnPosition, [],0, "NONE"] call A3A_fnc_createUnit;

        _civUnit setPosATL _spawnPosition;
        _civilianGroups pushBack _groupX;
        _special pushBack _civUnit;
        [_civUnit] spawn A3A_fnc_civilianInitEH;
        [_groupX] call A3A_fnc_patrolLoop;
    };

    // need to repaste this so civs actually get removed
    waitUntil {sleep 1;(spawner getVariable _spawnKey == 2)};
    {if (alive _x) then {deleteVehicle _x};} forEach _civilians;
    {if (alive _x) then {deleteVehicle _x};} forEach _special;
    { deleteGroup _x } forEach _civilianGroups;
    {deleteVehicle _x} forEach _soundSources;
    {deleteVehicle _x} forEach _lightSources;
}; // This ensures the zombies are always aggro to the city owner

if (random 100 < ((aggressionOccupants) + (aggressionInvaders)) && {_civNonHuman isEqualTo false}) then {
    private _spawnPosition = [_positionX, 10, 150, 3, 0, -1, 0] call A3A_fnc_getSafePos;
    private _groupX = createGroup _groupSide;
    _civilianGroups pushBack _groupX;
    private _civPress = [_groupX, FactionGet(civ, "unitPress"), _spawnPosition, [],0, "NONE"] call A3A_fnc_createUnit;
    [_civPress] spawn A3A_fnc_civilianInitEH;
    _civilians pushBack _civPress;
    [_groupX, "Patrol_Area", 5, 50, 300, false, [], false] call A3A_fnc_patrolLoop;
};

for "_i" from 1 to _numCiv do {
    if (count units civilian >= globalCivilianMax) exitWith {
        Info("Global Civilian spawn limit reached! - Exiting");
    };

    private _posHouse = [];

    if (count _buildings > 0 && {_civNonHuman isEqualTo false}) then {
        _building = selectRandom _buildings;
        private _housePositions = [_building] call BIS_fnc_buildingPositions;
        _buildings deleteAt (_buildings find _building);

        if !(_housePositions isEqualTo []) then {
            _posHouse = selectRandom _housePositions;
        } else {
            _posHouse = [_positionX, 10, 150, 3, 0, -1, 0] call A3A_fnc_getSafePos;
        };

        private _groupX = createGroup _groupSide;

        private _civUnit = [_groupX, FactionGet(civ, "unitMan"), _posHouse, [], 0, "NONE"] call A3A_fnc_createUnit;

        _civUnit setPosATL _posHouse;
        _civilianGroups pushBack _groupX;
        _civilians pushBack _civUnit;
        [_civUnit] spawn A3A_fnc_civilianInitEH;

        // Actions to do during the evening hours of spawn.
        if (_dayState == "EVENING" || {_dayState == "NIGHT"}) then {
            _light = [_building] call A3A_fnc_createRoomLight;
            _lightSources pushBack _light;
        };

        // Actions to do during the morning hours of spawn.
        if (_dayState == "MORNING") then {
            if (4 > random 10) then {
                private _soundSource = [_building] call A3A_fnc_createMusicSource;
                _soundSources pushBack _soundSource;
            };
            _light = [_building] call A3A_fnc_createRoomLight;
            _lightSources pushBack _light;
        };

        // Actions to do during the day hours of spawn
        if (_dayState == "DAY") then {
            if (7 > random 10) then {
                private _soundSource = [_building] call A3A_fnc_createMusicSource;
                _soundSources pushBack _soundSource;
            };

            [_groupX] call A3A_fnc_patrolLoop;
        };

    } else {
        private _groupX = createGroup _groupSide;
        private _spawnPosition = [_positionX, 10, 150, 3, 0, -1, 0] call A3A_fnc_getSafePos;

        private _civUnit = [_groupX, FactionGet(civ, "unitMan"), _posHouse, [], 0, "NONE"] call A3A_fnc_createUnit;

        _civUnit setPosATL _spawnPosition;
        _civilianGroups pushBack _groupX;
        _civilians pushBack _civUnit;
        [_civUnit] spawn A3A_fnc_civilianInitEH;
        [_groupX] call A3A_fnc_patrolLoop;
    };
};

// Handle removal of civ's.
waitUntil {sleep 1;(spawner getVariable _spawnKey == 2)};
{if (alive _x) then {deleteVehicle _x};} forEach _civilians;
{ deleteGroup _x } forEach _civilianGroups;
{deleteVehicle _x} forEach _soundSources;
{deleteVehicle _x} forEach _lightSources;