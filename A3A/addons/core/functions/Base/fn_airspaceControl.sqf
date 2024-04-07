#define CIV_HELI        0
#define MIL_HELI        1
#define JET             2

params ["_vehicle"];
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
/*  Handles the airspace control of any player aircraft, breaking undercover and calling support

    Execution on: Any

    Scope: Internal

    Params:
        _vehicle: OBJECT : The vehicles that should be checked against enemy positions

    Returns:
        Nothing
*/

//If vehicle already has an airspace control script, exit here
if(_vehicle getVariable ["airspaceControl", false]) exitWith {};

_vehicle setVariable ["airspaceControl", true, true];

//Select the kind of aircraft
private _airType = -1;
if(_vehicle isKindOf "Helicopter") then
{
    if((typeOf _vehicle) in (FactionGet(reb,"vehiclesCivHeli"))) then
    {
        _airType = CIV_HELI;
    }
    else
    {
        _airType = MIL_HELI;
    };
}
else
{
    _airType = JET;
};

//Select height and range for outposts, numbers are values for [CIV_HELI, MIL_HELI, JET]
private _outpostDetectionRange = [300, 500, 750] select _airType;
private _outpostDetectionHeight = [150, 250, 500] select _airType;

//Select height and range for milbases, numbers are values for [CIV_HELI, MIL_HELI, JET]
private _milbaseDetectionRange = [450, 600, 1000] select _airType;
private _milbaseDetectionHeight = [350, 350, 1500] select _airType;

//Select height and range for outposts, numbers are values for [CIV_HELI, MIL_HELI, JET]
private _airportDetectionRange = [500, 750, 1500] select _airType;
private _airportDetectionHeight = [500, 500, 2500] select _airType;

//Selecting height and distance warning for outposts
private _outpostWarningRange = 500;
private _outpostWarningHeight = 250;

//Selecting height and distance warning for milbases
private _milbaseWarningRange = 600;
private _milbaseWarningHeight = 350;

//Selecting height and distance warning for airports
private _airportWarningRange = 750;
private _airportWarningHeight = 750;

//Initialize needed variables
private _inWarningRangeOutpost = [];
private _inDetectionRangeOutpost = [];
private _inWarningRangeMilbase = [];
private _inDetectionRangeMilbase = [];
private _inWarningRangeAirport = [];
private _inDetectionRangeAirport = [];
private _vehicleIsUndercover = false;
private _supportCallAt = -1;
private _vehPos = [];

private _fn_sendSupport =
{
    params ["_vehicle", "_marker"];

    private _markerSide = sidesX getVariable [_marker, sideUnknown];
    //Reveal vehicle to all groups of the side so they can take actions
    {
        if(side _x == _markerSide) then
        {
            _x reveal [_vehicle, 4];            // TODO: doesn't actually work, needs remoteExec
        };
    } forEach allGroups;

    //Take actions against the aircraft
    // Let support system decide whether it's worth reacting to
    private _revealValue = [getMarkerPos _marker, _markerSide] call A3A_fnc_calculateSupportCallReveal;
    [_markerSide, _vehicle, markerPos _marker, 4, _revealValue] remoteExec ["A3A_fnc_requestSupport", 2];

/*
    switch (_airType) do
    {
        case (MIL_HELI):
        {
            Debug_3("Rebel military helicopter %1 detected by %2 (side %3), sending support now!", _vehicle, _marker, _markerSide);
            [_vehicle, _markerSide, markerPos _marker, 4, _revealValue] remoteExec ["A3A_fnc_requestSupport", 2];
        };
        case (JET):
        {
            Debug_3("Rebel jet %1 detected by %2 (side %3), sending support now!", _vehicle, _marker, _markerSide);
            [_vehicle, 4, ["ASF", "SAM"], _markerSide, _revealValue] remoteExec ["A3A_fnc_sendSupport", 2];
        };
        default
        {
            Debug_3("Rebel civil helicopter %1 detected by %2 (side %3), revealed for all groups!", _vehicle, _marker, _markerSide);
        };
    };
*/
};

private _fn_checkNoFlyZone =
{
    params ["_vehicle", "_vehPos", "_markerPos", "_detectionRange", "_detectionHeight"];

    private _heightDiff = (_vehPos select 2) - (_markerPos select 2);
    if(_heightDiff < _detectionHeight && {_markerPos distance2D _vehPos < _detectionRange}) exitWith
    {
        //Too close to marker, break undercover
        _vehicle setVariable ["NoFlyZoneDetected", _x, true];
        _vehicleIsUndercover = false;
        true;
    };
    false;
};


private _fn_getMarkersInRange =
{
    params ["_markers", "_vehPos", "_range", "_height"];

    private _inRange = _markers select
    {
        private _markerPos = AGLToASL (getMarkerPos _x);
        private _heightDiff = (_vehPos select 2) - (_markerPos select 2);
        _heightDiff < _height &&
        {_markerPos distance2D _vehPos < _range}
    };

    _inRange;
};


//While not in garage and alive and crewed we check what the aircraft is doing
while {!(isNull _vehicle) && {alive _vehicle && {count (crew _vehicle) != 0}}} do
{
    //Check undercover status
    _vehicleIsUndercover = captive ((crew _vehicle) select 0);
    _vehPos = getPosASL _vehicle;

    //Get all enemy airports and outposts to not search that much options
    private _enemyAirports = airportsX select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
    private _enemyOutposts = (outposts + seaports) select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
    private _enemyMilbases = milbases select {sidesX getVariable [_x, sideUnknown] != teamPlayer};

    //Check vehicles undercover status
    if(_vehicleIsUndercover && {_vehicle getVariable ["NoFlyZoneDetected", ""] == ""}) then
    {
        //Warnings will be issued before undercover is broken

        //Checking for nearby airports
        private _airportsInWarningRange = [_enemyAirports, _vehPos, _airportWarningRange, _airportWarningHeight] call _fn_getMarkersInRange;

        //NewAirport will contain all airports of which the warning zone has just been entered
        private _newAirports = _airportsInWarningRange - _inWarningRangeAirport;
        _inWarningRangeAirport = _airportsInWarningRange;

        //Check for nearby outposts
        private _outpostsInWarningRange = [_enemyOutposts, _vehPos, _outpostWarningRange, _outpostWarningHeight] call _fn_getMarkersInRange;

        //NewOutposts will contain all outposts of which the warning zone has just been entered
        private _newOutposts = _outpostsInWarningRange - _inWarningRangeOutpost;
        _inWarningRangeOutpost = _outpostsInWarningRange;

        //Check for nearby milbases
        private _milbasesInWarningRange = [_enemyMilbases, _vehPos, _milbaseWarningRange, _milbaseWarningHeight] call _fn_getMarkersInRange;

        //NewMilbases will contain all milbases of which the warning zone has just been entered
        private _newMilbases = _milbasesInWarningRange - _inWarningRangeMilbase;
        _inWarningRangeMilbase = _milbasesInWarningRange;

        {
            //Assuming you only get a single one each second, need to split it otherwise
            private _warningText = format [localize "STR_A3A_base_airspace_control_warning", [_x] call A3A_fnc_localizar];
            [localize "STR_info_bar_undercover_break_title", _warningText] remoteExec ["A3A_fnc_customHint", (crew _vehicle)];
        } forEach (_newAirports + _newOutposts + _newMilbases);

        //Check if the aircraft got to close to any airport in which warning zone it already is
        {
            if([_vehicle, _vehPos, AGLToASL (getMarkerPos _x), _airportDetectionRange, _airportDetectionHeight] call _fn_checkNoFlyZone) exitWith
            {
                _vehicleIsUndercover = false;
            };
        } forEach _inWarningRangeAirport;

        //Check if the aircraft got to close to any outpost in which warning zone it already is
        if(_vehicleIsUndercover) then
        {
            {
                if([_vehicle, _vehPos, AGLToASL (getMarkerPos _x), _outpostDetectionRange, _outpostDetectionHeight] call _fn_checkNoFlyZone) exitWith
                {
                    _vehicleIsUndercover = false;
                };
            } forEach _inWarningRangeOutpost;
        };

        //Check if the aircraft got to close to any milbase in which warning zone it already is
        if(_vehicleIsUndercover) then
        {
            {
                if([_vehicle, _vehPos, AGLToASL (getMarkerPos _x), _milbaseDetectionRange, _milbaseDetectionHeight] call _fn_checkNoFlyZone) exitWith
                {
                    _vehicleIsUndercover = false;
                };
            } forEach _inWarningRangeMilbase;
        };
    }
    else
    {
        //Vehicles will be attacked instantly once detected

        //Check for nearby airports
        private _airportsInRange = [_enemyAirports, _vehPos, _airportDetectionRange, _airportDetectionHeight] call _fn_getMarkersInRange;
        private _milbasesInRange = [_enemyMilbases, _vehPos, _milbaseDetectionRange, _milbaseDetectionHeight] call _fn_getMarkersInRange;

        //newAirports will contain all airports which just detected the aircraft
        private _newAirports = _airportsInRange - _inDetectionRangeAirport;
        _inDetectionRangeAirport = _airportsInRange;

        private _newMilbases = _milbasesInRange - _inDetectionRangeMilbase;
        _inDetectionRangeMilbase = _milbasesInRange;

        switch (true) do {
            case (count _newAirports > 0): {
                //Vehicle detected by another airport (or multiple, lucky in that case)
                [_vehicle, _newAirports select 0] call _fn_sendSupport;
                _supportCallAt = time + 300;
            };
            case (count _newAirports > 0): {
                //Vehicle detected by another milbase (or multiple, lucky in that case)
                [_vehicle, _newMilbases select 0] call _fn_sendSupport;
                _supportCallAt = time + 450;
            };
            default {
                //No airport near, to save performance we only check outpost if they would be able to send support
                if(time > _supportCallAt) then
                {
                    //Check for nearby outposts
                    private _outpostsInRange = [_enemyOutposts, _vehPos, _outpostDetectionRange, _outpostDetectionHeight] call _fn_getMarkersInRange;

                    //Same as above
                    private _newOutposts = _outpostsInRange - _inDetectionRangeOutpost;
                    _inDetectionRangeOutpost = _outpostsInRange;

                    if(count _newOutposts > 0) then
                    {
                        //Vehicle detected by another outpost, call support if possible
                        [_vehicle, _newOutposts select 0] call _fn_sendSupport;
                        _supportCallAt = time + 300;
                    };
                };
            };
        };
    };
    sleep 1;
};

_vehicle setVariable ["airspaceControl", nil, true];
