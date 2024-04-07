#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_thingX", "_playerX", "_id"];


private _isStatic = (_thingX isKindOf "StaticWeapon");

if (!_isStatic && {player != theBoss}) exitWith {
	[localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_only_comm"] call SCRT_fnc_misc_deniedHint;
};
if (!(isNull attachedTo _thingX)) exitWith {
	[localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_already_moved"] call SCRT_fnc_misc_deniedHint;
};
if (vehicle _playerX != _playerX) exitWith {
	[localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_veh"] call SCRT_fnc_misc_deniedHint;
};
if (([_playerX] call A3A_fnc_countAttachedObjects) > 0) exitWith {
	[localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_already_attached"] call SCRT_fnc_misc_deniedHint;
};

private _sites = markersX select {sidesX getVariable [_x,sideUnknown] == teamPlayer};
private _markerX = [_sites,_playerX] call BIS_fnc_nearestPosition;
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _positionX = getMarkerPos _markerX;

if (_playerX distance2D _positionX > (_size + 5)) exitWith {
	[localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_closer_center"] call A3A_fnc_customHint;
};

if (captive _playerX) then { _playerX setCaptive false };

_thingX setVariable ["objectBeingMoved", true];
if !(_isStatic) then { _thingX removeAction _id };
if (_isStatic) then { _thingX lock true };

if (isNil {_thingX getVariable "A3A_originalMass"}) then { _thingX setVariable ["A3A_originalMass", getMass _thingX] };
[_thingX, 1e-12] remoteExecCall ["setMass", 0]; 

private _spacing = 2 max (1 - (boundingBoxReal _thingX select 0 select 1));
private _height = 0.1 - (boundingBoxReal _thingX select 0 select 2);
_thingX attachTo [_playerX, [0, _spacing, _height]];

private _fnc_placeObject = {
	params [["_thingX", objNull], ["_playerX", objNull], ["_dropObjectActionIndex", -1]];

	if (isNull _thingX) exitWith {Error("trying to place invalid HQ object")};
	if (isNull _playerX) exitWith {Error("trying to place HQ object with invalid player")};

	if (!(_thingX getVariable ["objectBeingMoved", false])) exitWith {};

	if (_playerX == attachedTo _thingX) then {
		_playerX setVelocity [0,0,0];
		_thingX setVelocity [0,0,0];
		detach _thingX;
	};

	if (_dropObjectActionIndex != -1) then {
		_playerX removeAction _dropObjectActionIndex;
	};

	// Can't find a case where this is ever true, but we'll make sure
	if (local _thingX) then {
		if (isNull group _thingX) then { [_thingX, 2] remoteExec ["setOwner", 2] }
		else { [group _thingX, 2] remoteExec ["setGroupOwner", 2] };
	};

	// Some objects never lose (and even regain) their velocity when detached, becoming lethal
	// On a DS, object locality changes when detached, so we have to remoteexec
	[_thingX, [0,0,0]] remoteExec ["setVelocity", _thingX];

	// Without this, non-unit objects often hang in mid-air
	[_thingX, surfaceNormal position _thingX] remoteExec ["setVectorUp", _thingX];

	// Place on closest surface
	private _pos = getPosASL _thingX;
	private _intersects = lineIntersectsSurfaces [_pos, _pos vectorAdd [0,0,-100], _thingX];
	if (count _intersects > 0) then {
		_thingX setPosASL (_intersects select 0 select 0);
	};

	if (_thingX isKindOf "StaticWeapon") then { _thingX lock false };

	_thingX setVariable ["objectBeingMoved", false];

	[_thingX, _thingX getVariable "A3A_originalMass"] remoteExecCall ["setMass", _thingX];
};

private _actionX = _playerX addAction [localize "STR_antistasi_actions_drop_here", {
	(_this select 3) params ["_thingX", "_fnc_placeObject"];

	[_thingX, player, (_this select 2)] call _fnc_placeObject;
}, [_thingX, _fnc_placeObject],6,true,true,"",""];

waitUntil {sleep 1;
	(_playerX != attachedTo _thingX)
	or (vehicle _playerX != _playerX)
	or (_playerX distance2D _positionX > (_size-3))
	or !([_playerX] call A3A_fnc_canFight)
	or (!isPlayer _playerX)
	or (_isStatic and {count crew _thingX > 0})
};

[_thingX, _playerX, _actionX] call _fnc_placeObject;

if !(_isStatic) then { _thingX addAction [localize "STR_antistasi_actions_move_this_asset", A3A_fnc_moveHQObject,nil,0,false,true,"","(_this == theBoss)"] };

if (vehicle _playerX != _playerX) exitWith {
	[localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_veh"] call SCRT_fnc_misc_deniedHint;
};

if  (_playerX distance2D _positionX > (_size - 3)) exitWith {
	[localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_far_center"] call SCRT_fnc_misc_deniedHint;
};
