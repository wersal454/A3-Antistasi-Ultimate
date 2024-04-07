/*  Sets up an ASF (air support fighter?) support

Environment: Server, scheduled, internal

Arguments:
    <STRING> The (unique) name of the support, mostly for logging
    <SIDE> The side from which the support should be sent (occupants or invaders)
    <STRING> Resource pool used for this support. Should be "attack" or "defence"
    <SCALAR> Maximum resources to spend. Not used here.
    <OBJECT> or <BOOL> Initial target for the ASF, or "false" for no initial target
    <POSITION> Esimated position of target, or center of patrol zone
    <SCALAR> Reveal value 0-1, higher values mean more information provided about support
    <SCALAR> Setup delay time in seconds, if negative will calculate based on war tier

Returns:
    <SCALAR> Resource cost of support call, or -1 for failure
*/

#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];

private _airport = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airport") exitWith { Debug_1("No airport found for %1 support", _supportName); -1; };

private _faction = Faction(_side);
private _vehType = selectRandom (_faction get "vehiclesPlanesAA");

private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (600 - 15*tierWar - 1*_aggro) };

private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "TARGET", _target, time + 1200, 1200, 200];
    _targArray = [_target, _targPos];
};

// name, side, suppType, center, radius, [target, targpos]
private _suppData = [_supportName, _side, "ASF", _targPos, 10000, _targArray];       // should radius be larger?
A3A_activeSupports pushBack _suppData;

[_suppData, _resPool, _airport, _vehType, _delay, _reveal] spawn A3A_fnc_SUP_ASFRoutine;

[_reveal, _side, "ASF", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;

// Vehicle cost + extra support cost for balance
(A3A_vehicleResourceCosts get _vehType) + 0;
