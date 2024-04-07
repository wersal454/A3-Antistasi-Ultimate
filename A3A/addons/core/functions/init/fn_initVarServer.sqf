/*
 * This file is called after initVarCommon.sqf, on the server only.
 *
 * We also initialise anything in here that we don't want a client that's joining to overwrite, as JIP happens before initVar.
 */
scriptName "initVarServer.sqf";
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Info("initVarServer started");

params ["_saveData"];

//Little bit meta.
serverInitialisedVariables = ["serverInitialisedVariables"];

private _declareServerVariable = {
	params ["_varName", "_varValue"];

	serverInitialisedVariables pushBackUnique _varName;

	if (!isNil "_varValue") then {
		missionNamespace setVariable [_varName, _varValue];
	};
};

//Declares a variable that will be synchronised to all clients at the end of initVarServer.
//Only needs using on the first declaration.
#define ONLY_DECLARE_SERVER_VAR(name) [#name] call _declareServerVariable
#define DECLARE_SERVER_VAR(name, value) [#name, value] call _declareServerVariable
#define ONLY_DECLARE_SERVER_VAR_FROM_VARIABLE(name) [name] call _declareServerVariable
#define DECLARE_SERVER_VAR_FROM_VARIABLE(name, value) [name, value] call _declareServerVariable

////////////////////////////////////////
//     GENERAL SERVER VARIABLES      ///
////////////////////////////////////////
Info("initialising general server variables");

//time to delete dead bodies, vehicles etc..
DECLARE_SERVER_VAR(cleantime, 3600);
//initial spawn distance. Less than 1Km makes parked vehicles spawn in your nose while you approach.
//User-adjustable variables are now declared in initParams
//DECLARE_SERVER_VAR(distanceSPWN, 1000);
DECLARE_SERVER_VAR(distanceSPWN1, distanceSPWN*1.3);
DECLARE_SERVER_VAR(distanceSPWN2, distanceSPWN*0.5);
//The furthest distance the AI can attack from using helicopters or planes
DECLARE_SERVER_VAR(distanceForAirAttack, 10000);
//The furthest distance the AI can attack from using trucks and armour
DECLARE_SERVER_VAR(distanceForLandAttack, 3000);

// Used by headless clients for crate scaling
DECLARE_SERVER_VAR(A3A_activePlayerCount, 1);

//Legacy tool for scaling AI difficulty. Should die.
DECLARE_SERVER_VAR(difficultyCoef, 0);

//Mostly state variables, used by various parts of Antistasi.
DECLARE_SERVER_VAR(bigAttackInProgress, false);
DECLARE_SERVER_VAR(AAFpatrols,0);

//Should vegetation around HQ be cleared
DECLARE_SERVER_VAR(chopForest, false);

DECLARE_SERVER_VAR(skillFIA, 5);																		//Initial skill level for FIA soldiers
//Initial Occupant Aggression
DECLARE_SERVER_VAR(aggressionOccupants, 0);
DECLARE_SERVER_VAR(aggressionStackOccupants, []);
DECLARE_SERVER_VAR(aggressionLevelOccupants, 1);
//Initial Invader Aggression
DECLARE_SERVER_VAR(aggressionInvaders, 0);
DECLARE_SERVER_VAR(aggressionStackInvaders, []);
DECLARE_SERVER_VAR(aggressionLevelInvaders, 1);
//Initial war tier.
DECLARE_SERVER_VAR(tierWar, 1);
DECLARE_SERVER_VAR(bombRuns, 0);
//Should various units, such as patrols and convoys, be revealed.
DECLARE_SERVER_VAR(revealX, false);
DECLARE_SERVER_VAR(A3A_activeTasks, []);
DECLARE_SERVER_VAR(A3A_taskCount, 0);
//List of statics (MGs, AA, etc) that will be saved and loaded.
DECLARE_SERVER_VAR(staticsToSave, []);
//Whether the players have access to radios.
DECLARE_SERVER_VAR(haveRadio, false);
//Initial HR
server setVariable ["hr",initialHr,true];
//Initial faction money pool
server setVariable ["resourcesFIA",initialFactionMoney,true];
// Time of last garbage clean. Note: serverTime may not reset to zero if server was not restarted. Therefore, it should capture the time at start of mission.
DECLARE_SERVER_VAR(A3A_lastGarbageCleanTime, serverTime);
// Hash map of custom non-member/AI item thresholds
DECLARE_SERVER_VAR(A3A_arsenalLimits, createHashMap);
//Time of last garbage clean notification
DECLARE_SERVER_VAR(A3A_lastGarbageCleanTimeNote, serverTime);
// Under-construction objects
DECLARE_SERVER_VAR(A3A_unbuiltObjects, []);

//Antistasi Plus variables

//Override uniforms on rebel loadouts
DECLARE_SERVER_VAR(randomizeRebelLoadoutUniforms, true);
//Stores  custom AI rebel loadouts.
DECLARE_SERVER_VAR(rebelLoadouts, createHashMap);
//Players who attend in parachute jumps
DECLARE_SERVER_VAR(paradropAttendants, []);
//Trader discount.
DECLARE_SERVER_VAR(traderDiscount, 0);
//Trader position.
DECLARE_SERVER_VAR(traderPosition, []);
//List of player-placed buildings that will be saved and loaded.
DECLARE_SERVER_VAR(constructionsToSave, []);
//Non-lethal support points similar to airstrikes
DECLARE_SERVER_VAR(supportPoints, 0);
//Whether the players have trader quest.
DECLARE_SERVER_VAR(isTraderQuestAssigned, false);
//Whether the players have access to trader.
DECLARE_SERVER_VAR(isTraderQuestCompleted, false);
//Check if occupants and invaders are defeated
DECLARE_SERVER_VAR(areOccupantsDefeated, false);
DECLARE_SERVER_VAR(areInvadersDefeated, false);
//Whether the rebels know about rival rebel faction.
DECLARE_SERVER_VAR(areRivalsDiscovered, false);
DECLARE_SERVER_VAR(inactivityStackRivals, []);
DECLARE_SERVER_VAR(inactivityLevelRivals, 5);
//Override uniforms on rebel loadouts
DECLARE_SERVER_VAR(rivalsLocationsMap, createHashMap);
DECLARE_SERVER_VAR(rivalsExcludedLocations, createHashMap);
DECLARE_SERVER_VAR(nextRivalsLocationReveal, 0);
//Check if occupants and invaders are defeated
DECLARE_SERVER_VAR(areOccupantsDefeated, false);
DECLARE_SERVER_VAR(areInvadersDefeated, false);
DECLARE_SERVER_VAR(areRivalsDefeated, false);
DECLARE_SERVER_VAR(isRivalsDiscoveryQuestAssigned, false);

////////////////////////////////////
//     SERVER ONLY VARIABLES     ///
////////////////////////////////////
//We shouldn't need to sync these.
Info("Setting server only variables");

// horrible naming
prestigeOPFOR = [75, 50] select cadetMode;												//Initial % support for NATO on each city
prestigeBLUFOR = 0;																	//Initial % FIA support on each city

// Don't need to be distributed
occupantsRadioKeys = 0;
invaderRadioKeys = 0;

// Recent casualties/damage taken by enemies, format [X, Y, time * 1000 + value]
A3A_recentDamageOcc = [];
A3A_recentDamageInv = [];

// Balance params updated by aggressionUpdateLoop
A3A_balancePlayerScale = 1;					// Important due to load/save scaling to 1 playerScale
A3A_balanceVehicleCost = 110;
A3A_balanceResourceRate = A3A_balancePlayerScale * A3A_balanceVehicleCost;

// Current resources, overwritten by saved game
A3A_resourcesDefenceOcc = A3A_balanceResourceRate * 3;													// 30% of max
A3A_resourcesDefenceInv = A3A_balanceResourceRate * (A3A_invaderBalanceMul / 10) * 6;							// 60% of max
A3A_resourcesAttackOcc = -10 * A3A_balanceResourceRate * (A3A_enemyAttackMul / 10);								// ~100 min to attack
A3A_resourcesAttackInv = -10 * A3A_balanceResourceRate * (A3A_enemyAttackMul / 10) * (A3A_invaderBalanceMul / 10) * 0.5;	// ~50 min to attack

// HQ knowledge values
A3A_curHQInfoOcc = 0;			// 0-1 ranges for current HQ
A3A_curHQInfoInv = 0;
A3A_oldHQInfoOcc = [];			// arrays of [xpos, ypos, knowledge]
A3A_oldHQInfoInv = [];

// These are silly, should be nil/true and local-defined only
A3A_buildingsToSave = [];
cityIsSupportChanging = false;
resourcesIsChanging = false;
savingServer = true;					// lock out saves until this is changed

prestigeIsChanging = false;

zoneCheckInProgress = false;
garrisonIsChanging = false;
movingMarker = false;
markersChanging = [];

playerHasBeenPvP = [];

A3A_playerSaveData = createHashMap;
destroyedBuildings = [];		// synced only on join, to avoid spam on change

testingTimerIsActive = false;

A3A_tasksData = [];

hcArray = [];					// array of headless client IDs

membersX = [];					// These two published later by startGame
theBoss = objNull;

activityIsChanging = false;
baseRivalsDecay = switch (rivalsDifficulty) do {
    case (1): { 0.28 };
	case (2): { 0.42 };
    case (3): { 0.65 };
    default {
		Error_1("Can't set base rivals decay - something wrong with %1 difficulty value.", str rivalsDifficulty);
	};
};
publicVariable "baseRivalsDecay";


///////////////////////////////////////////
//     INITIALISING ITEM CATEGORIES     ///
///////////////////////////////////////////
Info("Initialising item categories");

//We initialise a LOT of arrays based on the categories. Every category gets a 'allX' variables and an 'unlockedX' variable.

private _unlockableCategories = allCategoriesExceptSpecial + ["AA", "AT", "GrenadeLaunchers", "ArmoredVests", "ArmoredHeadgear", "BackpacksCargo"];

//Build list of 'allX' variables, such as 'allWeapons'
DECLARE_SERVER_VAR(allEquipmentArrayNames, allCategories apply {"all" + _x});

//Build list of 'unlockedX' variables, such as 'allWeapons'
DECLARE_SERVER_VAR(unlockedEquipmentArrayNames, _unlockableCategories apply {"unlocked" + _x});

//Various arrays used by the loot system. Could also be done using DECLARE_SERVER_VAR individually.
private _otherEquipmentArrayNames = [
	"initialRebelEquipment",
	"lootBasicItem",
	"lootNVG",
	"lootItem",
	"lootWeapon",
	"lootAttachment",
	"lootMagazine",
	"lootGrenade",
	"lootExplosive",
	"lootBackpack",
	"lootHelmet",
	"lootVest",
	"lootDevice",
	"invaderStaticWeapon",
	"occupantStaticWeapon",
	"rebelStaticWeapon",
	"invaderBackpackDevice",
	"occupantBackpackDevice",
	"rebelBackpackDevice",
	"civilianBackpackDevice"
];

DECLARE_SERVER_VAR(otherEquipmentArrayNames, _otherEquipmentArrayNames);

//We're going to use this to sync the variables later.
everyEquipmentRelatedArrayName = allEquipmentArrayNames + unlockedEquipmentArrayNames + otherEquipmentArrayNames;

//Initialise them all as empty arrays.
{
	DECLARE_SERVER_VAR_FROM_VARIABLE(_x, []);
} forEach everyEquipmentRelatedArrayName;

//Create a global namespace for custom unit types.
DECLARE_SERVER_VAR(A3A_customUnitTypes, [true] call A3A_fnc_createNamespace);

//money magazines
private _arrayMoney = ["Money_bunch","Money_roll","Money_stack","Money"];
DECLARE_SERVER_VAR(arrayMoney, _arrayMoney);

//SHOULD BE SYNCHRONIZED WITH arrayMoney VARIABLE
private _arrayMoneyAmount = [
	HALs_money_oldManItemsPrice select 0,
	HALs_money_oldManItemsPrice select 1,
	HALs_money_oldManItemsPrice select 2,
	HALs_money_oldManItemsPrice select 3
];
DECLARE_SERVER_VAR(arrayMoneyAmount, _arrayMoneyAmount);

////////////////////////////////////
//          MOD CONFIG           ///
////////////////////////////////////
Info("Setting mod configs");

//TFAR config
if (A3A_hasTFAR) then
{
	if (isServer) then
	{
		[] spawn {
            #include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
			waitUntil {sleep 1; !isNil "TF_server_addon_version"};
            Info("Initializing TFAR settings");
			["TF_no_auto_long_range_radio", true, true,"mission"] call CBA_settings_fnc_set;						//set to false and players will spawn with LR radio.
			tf_teamPlayer_radio_code = "";publicVariable "tf_teamPlayer_radio_code";								//to make enemy vehicles usable as LR radio
			tf_east_radio_code = tf_teamPlayer_radio_code; publicVariable "tf_east_radio_code";					//to make enemy vehicles usable as LR radio
			tf_guer_radio_code = tf_teamPlayer_radio_code; publicVariable "tf_guer_radio_code";					//to make enemy vehicles usable as LR radio
			["TF_same_sw_frequencies_for_side", true, true,"mission"] call CBA_settings_fnc_set;						//synchronize SR default frequencies
			["TF_same_lr_frequencies_for_side", true, true,"mission"] call CBA_settings_fnc_set;						//synchronize LR default frequencies
		};
	};
};

//////////////////////////////////////
//   SETUP FACTION AND DLC FLAGS   ///
//////////////////////////////////////
Info("Setting up faction and DLC equipment flags");

// Set enabled & disabled DLC/CDLC arrays for faction/equipment modification
private _loadedDLC = getLoadedModsInfo select {
	(_x#3 or {_x#0 isEqualTo "Arma 3 Creator DLC: Western Sahara"})
	and {!(_x#1 in ["A3","curator","argo","tacops", "kart"])}
} apply {tolower (_x#1)};
A3A_enabledDLC = (_saveData get "DLC") apply {tolower _x};                 // should be pre-checked against _loadedDLC
{
	A3A_enabledDLC insert [0, getArray (configFile/"A3A"/"Templates"/_x/"forceDLC"), true];		// add unique elements only
} forEach (_saveData get "factions");
A3A_disabledDLC = _loadedDLC - A3A_enabledDLC;
A3A_disabledMods = A3A_disabledDLC;                 // Split to allow CUP civilians with GM

// Everything that counts as vanilla: Official DLC plus various junk tags
A3A_vanillaMods = (getLoadedModsInfo select {_x#2 and _x#3} apply {tolower (_x#1)}) + ["", "officialmod"];

Debug_3("DLC enabled: %1 Disabled: %2 Vanilla: %3", A3A_enabledDLC, A3A_disabledDLC, A3A_vanillaMods);

// Set faction equipment flags by lowest common denominator
private _factions = _saveData get "factions";
private _occEquipFlags = getArray (configFile/"A3A"/"Templates"/(_factions#0)/"equipFlags");
private _invEquipFlags = getArray (configFile/"A3A"/"Templates"/(_factions#1)/"equipFlags");
A3A_factionEquipFlags = _occEquipFlags arrayIntersect _invEquipFlags;

Debug_1("Faction equip flags: %1", A3A_factionEquipFlags);

switch (gameMode) do {
	case 3: {
		areInvadersDefeated = true;
		publicVariable "areInvadersDefeated";
	};
	case 4: {
		areOccupantsDefeated = true;
		publicVariable "areOccupantsDefeated";
	};
};

// Build list of extra equipment mods so we can filter out the modern stuff as necessary
// Might not work for everything because of configSourceMod inconsistency (eg. "rhs_weap_fnfal50_61_base")
A3A_extraEquipMods = [];
{
    private _modpath = (configFile/"CfgPatches"/_x) call A3A_fnc_getModOfConfigClass;
    if (_modpath != "") then { A3A_extraEquipMods pushBackUnique _modpath };
} forEach ["task_force_radio", "acre_main", "tfar_static_radios", "ace_main"];

Debug_1("Extra equip mod paths: %1", A3A_extraEquipMods);

//////////////////////////////////////
//         TEMPLATE LOADING        ///
//////////////////////////////////////
Info("Reading templates");

{
    private _side = [west, east, resistance, civilian, east] # _forEachIndex;
    Info_2("Loading template %1 for side %2", _x, _side);

	private _cfg = configFile/"A3A"/"Templates"/_x;
	private _basepath = getText (_cfg/"basepath") + "\";
	private _file = getText (_cfg/"file") + ".sqf";

	if (_forEachIndex isNotEqualTo 4) then {
		[_basepath + _file, _side] call A3A_fnc_compatibilityLoadFaction;
	} else {
		[_basepath + _file] call A3A_fnc_loadRivals;
	};

    private _type = ["Occ", "Inv", "Reb", "Civ", "Riv"] # _forEachIndex;
    missionNamespace setVariable ["A3A_"+_type+"_template", _x, true];			// don't actually need this atm, but whatever
} forEach (_saveData get "factions");

{
	private _cfg = configFile/"A3A"/"AddonVics"/_x;
	private _basepath = getText (_cfg/"path") + "\";
	{
		Info_2("Loading addon file %1 for side %2", _x#1, _x#0);
		[_x#0, _basepath + _x#1] call A3A_fnc_loadAddon;
	} forEach getArray (_cfg/"files");

} forEach (_saveData get "addonVics");

call A3A_fnc_compileMissionAssets;

{ //broadcast the templates to the clients
    publicVariable ("A3A_faction_"+_x);
} forEach ["occ", "inv", "riv", "reb", "civ", "all"]; // ["A3A_faction_occ", "A3A_faction_inv", "A3A_faction_riv", "A3A_faction_reb", "A3A_faction_civ", "A3A_faction_all"]

// Set template-dependent map stuff

flagX setFlagTexture FactionGet(reb,"flagTexture");                 // HQ flag, should be local here
"NATO_carrier" setMarkerText FactionGet(occ,"spawnMarkerName");
"CSAT_carrier" setMarkerText FactionGet(inv,"spawnMarkerName");
"NATO_carrier" setMarkertype FactionGet(occ,"flagMarkerType");
"CSAT_carrier" setMarkertype FactionGet(inv,"flagMarkerType");

////////////////////////////////////
//      CIVILIAN VEHICLES       ///
////////////////////////////////////
Info("Creating civilian vehicles lists");

private _fnc_vehicleIsValid = {
	params ["_type"];
	private _cfg = configFile >> "CfgVehicles" >> _type;
	if !(isClass _cfg) exitWith { Error_1("Vehicle class %1 not found", _type); false };
	if (_cfg call A3A_fnc_getModOfConfigClass in A3A_disabledDLC) then {false} else {true};
};

private _fnc_filterAndWeightArray = {

	params ["_array", "_targWeight"];
	private _output = [];
	private _curWeight = 0;

	// first pass, filter and find total weight
	for "_i" from 0 to (count _array - 2) step 2 do {
		if ((_array select _i) call _fnc_vehicleIsValid) then {
			_output pushBack (_array select _i);
			_output pushBack (_array select (_i+1));
			_curWeight = _curWeight + (_array select (_i+1));
		};
	};
	if (_curWeight == 0) exitWith {_output};

	// second pass, re-weight
	private _weightMod = _targWeight / _curWeight;
	for "_i" from 0 to (count _output - 2) step 2 do {
		_output set [_i+1, _weightMod * (_output select (_i+1))];
	};
	_output;
};

private _civVehicles = [];
private _civVehiclesWeighted = [];

_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivCar"), 4] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivIndustrial"), 1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivMedical"), 0.1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivRepair"), 0.1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivFuel"), 0.1] call _fnc_filterAndWeightArray);

for "_i" from 0 to (count _civVehiclesWeighted - 2) step 2 do {
	_civVehicles pushBack (_civVehiclesWeighted select _i);
};

_civVehicles append FactionGet(reb,"vehiclesCivCar");
_civVehicles append FactionGet(reb,"vehiclesCivTruck");
_civVehicles append FactionGet(reb,"vehiclesCivSupply");

DECLARE_SERVER_VAR(arrayCivVeh, _civVehicles);
DECLARE_SERVER_VAR(civVehiclesWeighted, _civVehiclesWeighted);


private _civBoats = [];
private _civBoatsWeighted = [];

// Boats don't need any re-weighting, so just copy the data
private _civBoatData = FactionGet(civ,"vehiclesCivBoat");
for "_i" from 0 to (count _civBoatData - 2) step 2 do {
	private _boat = _civBoatData select _i;
	if (_boat call _fnc_vehicleIsValid) then {
		_civBoats pushBack _boat;
		_civBoatsWeighted pushBack _boat;
		_civBoatsWeighted pushBack (_civBoatData select (_i+1));
	};
};

DECLARE_SERVER_VAR(civBoats, _civBoats);
DECLARE_SERVER_VAR(civBoatsWeighted, _civBoatsWeighted);

private _undercoverVehicles = (arrayCivVeh - ["C_Quadbike_01_F"]) + FactionGet(reb,"vehiclesCivBoat") + FactionGet(reb,"vehiclesCivHeli") + FactionGet(reb, "vehiclesCivPlane");
DECLARE_SERVER_VAR(undercoverVehicles, _undercoverVehicles);

//////////////////////////////////////
//        ITEM INITIALISATION      ///
//////////////////////////////////////
//This is all very tightly coupled.
//Beware when changing these, or doing anything with them, really.

Info("Generating forbidden items list");
[] call A3U_fnc_grabForbiddenItems;
Info("Scanning config entries for items");
[A3A_fnc_equipmentIsValidForCurrentModset] call A3A_fnc_configSort;
Info("Categorizing vehicle classes");
[] call A3A_fnc_vehicleSort;
Info("Categorizing equipment classes");
[] call A3A_fnc_equipmentSort;
Info("Sorting grouped class categories");
[] call A3A_fnc_itemSort;
Info("Building loot lists");
[] call A3A_fnc_loot;

if (["tts_emission"] call A3U_fnc_hasAddon) then {call A3U_fnc_emission};

if (["diwako_anomalies"] call A3U_fnc_hasAddon) then {call A3U_fnc_fillMapAnomalies};

// Build smoke grenade magazine->muzzle hashmap
private _smokeMuzzleHM = createHashMap;
{
	private _muzzle = configName _x;
	{
		if (_x in allSmokeGrenades) then { _smokeMuzzleHM set [_x, _muzzle] };
	} forEach compatibleMagazines ["Throw", _muzzle];			// works around casing & missing elements
} forEach ("true" configClasses (configFile / "CfgWeapons" / "Throw"));

DECLARE_SERVER_VAR(A3A_smokeMuzzleHM, _smokeMuzzleHM);

////////////////////////////////////
//   CLASSING TEMPLATE VEHICLES  ///
////////////////////////////////////

// Utility items data init
call A3A_fnc_initUtilityItems;
ONLY_DECLARE_SERVER_VAR(A3A_utilityItemList);
ONLY_DECLARE_SERVER_VAR(A3A_utilityItemHM);

//fast ropes are hard defined here, because of old fixed offsets.
//fastrope needs to be rewritten and then we can get get ridd of this
private _vehFastRope = ["O_Heli_Light_02_unarmed_F","B_Heli_Transport_01_camo_F","RHS_UH60M_d","UK3CB_BAF_Merlin_HC3_18_GPMG_DDPM_RM","UK3CB_BAF_Merlin_HC3_18_GPMG_Tropical_RM","RHS_Mi8mt_vdv","RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv"];
DECLARE_SERVER_VAR(vehFastRope, _vehFastRope);
DECLARE_SERVER_VAR(A3A_vehClassToCrew,call A3A_fnc_initVehClassToCrew);


// Default vehicle resource costs
private _vehicleResourceCosts = createHashMap;

{ _vehicleResourceCosts set [_x, 20] } forEach FactionGet(all, "staticAA") + FactionGet(all, "staticAT") + FactionGet(all, "staticMortars");
{ _vehicleResourceCosts set [_x, 20] } forEach FactionGet(all, "vehiclesLightUnarmed") + FactionGet(all, "vehiclesTrucks");
{ _vehicleResourceCosts set [_x, 50] } forEach FactionGet(all, "vehiclesLightArmed");
{ _vehicleResourceCosts set [_x, 70] } forEach FactionGet(all, "vehiclesLightAPCs");
{ _vehicleResourceCosts set [_x, 100] } forEach FactionGet(all, "vehiclesAPCs");
{ _vehicleResourceCosts set [_x, 150] } forEach FactionGet(all, "vehiclesAA") + FactionGet(all, "vehiclesArtillery") + FactionGet(all, "vehiclesIFVs");
{ _vehicleResourceCosts set [_x, 165] } forEach FactionGet(all, "vehiclesLightTanks");
{ _vehicleResourceCosts set [_x, 230] } forEach FactionGet(all, "vehiclesTanks");

{ _vehicleResourceCosts set [_x, 70] } forEach FactionGet(all, "vehiclesHelisLight");
{ _vehicleResourceCosts set [_x, 100] } forEach FactionGet(all, "vehiclesHelisTransport");
{ _vehicleResourceCosts set [_x, 130] } forEach FactionGet(all, "vehiclesHelisLightAttack") + FactionGet(all, "vehiclesPlanesTransport");
{ _vehicleResourceCosts set [_x, 250] } forEach FactionGet(all, "vehiclesPlanesCAS") + FactionGet(all, "vehiclesPlanesAA");
{ _vehicleResourceCosts set [_x, 250] } forEach FactionGet(all, "vehiclesHelisAttack");


// Threat table
private _groundVehicleThreat = createHashMap;

{ _groundVehicleThreat set [_x, 40] } forEach FactionGet(all, "staticMGs");
{ _groundVehicleThreat set [_x, 60] } forEach FactionGet(all, "vehiclesLightArmed");
{ _groundVehicleThreat set [_x, 80] } forEach FactionGet(all, "staticAA") + FactionGet(all, "staticAT") + FactionGet(all, "staticMortars");
{ _groundVehicleThreat set [_x, 80] } forEach FactionGet(Reb, "vehiclesAA") + FactionGet(Reb, "vehiclesAT");
{ _groundVehicleThreat set [_x, 90] } forEach FactionGet(all, "vehiclesLightAPCs");
{ _groundVehicleThreat set [_x, 120] } forEach FactionGet(all, "vehiclesAPCs");
{ _groundVehicleThreat set [_x, 180] } forEach FactionGet(all, "vehiclesLightTanks");
{ _groundVehicleThreat set [_x, 200] } forEach FactionGet(all, "vehiclesAA") + FactionGet(all, "vehiclesArtillery") + FactionGet(all, "vehiclesIFVs");
{ _groundVehicleThreat set [_x, 300] } forEach FactionGet(all, "vehiclesTanks");


// Rebel vehicle cost
private _rebelVehicleCosts = createHashMap;

_fnc_setPriceIfValid =
{
	_this params ["_hashMap", "_className", "_price"];
	private _configClass = configFile >> "CfgVehicles" >> _className;
    if (isClass _configClass) then {
		_hashMap set [_className, _price];
	};
};

{ [_rebelVehicleCosts, _x, 100] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesBasic");
{ [_rebelVehicleCosts, _x, 200] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesCivCar") + FactionGet(reb, "vehiclesCivBoat");
{ [_rebelVehicleCosts, _x, 600] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesCivTruck") + FactionGet(reb, "vehiclesMedical");
{ [_rebelVehicleCosts, _x, 300] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesTruck");
{ [_rebelVehicleCosts, _x, 200] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesLightUnarmed");
{ [_rebelVehicleCosts, _x, 800] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesLightArmed");
{ [_rebelVehicleCosts, _x, 500] call _fnc_setPriceIfValid } forEach FactionGet(reb, "staticMGs") + FactionGet(reb, "vehiclesBoat");
{ [_rebelVehicleCosts, _x, 1000] call _fnc_setPriceIfValid } forEach FactionGet(reb, "staticAT");
{ [_rebelVehicleCosts, _x, 1200] call _fnc_setPriceIfValid } forEach FactionGet(reb, "staticAA");
{ [_rebelVehicleCosts, _x, 2500] call _fnc_setPriceIfValid } forEach FactionGet(reb, "staticMortars");
{ [_rebelVehicleCosts, _x, 1500] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesAA");
{ [_rebelVehicleCosts, _x, 1200] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesAT");
{ [_rebelVehicleCosts, _x, 5000] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesCivHeli");
{ [_rebelVehicleCosts, _x, 5000] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesPlane") + FactionGet(reb, "vehiclesCivPlane");


// Template overrides
private _overrides = FactionGet(Reb, "attributesVehicles") + FactionGet(Occ, "attributesVehicles") + FactionGet(Inv, "attributesVehicles");
{
	private _vehType = _x select 0;
	if !(_vehType in ((keys _vehicleResourceCosts) + (keys _rebelVehicleCosts))) then { continue };
	{
		if !(_x isEqualType []) then { continue };		// first entry is classname
		_x params ["_attr", "_val"];
		call {
			if (_attr == "threat") exitWith { _groundVehicleThreat set [_vehType, _val] };
			if (_attr == "cost") exitWith { _vehicleResourceCosts set [_vehType, _val] };
			if (_attr == "rebCost") exitWith { _rebelVehicleCosts set [_vehType, _val] };
		};
	} forEach _x;
} forEach _overrides;

DECLARE_SERVER_VAR(A3A_vehicleResourceCosts, _vehicleResourceCosts);
DECLARE_SERVER_VAR(A3A_groundVehicleThreat, _groundVehicleThreat);
DECLARE_SERVER_VAR(A3A_rebelVehicleCosts, _rebelVehicleCosts);

///////////////////////////
//     MOD TEMPLATES    ///
///////////////////////////
//Please respect the order in which these are called,
//and add new entries to the bottom of the list.
if (A3A_hasACE) then {
	[] call A3A_fnc_aceModCompat;
};

////////////////////////////////////
//     ACRE ITEM MODIFICATIONS   ///
////////////////////////////////////
if (A3A_hasACRE) then {FactionGet(reb,"initialRebelEquipment") append ["ACRE_PRC343","ACRE_PRC148","ACRE_PRC152","ACRE_SEM52SL"];};
if (A3A_hasACRE && startWithLongRangeRadio) then {FactionGet(reb,"initialRebelEquipment") append ["ACRE_SEM70", "ACRE_PRC117F", "ACRE_PRC77"];};

////////////////////////////////////
//    UNIT AND VEHICLE PRICES    ///
////////////////////////////////////
Info("Creating pricelist");

{server setVariable [_x,50,true]} forEach [FactionGet(reb,"unitRifle"), FactionGet(reb,"unitCrew")];
{server setVariable [_x,75,true]} forEach [FactionGet(reb,"unitMG"), FactionGet(reb,"unitGL"), FactionGet(reb,"unitLAT")];
{server setVariable [_x,100,true]} forEach [FactionGet(reb,"unitMedic"), FactionGet(reb,"unitExp"), FactionGet(reb,"unitEng")];
{server setVariable [_x,150,true]} forEach [FactionGet(reb,"unitSL"), FactionGet(reb,"unitSniper")];
{server setVariable [_x,500,true]} forEach [FactionGet(reb,"unitAT"), FactionGet(reb,"unitAA")];

//black market costs
{server setVariable [_x select 0, _x select 1, true]} forEach (FactionGet(reb,"blackMarketStock"));

server setVariable [FactionGet(reb,"rallyPoint"), 100, true];

{
	server setVariable [_x, _y, true];
} forEach A3A_rebelVehicleCosts;

///////////////////////
//     GARRISONS    ///
///////////////////////
Info("Initialising Garrison Variables");

tierPreference = 1;
cityUpdateTiers = [4, 8];
cityStaticsTiers = [0.2, 1];
airportUpdateTiers = [3, 6, 8];
airportStaticsTiers = [0.5, 0.75, 1];
outpostUpdateTiers = [4, 7, 9];
outpostStaticsTiers = [0.4, 0.7, 1];
milbaseUpdateTiers = [3, 6, 8];
milbaseStaticsTiers = [0.45, 0.725, 1];
otherUpdateTiers = [3, 7];
otherStaticsTiers = [0.3, 1];
[] call A3A_fnc_initPreference;

////////////////////////////
//     REINFORCEMENTS    ///
////////////////////////////
Info("Initialising Reinforcement Variables");
DECLARE_SERVER_VAR(reinforceMarkerOccupants, []);
DECLARE_SERVER_VAR(reinforceMarkerInvaders, []);
DECLARE_SERVER_VAR(canReinforceOccupants, []);
DECLARE_SERVER_VAR(canReinforceInvaders, []);

/////////////////////////////////////////
//     SYNCHRONISE SERVER VARIABLES   ///
/////////////////////////////////////////
Info("Sending server variables");

//Declare this last, so it syncs last.
DECLARE_SERVER_VAR(initVarServerCompleted, true);
{
	publicVariable _x;
} forEach serverInitialisedVariables;

Info("initVarServer completed");
