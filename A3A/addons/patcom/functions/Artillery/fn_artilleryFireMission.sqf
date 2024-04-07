/*
    Author: [Hazey]
    Description:
        Calls artillery firemission to select a battery and fire at a given location.

    Arguments:
        <Array> Position where you want the artillery strike to happen.
        <Number> Area in which you want the artillery strike to happen in.
        <String> Type of round, "HE", "Flare", "Smoke".
        <Number> Number of rounds you want fired.
        <Object> Unit who called in the artillery strike. (Mainly for debug purposes).

    Return Value:
        N/A

    Scope: Any
    Environment: Any
    Public: No

    Example: 
        [getPosATL _instigator, (random 150), "HE", 6, _unit] call A3A_fnc_artilleryFireMission;

    License: MIT License
*/

#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_targetPos", "_area", "_roundType", "_rounds", "_callerGroup"];	

private _batteryArray = [];
private _side = side _callerGroup;

/////// GET ACTIVE BATTERY ARRAY FOR CALLERS SIDE \\\\\\\
{
    if !(_x getVariable ["PATCOM_ArtilleryBusy", false]) then {
        {
            private _veh = vehicle _x;
            private _class = typeOf _veh;
            if ((_class == "") || (gunner _veh != _x)) then { continue; };
            private _artyChk = getNumber(configfile/"CfgVehicles"/_class/"artilleryScanner");
            if (_artyChk isEqualTo 1) then {
                if !(_veh in _batteryArray) then {
                    _batteryArray pushBackUnique _veh;
                };
            };
        } forEach (units _x);
    };
} forEach ((groups _side) select {_x getVariable ["PATCOM_ArtilleryBattery", false]});

if (count _batteryArray == 0) exitWith {
    If (PATCOM_DEBUG) then {
        [leader _callerGroup, "NO SUPPORT AVAILABLE", 5, "Red"] call A3A_fnc_debugText3D;
    };
};

private _selectedBattery = selectRandom _batteryArray;
private _group = group (gunner _selectedBattery);
private _batteryClass = (typeOf _selectedBattery);
private _dayState = [] call A3A_fnc_getDayState;
private _reloadTime = [_selectedBattery] call A3A_fnc_getReloadTime;
private _shellType = "";

// Set Artillery to busy
_group setVariable ["PATCOM_ArtilleryBusy", true, true];

/////// CHECK IF UNITS ARE IN DANGER CLOSE PROXIMITY \\\\\\\
if ([_targetPos, _area, _side] call A3A_fnc_artilleryDangerClose) then {
    If (PATCOM_DEBUG) then {
        [leader _group, "DANGER CLOSE", 5, "Yellow"] call A3A_fnc_debugText3D;
    };

    if (_dayState == "EVENING" || {_dayState == "NIGHT"}) then {
        _roundType = "FLARE"; // Need to add flare into templates.
    } else {
        _roundType = "SMOKE";
    };
};

/////// GET ARTILLERY ROUND TYPE FROM TEMPLATES \\\\\\\
private _faction = Faction(_side);
if (_batteryClass in (_faction get "vehiclesArtillery")) then {
    private _shellArray = _faction get "magazines" get _batteryClass;
    _shellType = (_shellArray # 0);
};
if (_batteryClass in (_faction get "staticMortars")) then {
    switch (_roundType) do {
        case "HE": {
            _shellType = _faction get "mortarMagazineHE";
        };

        case "SMOKE": {
            _shellType = _faction get "mortarMagazineSmoke";
        };
        
        case "FLARE": {
            _shellType = _faction get "mortarMagazineFlare";
        };

        default {
            _shellType = _faction get "mortarMagazineHE";
        };
    };
};

if (_shellType == "") exitWith {
    ServerDebug_1("Unable to find ammoType for Classname - %1", _batteryClass);
};

/////// FINAL ARTILLERY RANGE CHECK \\\\\\\
if !(_targetPos inRangeOfArtillery [[_selectedBattery], _shellType]) exitWith {
    If (PATCOM_DEBUG) then {
        [leader _group, "OUT OF RANGE", 5, "Red"] call A3A_fnc_debugText3D;
    };
    _group setVariable ["PATCOM_ArtilleryBusy", false, true];
};

/////// DO ARTILLERY FIRE \\\\\\\
[_group, _targetPos, _area, _selectedBattery, _shellType, _rounds, _reloadTime] spawn {
    params ["_group", "_targetPos", "_area", "_selectedBattery", "_shellType", "_rounds", "_reloadTime"];

    for "_i" from 1 to _rounds do {
        private _finalTargetPos = [_targetPos, (random 50), _area, 0, 1, -1, 0] call A3A_fnc_getSafePos;
        _selectedBattery doArtilleryFire [_finalTargetPos, _shellType, 1];
        If (PATCOM_DEBUG) then {
            [leader _group, "ROUND AWAY", 1, "Green"] call A3A_fnc_debugText3D;
        };
        sleep (_reloadTime + (2 + (random 4)));
    };

    sleep PATCOM_ARTILLERY_DELAY;
    _group setVariable ["PATCOM_ArtilleryBusy", false, true];
};