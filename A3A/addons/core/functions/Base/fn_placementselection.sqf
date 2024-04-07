#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
scriptName "fn_placementSelection.sqf";
private _disabledPlayerDamage = false;

player allowDamage false;
format [localize "STR_hints_new_game_petros_dead_header",name petros] hintC format [localize "STR_hints_new_game_petros_dead_text",name petros];

hintC_arr_EH = findDisplay 72 displayAddEventHandler ["unload",{
	_nul = _this spawn {
		_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
		hintSilent "";
	};
}];

private _markersX = markersX select {sidesX getVariable [_x,sideUnknown] != teamPlayer};
_markersX = _markersX - (controlsX select {!isOnRoad (getMarkerPos _x)});
openMap [true,true];

private _mrkDangerZone = [];
{
	_mrk = createMarkerLocal [format ["%1dumdum", count _mrkDangerZone], getMarkerPos _x];
	_mrk setMarkerShapeLocal "ELLIPSE";
	_mrk setMarkerSizeLocal [500,500];
	_mrk setMarkerTypeLocal "hd_warning";
	_mrk setMarkerColorLocal "ColorRed";
	_mrk setMarkerBrushLocal "DiagGrid";
	_mrkDangerZone pushBack _mrk;
} forEach _markersX;

private _positionClicked = [];
private _positionIsInvalid = true;

while {_positionIsInvalid} do {
	positionClickedDuringHQPlacement = [];
	onMapSingleClick "positionClickedDuringHQPlacement = _pos;";
	waitUntil {sleep 1; (count positionClickedDuringHQPlacement > 0) or (not visiblemap)};
	onMapSingleClick "";

	//If they quit the map, keep HQ where it is.
	if (not visiblemap) exitWith {};

	//Assume the position chosen is valid.
	_positionIsInvalid = false;

	_positionClicked = positionClickedDuringHQPlacement;
	_markerX = [_markersX,_positionClicked] call BIS_fnc_nearestPosition;

	if (getMarkerPos _markerX distance _positionClicked < 500) then {
		[localize "STR_A3A_Base_placementselection_header", localize "STR_A3A_Base_placementselection_too_close_enemy_zones"] call SCRT_fnc_misc_deniedHint;
		_positionIsInvalid = true;
	};

	if (!_positionIsInvalid && {surfaceIsWater _positionClicked}) then {
		[localize "STR_A3A_Base_placementselection_header", localize "STR_A3A_Base_placementselection_not_water"] call SCRT_fnc_misc_deniedHint;
		_positionIsInvalid = true;
	};

	if (!_positionIsInvalid && (_positionClicked findIf { (_x < 0) || (_x > worldSize)} != -1)) then {
		[localize "STR_A3A_Base_placementselection_header", localize "STR_A3A_Base_placementselection_oob"] call SCRT_fnc_misc_deniedHint;
		_positionIsInvalid = true;
	};

	if (!_positionIsInvalid) then {
		//Invalid if enemies nearby
		_positionIsInvalid = (allUnits findIf {(side _x == Occupants || side _x == Invaders) && {_x distance _positionClicked < 500}}) > -1;
		if (_positionIsInvalid) then {[localize "STR_A3A_Base_placementselection_header", localize "STR_A3A_Base_placementselection_enemies"] call SCRT_fnc_misc_deniedHint;};
	};
	sleep 0.1;
};

player allowDamage true;

{deleteMarkerLocal _x} forEach _mrkDangerZone;

//If we're still in the map, we chose a place.
if (visiblemap) then {
	_controlsX = controlsX select {!(isOnRoad (getMarkerPos _x))};
	{
		if (getMarkerPos _x distance _positionClicked < distanceSPWN) then {
			sidesX setVariable [_x,teamPlayer,true];
		};
	} forEach _controlsX;
	[_positionClicked] remoteExec ["A3A_fnc_createPetros", 2];
	[_positionClicked, false] remoteExec ["A3A_fnc_relocateHQObjects", 2];
	openmap [false,false];

	// Make sure petros is actually placed before we signal that we're done placing
	sleep 5;
};

A3A_playerPlacingPetros = "";
publicVariableServer "A3A_playerPlacingPetros";
