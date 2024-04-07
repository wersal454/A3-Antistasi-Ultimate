
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Info("InitGarrisons started");

// This function is now only called for a new game

_fnc_initGarrison =
{
    params ["_marker", "_occGroups", "_invGroups"];
    private _garrNum = [_marker] call A3A_fnc_garrisonSize;
    private _side = sidesX getVariable _marker;
    private _groupsRandom = [_occGroups, _invGroups] select (_side == Invaders);

    private _garrison = [];
    while {count _garrison < _garrNum} do {
        _garrison append (selectRandom _groupsRandom);
    };
    _garrison resize _garrNum;
    garrison setVariable [_marker, _garrison, true];
};

private _updateMarkers = outposts + airportsX + milbases;			// To sort out the faction names & flags
if (gameMode >= 3) then
{
    // Set everything to government control if we have no invaders
    {
        if (sidesX getVariable _x == Occupants) then { continue };
        sidesX setVariable [_x, Occupants, true];
        _updateMarkers pushBackUnique _x;
    } forEach (markersX - ["Synd_HQ"]);
};
{ _x call A3A_fnc_mrkUpdate } forEach _updateMarkers;


private _occGroups = ((A3A_faction_occ get "groupsTierSquads") apply {_x select 1}) + ((A3A_faction_occ get "groupsTierMedium") apply {_x select 1});
private _invGroups = ((A3A_faction_inv get "groupsTierSquads") apply {_x select 1}) + ((A3A_faction_inv get "groupsTierMedium") apply {_x select 1});
{ [_x, _occGroups, _invGroups] call _fnc_initGarrison } forEach airportsX + milbases + (outposts select {sidesX getVariable [_x, sideUnknown] == Invaders});

private _milGroups = (A3A_faction_occ get "groupsMilitiaSquads") + (A3A_faction_occ get "groupsMilitiaMedium");
{ [_x, _milGroups, _invGroups] call _fnc_initGarrison } forEach resourcesX + factories + seaports + (outposts select {sidesX getVariable [_x, sideUnknown] == Occupants});

Info("InitGarrisons completed");
