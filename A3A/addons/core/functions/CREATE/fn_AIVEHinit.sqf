/*
	Installs various damage/smoke/kill/capture logic for vehicles
	Will set and modify the "originalSide" and "ownerSide" variables on the vehicle indicating side ownership
	If a rebel enters a vehicle, it will be switched to rebel side and added to vehDespawner

	Params:
	1. Object: Vehicle object
	2. Side: Side ownership for vehicle
	3. String: (Optional) Resource pool for vehicle
*/
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_veh", "_side", "_resPool", ["_excludeTrails", false]];

if (isNil "_veh") exitWith {};

// Not a crewed vehicle, nothing to do here
if (fullCrew [_veh, "", true] isEqualTo []) exitWith {
	// buyable item, use initObject. Happens on game loading at the moment
	if (typeof _veh in A3A_utilityItemHM) then { _veh call A3A_fnc_initObject };
};

if !(isNil { _veh getVariable "ownerSide" }) exitWith {
	// vehicle already initialized, just swap side and exit
	[_veh, _side, true] call A3A_fnc_vehKilledOrCaptured;
};

_veh setVariable ["originalSide", _side, true];
_veh setVariable ["ownerSide", _side, true];

if (isNil "_resPool") then { _resPool = "legacy" };
_veh setVariable ["A3A_resPool", _resPool, true];

// this might need moving into a different function later
if (_side == teamPlayer) then {
	clearMagazineCargoGlobal _veh;			// might need an exception on this for vehicle weapon mags?
	clearWeaponCargoGlobal _veh;
	clearItemCargoGlobal _veh;
	clearBackpackCargoGlobal _veh;
} else {
	clearWeaponCargoGlobal _veh;
};

// Sync the vehicle textures if necessary
_veh call A3A_fnc_vehicleTextureSync;

private _typeX = typeOf _veh;
if (_veh isKindOf "Car" or{ _veh isKindOf "Tank"}) then {
	// isn't this section basically supposed to be all ground vehicles?
	if (_side == teamPlayer or _side == civilian) exitWith {};				// arguable

	if (_typeX in FactionGet(all,"vehiclesArmor")) then { _veh call A3A_fnc_addActionBreachVehicle };

	switch (true) do {
		case (_veh isKindOf "Car"): {
			_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != teamPlayer)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
			if ({"SmokeLauncher" in (_veh weaponsTurret _x)} count (allTurrets _veh) > 0) then {
				_veh setVariable ["within",true];
				_veh addEventHandler ["GetOut", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}];
				_veh addEventHandler ["GetIn", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
			};
		};

		case (_typeX in FactionGet(all,"vehiclesAPCs") + FactionGet(all,"vehiclesIFVs") + FactionGet(all,"vehiclesLightAPCs")): {
			_veh addEventHandler ["HandleDamage",{private _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto; _veh removeEventHandler ["HandleDamage",_thisEventHandler]};if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_veh))) then {0;} else {(_this select 2);}}];
			_veh setVariable ["within",true];
			_veh addEventHandler ["GetOut", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false];[_veh] call A3A_fnc_smokeCoverAuto}}}];
			_veh addEventHandler ["GetIn", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
		};

		default {
			// tanks and AA
			_veh addEventHandler ["HandleDamage",{private _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto; _veh removeEventHandler ["HandleDamage",_thisEventHandler]}; _this select 2}];
		};
	};
} else {
	switch (true) do {
		case (_typeX in (FactionGet(all,"vehiclesFixedWing") + FactionGet(all,"vehiclesHelis"))): {
			_veh addEventHandler ["GetIn", {
				if (_this select 1 != "driver") exitWith {};
				_unit = _this select 2;
				if (!isPlayer _unit and {_unit getVariable ["spawner",false] and {side group _unit == teamPlayer}}) then {
					moveOut _unit;
					[localize "STR_A3A_Create_AIVEHINIT_header", localize "STR_A3A_Create_AIVEHINIT_only_humans"] call A3A_fnc_customHint;
				};
			}];

			if (_veh isKindOf "Helicopter" && {_typeX in FactionGet(all,"vehiclesTransportAir")}) then {
				_veh setVariable ["within",true];
				_veh addEventHandler ["GetOut", {private _veh = _this select 0; if ((isTouchingGround _veh) and (isEngineOn _veh)) then {if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}}];
				_veh addEventHandler ["GetIn", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
			};
		};

		case (_veh isKindOf "StaticWeapon"): {
			_veh setCenterOfMass [(getCenterOfMass _veh) vectorAdd [0, 0, -1], 0];

			if !(_typeX isKindOf "StaticMortar") then {
				[_veh, "static"] remoteExec ["A3A_fnc_flagAction", [teamPlayer,civilian], _veh];
				if (_side == teamPlayer && !isNil {serverInitDone}) then { [_veh] remoteExec ["A3A_fnc_updateRebelStatics", 2] };
			};
		};
	};
};

if (_side == civilian) then {
	_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_this select 0))) then {0;} else {(_this select 2);};}];
	
	if ((_veh isKindOf "Air")) exitWith {};

	_veh addEventHandler ["HandleDamage", {
		private _veh = _this select 0;
		if (side(_this select 3) == teamPlayer) then {
			_driverX = driver _veh;
			if (side group _driverX == civilian) then {_driverX leaveVehicle _veh};
			_veh removeEventHandler ["HandleDamage", _thisEventHandler];
		};
	}];
};

// Handler for enemy responses to vehicle damage
if (_side == Invaders || _side == Occupants) then {
	_veh addEventHandler ["HandleDamage", {
		params ["_veh", "_part", "_damage", "_source"];
		if (_damage < 0.5) exitWith { nil };			// rough as hell, but whatever
		if (isNil "_source" or {isNull _source or side _source == side _veh}) exitWith { nil };

		_veh removeEventHandler ["HandleDamage", _thisEventHandler];
		if (_veh getVariable "ownerSide" != _veh getVariable "originalSide") exitWith { nil };

		// Add 1/3 cost to recent casualties list on server
		private _vehCost = A3A_vehicleResourceCosts getOrDefault [typeof _veh, 0];
		[_veh getVariable "ownerSide", getPos _veh, _vehCost/3] remoteExec ["A3A_fnc_addRecentDamage", 2];

		// Attempt to call for support if there's a crew. Assume local, should be true
		if !(isNull group _veh) then { [group _veh, _source] spawn A3A_fnc_callForSupport };
		nil;
	}];

	if (_veh isKindOf "Helicopter") then {
		// Event handler to (usually) get the crew out after crippling damage
		// Doesn't cover dead pilot / live co-pilot case, should eventually be handled by AI routines
		_veh addEventHandler ["Dammaged", {
			params ["_veh"];
			if (canMove _veh) exitWith {};
			Debug("Downed heli handler triggered");
			group _veh leaveVehicle _veh;
			_veh removeEventHandler ["Dammaged", _thisEventHandler];
		}];
	};

    _veh addEventHandler ["IncomingMissile", {
		params ["_veh", "_ammo", "_source", "_instigator"];
		private _group = group _veh;
		if (isNull _group or { side _group == teamPlayer }) exitWith { _veh removeEventHandler ["IncomingMissile", _thisEventHandler] };
		private _isRival = (units _group) findIf {_unit getVariable ["isRival", false]} != -1;
		if (_isRival) exitWith { _veh removeEventHandler ["IncomingMissile", _thisEventHandler] };

		//it would be really annoying if on each missile launch support will be called
		if (random 10 < tierWar + aggressionOccupants/10) then {
			[_group, _source] spawn A3A_fnc_callForSupport;
		}; 
    }];
};

//check if vehicle is artillery
if(isNumber (configFile >> "CfgVehicles" >> _typeX >> "artilleryScanner") && {(getNumber (configFile >> "CfgVehicles" >> _typeX >> "artilleryScanner") isEqualTo 1)}) then {
	_veh addEventHandler ["Fired", SCRT_fnc_common_triggerArtilleryResponseEH];
	if (!_excludeTrails) then {
		[_veh] call A3A_fnc_addArtilleryTrailEH;
	};
	// Redundant with support system?
	//[_veh] remoteExec ["A3A_fnc_addArtilleryDetectionEH", 2];
};

// EH behaviour:
// GetIn/GetOut/Dammaged: Runs where installed, regardless of locality
// Local: Runs where installed if target was local before or after the transition
// HandleDamage/Killed: Runs where installed, only if target is local
// MPKilled: Runs everywhere, regardless of target locality or install location
// Destruction is handled in an EntityKilled mission event handler, in case of locality changes

if (_side != teamPlayer) then
{
	// Vehicle stealing handler
	// When a rebel first enters a vehicle, fire capture function
	_veh addEventHandler ["GetIn", {

		params ["_veh", "_role", "_unit"];
		if (side group _unit != teamPlayer) exitWith {};		// only rebels can flip vehicles atm
		private _oldside = _veh getVariable ["ownerSide", teamPlayer];
		if (_oldside != teamPlayer) then
		{
			ServerDebug_2("%1 switching side from %2 to rebels", typeof _veh, _oldside);
			[_veh, teamPlayer, true] call A3A_fnc_vehKilledOrCaptured;
		};
		_veh removeEventHandler ["GetIn", _thisEventHandler];
	}];
};

if(_veh isKindOf "Air") then
{
    //Start airspace control script if rebel player enters
    _veh addEventHandler ["GetIn", {
		params ["_veh", "_role", "_unit"];
		if((side (group _unit) == teamPlayer) && {isPlayer _unit}) then
		{
			// TODO: check this isn't spammed
			[_veh] spawn A3A_fnc_airspaceControl;
		};
    }];
};

if(([_veh] call A3A_Logistics_fnc_getVehCapacity) > 1) then {
	_veh addEventHandler ["Killed", {
		params ["_vehicle", "_killer", "_instigator", "_useEffects"];

		private _cargo = _vehicle call A3A_Logistics_fnc_getCargo;
		if (_cargo isEqualTo []) exitWith {};

		_cargo = _cargo select {typeOf _x isEqualTo FactionGet(reb, "lootCrate")};

		{
			_cargoItem setDamage 1; 
			[_x] spawn {
				params["_cargoItem"];
				sleep 4;
				deleteVehicle _cargoItem;
			};
		} forEach _cargo;
	}];
};

// Handler for refunding vehicles after cleanup
if (A3A_vehicleResourceCosts getOrDefault [typeof _veh, 0] > 0) then {
	_veh addEventHandler ["Deleted", A3A_fnc_vehicleDeletedEH];
};


//add logistics loading to loadable objects
if([typeOf _veh] call A3A_Logistics_fnc_isLoadable) then {[_veh] call A3A_Logistics_fnc_addLoadAction;};

// deletes vehicle if it exploded on spawn...
[_veh] spawn A3A_fnc_cleanserVeh;

//initializes animiation sources and camo variants
if (_side != teamPlayer) then {
	[_veh, _side] call SCRT_fnc_misc_tryInitVehicle;
};

if (!isNull _veh) then {
    ["AIVehInit", [_veh, _side]] call EFUNC(Events,triggerEvent);
};
