/*
Maintainer: Socrates
    Returns 

Arguments:

Return Value:
    <ARRAY> Known loca

Scope: Server
Environment: Any
Public: Yes
Dependencies:
    <HASHMAP> rivalsLocationsMap

Example:
[] call SCRT_fnc_rivals;
*/


private _unknownLocations = ["UNKNOWN"] call SCRT_fnc_rivals_getLocations;

private _location = [_unknownLocations, respawnTeamplayer] call BIS_fnc_nearestPosition;

if (isNil "_location") exitWith {};
if (_location isEqualTo [0,0,0]) exitWith {};

//revealing locations (key - location, value - knowledge)
rivalsLocationsMap set [_location, true];
publicVariable "rivalsLocationsMap";

private _name = [_location] call A3A_fnc_localizar;

private _revealText = [
	format [(localize "STR_antistasi_rivals_reveal_location_hideout_hint_text"), A3A_faction_riv get "name", _name],
	format [(localize "STR_antistasi_rivals_reveal_location_city_hint_text"), A3A_faction_riv get "name", _name]
] select (_location in citiesX);

[petros, "support", _revealText] remoteExec ["A3A_fnc_commsMP", [teamPlayer, civilian]];
