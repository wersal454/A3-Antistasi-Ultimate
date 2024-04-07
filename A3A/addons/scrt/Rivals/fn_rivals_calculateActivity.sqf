/*
Maintainer: Socrates, based on Wurzel0701's aggro code
    Calculates the current rival activity values and levels.

Arguments:
    <BOOL> The amount of activity to add

Return Value:
    <NIL>

Scope: Server
Environment: Any
Public: Yes
Dependencies:
    <ARRAY> inactivityStackRivals

Example:
[] call SCRT_fnc_rivals_calculateActivity;
*/
#include "..\defines.inc"
FIX_LINE_NUMBERS()

params [["_silent", false]];

if (!areRivalsEnabled) exitWith {};
if (!areRivalsDiscovered) exitWith {};
if (areRivalsDefeated) exitWith {};

//Calculate the new values from the stacks
private _newValue = 0;
{
    _newValue = _newValue + (_x select 0);
} forEach inactivityStackRivals;

//Limit them to 0 - 100
_newValue = round ((_newValue min 100) max 0);

private _levelBounds = [((inactivityLevelRivals - 1) * 20) - 2.5, inactivityLevelRivals * 20 + 2.5];

private _notificationText = "";
private _levelsChanged = false;


if (_newValue < (_levelBounds select 0)) then {
    inactivityLevelRivals = ((ceil (_newValue / 20)) min 5) max 1;
    publicVariable "inactivityLevelRivals";
    _notificationText = format [localize  "STR_comms_riv_activity_increased", A3A_faction_riv get "name", [inactivityLevelRivals] call SCRT_fnc_rivals_getActivityLevelString];
    _levelsChanged = true;
} else {
    if(_newValue > (_levelBounds select 1)) then {
        inactivityLevelRivals = ((ceil (_newValue / 20)) min 5) max 1;
        publicVariable "inactivityLevelRivals";
        _notificationText = format [localize "STR_comms_riv_activity_reduced", A3A_faction_riv get "name", [inactivityLevelRivals] call SCRT_fnc_rivals_getActivityLevelString];
        _levelsChanged = true;
    };
};

if(_levelsChanged) then {
    //Updating HUDs of players
    [] remoteExec ["A3A_fnc_statistics", [teamPlayer, civilian]];
    if(!_silent) then {
        //If not load progress, show message for everyone
        _notificationText = format [localize "STR_comms_riv_activity_change", _notificationText];
        [petros, "income", _notificationText] remoteExec ["A3A_fnc_commsMP", [teamPlayer, civilian]];
    };
};
