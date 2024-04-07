#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_varname"];
A3A_saveTarget params ["_serverID", "_campaignID", "_map"];

// Simple version for new missionProfileNamespace saves
if (_serverID isEqualType false) exitWith {
	missionProfileNamespace getVariable format ["%1%2", _varName, _campaignID];
};

private _saveExt = format["%1%2Antistasi%3",_serverID,_campaignID,_map];

private _varValue = profileNamespace getVariable (_varname + _saveExt);
if (isNil "_varValue") exitWith {};


_varValue;
