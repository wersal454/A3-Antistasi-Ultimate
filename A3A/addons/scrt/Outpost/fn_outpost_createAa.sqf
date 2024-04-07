#include "..\defines.inc"
FIX_LINE_NUMBERS()

params ["_position", "_direction", "_moneyCost", "_hrCost", "_commanderNetworkId"];

if (!isServer) exitWith {};

[-_hrCost,-_moneyCost] remoteExec ["A3A_fnc_resourcesFIA",2];

estabNetworkId = clientOwner;
_commanderNetworkId publicVariableClient "estabNetworkId";

private _textX = format [localize "STR_marker_aa_empl", FactionGet(reb,"name")];

private _marker = createMarker [format ["FIAAApost%1", random 1000], _position];
_marker setMarkerShape "ICON";

(45 call SCRT_fnc_misc_getTimeLimit) params ["_dateLimitNum", "_displayTime"];

private _taskId = "outpostTask" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_aaempl_deploy_desc", _displayTime],localize "STR_aaempl_deploy_header",_marker],_position,false,0,true,"Move",true] call BIS_fnc_taskCreate;
[_taskId, "outpostTask", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

_formatX = A3A_faction_reb get "groupAaEmpl";

_groupX = [getMarkerPos respawnTeamPlayer, teamPlayer, _formatX] call A3A_fnc_spawnGroup;
_groupX setGroupId ["Post"];
_road = [getMarkerPos respawnTeamPlayer] call A3A_fnc_findNearestGoodRoad;
_pos = position _road findEmptyPosition [1,30,"B_G_Van_01_transport_F"];
_vehType = (A3A_faction_reb get "vehiclesLightUnarmed") select 0;
_truckX = _vehType createVehicle _pos;
_groupX addVehicle _truckX;
{
    [_x] call A3A_fnc_FIAinit
} forEach units _groupX;
leader _groupX setBehaviour "SAFE";
(units _groupX) orderGetIn true;
theBoss hcSetGroup [_groupX];

private _units = units _groupX;

waitUntil {
	sleep 1;
	(!isNil "cancelEstabTask" && {cancelEstabTask}) || 
	{_units findIf {[_x] call A3A_fnc_canFight} == -1 || 
	{{[_x] call A3A_fnc_canFight && {_x distance _position < 35}} count units _groupX > 0 ||
	{(dateToNumber date > _dateLimitNum)}}}
};

switch (true) do {
	case (!isNil "cancelEstabTask" && {cancelEstabTask}): {
		[_hrCost,_moneyCost] remoteExec ["A3A_fnc_resourcesFIA",2];
		[_taskId, "outpostTask", "CANCELED"] call A3A_fnc_taskSetState;
		sleep 3;
		deleteMarker _marker;
	};
	case (units _groupX findIf {[_x] call A3A_fnc_canFight && {_x distance _position < 35}} != -1): {
		if (isPlayer leader _groupX) then {
			_owner = (leader _groupX) getVariable ["owner",leader _groupX];
			(leader _groupX) remoteExec ["removeAllActions",leader _groupX];
			_owner remoteExec ["selectPlayer",leader _groupX];
			// (leader _groupX) setVariable ["owner",_owner,true];
			// {[_x] joinsilent group _owner} forEach units group _owner;
			// [group _owner, _owner] remoteExec ["selectLeader", _owner];
			"" remoteExec ["hint",_owner];
			waitUntil {!(isPlayer leader _groupX)};
			sleep 5;
		};
		aapostsFIA pushBack _marker;
		publicVariable "aapostsFIA";
		sidesX setVariable [_marker,teamPlayer,true];
		markersX pushBack _marker;
		publicVariable "markersX";
		spawner setVariable [_marker,2,true];
		_nul = [-5,5,_position] remoteExec ["A3A_fnc_citySupportChange",2];
		_marker setMarkerType "n_antiair";
		_marker setMarkerColor colorTeamPlayer;
		_marker setMarkerText _textX;
		_garrison = A3A_faction_reb get "groupAaEmpl";
		garrison setVariable [_marker,_garrison,true];
		staticPositions setVariable [_marker, [_position, _direction], true];
		[_taskId, "outpostTask", "SUCCEEDED"] call A3A_fnc_taskSetState;
		["RebelControlCreated", [_marker, "aaemplacement"]] call EFUNC(Events,triggerEvent);
	};
	default {
		[_taskId, "outpostTask", "FAILED"] call A3A_fnc_taskSetState;
		sleep 3;
		deleteMarker _marker;
	};
};

[_taskId, "outpostTask", 0] spawn A3A_fnc_taskDelete;
cancelEstabTask = nil;
estabNetworkId = nil;
_commanderNetworkId publicVariableClient "estabNetworkId";

theBoss hcRemoveGroup _groupX;
{
    deleteVehicle _x
} forEach units _groupX;
deleteVehicle _truckX;
deleteGroup _groupX;
