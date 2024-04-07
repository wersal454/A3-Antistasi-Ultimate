#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Info("loadServer Starting.");
if (isServer) then {
    Info("Starting Persistent Load.");
	petros allowdamage false;

	// Set all main markers to occupant control by default, overridden by mrkSDK & mrkCSAT
	{
		if (sidesX getVariable _x != Occupants) then { sidesX setVariable [_x, Occupants, true] };
	} forEach (airportsX + resourcesX + factories + outposts + seaports + milbases);

	A3A_saveVersion = 0;
	["version"] call A3A_fnc_getStatVariable;
	["mrkSDK"] call A3A_fnc_getStatVariable;
	["mrkCSAT"] call A3A_fnc_getStatVariable;
	["destroyedSites"] call A3A_fnc_getStatVariable;
	["minesX"] call A3A_fnc_getStatVariable;
	["antennas"] call A3A_fnc_getStatVariable;
	["hr"] call A3A_fnc_getStatVariable;
	["dateX"] call A3A_fnc_getStatVariable;
	["weather"] call A3A_fnc_getStatVariable;
	["prestigeOPFOR"] call A3A_fnc_getStatVariable;
	["prestigeBLUFOR"] call A3A_fnc_getStatVariable;
	["resourcesFIA"] call A3A_fnc_getStatVariable;
	["garrison"] call A3A_fnc_getStatVariable;
	["usesWurzelGarrison"] call A3A_fnc_getStatVariable;
	["skillFIA"] call A3A_fnc_getStatVariable;
	["membersX"] call A3A_fnc_getStatVariable;
    ["HR_Garage"] call A3A_fnc_getStatVariable;
    ["A3A_fuelAmountleftArray"] call A3A_fnc_getStatVariable;
	["destroyedBuildings"] call A3A_fnc_getStatVariable;
	["enemyResources"] call A3A_fnc_getStatVariable;
	["HQKnowledge"] call A3A_fnc_getStatVariable;

	["killZones"] call A3A_fnc_getStatVariable;
	["controlsSDK"] call A3A_fnc_getStatVariable;
	["bombRuns"] call A3A_fnc_getStatVariable;
	["jna_dataList"] call A3A_fnc_getStatVariable;

	//Antistasi Plus variables
	["watchpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "watchpostsFIA";
	["roadblocksFIA"] call A3A_fnc_getStatVariable; publicVariable "roadblocksFIA";
	["aapostsFIA"] call A3A_fnc_getStatVariable; publicVariable "aapostsFIA";
	["hmgpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "hmgpostsFIA";
	["atpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "atpostsFIA";
	["supportPoints"] call A3A_fnc_getStatVariable;
	["areOccupantsDefeated"] call A3A_fnc_getStatVariable;
	["areInvadersDefeated"] call A3A_fnc_getStatVariable;
	["isTraderQuestCompleted"] call A3A_fnc_getStatVariable;
	["traderPosition"] call A3A_fnc_getStatVariable;
	["traderDiscount"] call A3A_fnc_getStatVariable;
	["destroyedMilAdmins"] call A3A_fnc_getStatVariable;
	["rebelLoadouts"] call A3A_fnc_getStatVariable;
	["randomizeRebelLoadoutUniforms"] call A3A_fnc_getStatVariable;
	["areRivalsDiscovered"] call A3A_fnc_getStatVariable;
	["areRivalsDefeated"] call A3A_fnc_getStatVariable;
	["rivalsLocationsMap"] call A3A_fnc_getStatVariable;
	["rivalsExcludedLocations"] call A3A_fnc_getStatVariable;
	["nextRivalsLocationReveal"] call A3A_fnc_getStatVariable;
	["constructionsX"] call A3A_fnc_getStatVariable;
	["isRivalsDiscoveryQuestAssigned"] call A3A_fnc_getStatVariable;

	//===========================================================================

	//RESTORE THE STATE OF THE 'UNLOCKED' VARIABLES USING JNA_DATALIST
	{
		private _arsenalTabDataArray = _x;
		private _unlockedItemsInTab = _arsenalTabDataArray select { _x select 1 == -1 } apply { _x select 0 };
		{
			[_x, true] call A3A_fnc_unlockEquipment;
		} forEach _unlockedItemsInTab;
	} forEach jna_dataList;

	//Check if we have radios unlocked and update haveRadio.
	call A3A_fnc_checkRadiosUnlocked;

	//Sort optics list so that snipers pick the right sight
	// obsolete since rebelGear
	//unlockedOptics = [unlockedOptics,[],{getNumber (configfile >> "CfgWeapons" >> _x >> "ItemInfo" >> "mass")},"DESCEND"] call BIS_fnc_sortBy;

	// Set enemy roadblock allegiance to match nearest main marker
	private _mainMarkers = markersX - controlsX -  watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - hmgpostsFIA;
	{
		if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
			private _nearX = [_mainMarkers, markerPos _x] call BIS_fnc_nearestPosition;
			private _sideX = sidesX getVariable [_nearX,sideUnknown];
			sidesX setVariable [_x,_sideX,true];
		};
	} forEach controlsX;

	{
		[_x] call A3A_fnc_mrkUpdate
	} forEach (markersX - controlsX);

	if (count watchpostsFIA > 0) then {
		markersX = markersX + watchpostsFIA;
		publicVariable "markersX";
	};

	if (count roadblocksFIA > 0) then {
		markersX = markersX + roadblocksFIA;
		publicVariable "markersX";
	};

	if (count aapostsFIA > 0) then {
		markersX = markersX + aapostsFIA;
		publicVariable "markersX";
	};

	if (count atpostsFIA > 0) then {
		markersX = markersX + atpostsFIA;
		publicVariable "markersX";
	};

	if (count hmgpostsFIA > 0) then {
		markersX = markersX + hmgpostsFIA;
		publicVariable "markersX";
	};

	{
		if (_x in destroyedSites) then {
			sidesX setVariable [_x, Invaders, true];
			[_x] call A3A_fnc_destroyCity
		};
	} forEach citiesX;

    //Load aggro stacks and level and calculate current level
    ["aggressionOccupants"] call A3A_fnc_getStatVariable;
	["aggressionInvaders"] call A3A_fnc_getStatVariable;
    [true] call A3A_fnc_calculateAggression;

	["inactivityRivals"] call A3A_fnc_getStatVariable;
	[true] call SCRT_fnc_rivals_calculateActivity;

	["chopForest"] call A3A_fnc_getStatVariable;

	["posHQ"] call A3A_fnc_getStatVariable;
	["nextTick"] call A3A_fnc_getStatVariable;
	["staticsX"] call A3A_fnc_getStatVariable;

	{_x setPos getMarkerPos respawnTeamPlayer} forEach ((call A3A_fnc_playableUnits) select {side _x == teamPlayer});
	_sites = markersX select {sidesX getVariable [_x,sideUnknown] == teamPlayer};

	// Move headless client logic objects near HQ so that firedNear EH etc. work more reliably
	private _hcpos = markerPos respawnTeamPlayer vectorAdd [-100, -100, 0];
	{ _x setPosATL _hcpos } forEach (entities "HeadlessClient_F");

	tierPreference = 1;
	publicVariable "tierPreference";
	// update war tier silently, calls updatePreference if changed
	[true] call A3A_fnc_tierCheck;

	if (isNil "usesWurzelGarrison") then {
		//Create the garrison new
        Info("No WurzelGarrison found, creating new!");
		[airportsX, "Airport", [0,0,0]] spawn A3A_fnc_createGarrison;	//New system
		[resourcesX, "Other", [0,0,0]] spawn A3A_fnc_createGarrison;	//New system
		[milbases, "MilitaryBase", [0,0,0]] spawn A3A_fnc_createGarrison;	//New system
		[factories, "Other", [0,0,0]] spawn A3A_fnc_createGarrison;
		[outposts, "Outpost", [1,1,0]] spawn A3A_fnc_createGarrison;
		[seaports, "Other", [1,0,0]] spawn A3A_fnc_createGarrison;

	} else {
		//Garrison save in wurzelformat, load it
        Info("WurzelGarrison found, loading it!");
		["wurzelGarrison"] call A3A_fnc_getStatVariable;
	};

    //Load state of testing timer
    ["testingTimerIsActive"] call A3A_fnc_getStatVariable;

	// Load all player data into A3A_playerSaveData hashmap. Works around issues with game copies
	_savedPlayers = "savedPlayers" call A3A_fnc_returnSavedStat;
	if (isNil "_savedPlayers") then { _savedPlayers = [] };
	{
		private _uid = _x;
		private _playerData = createHashMap;
		{
			_playerData set [_x, [_uid, _x] call A3A_fnc_retrievePlayerStat];
		} forEach ["moneyX", "loadoutPlayer", "scorePlayer", "rankPlayer", "personalGarage"];

		if (isNil {_playerData get "moneyX"}) then { Error_1("Saved player %1 has no money var", _uid); continue };
		A3A_playerSaveData set [_uid, _playerData];
	} forEach _savedPlayers;

    Info("Persistent Load Completed.");

	// uh, why here?
	["tasks"] call A3A_fnc_getStatVariable;

	statsLoaded = 0; publicVariable "statsLoaded";
	petros allowdamage true;

	{specialVarLoads deleteAt _x;} forEach (keys specialVarLoads);
	specialVarLoads = nil;
};
Info("loadServer Completed.");
