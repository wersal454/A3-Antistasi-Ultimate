/*


    Warning: Destroys A3A_saveTarget so shouldn't be used after a game is started
*/

// Optional (new) save vars used by the selector
private _optionalVars = ["name", "version", "saveTime", "ended", "params", "factions", "DLC", "addonVics"];

private _fnc_gameMissing = { isNil {"membersX" call A3A_fnc_returnSavedStat} };
private _saveData = [];
private _campaignIDs = [];
private _serverID = profileNameSpace getVariable ["ss_ServerID",""];

// Old Plus saves
private _saveList = [profileNamespace getVariable "antistasiPlus2SavedGames"] param [0, [], [[]]];
{
    _x params ["_cid", "_map", "_gameType"];
    _campaignIDs pushBack _cid;
    if (_gameType == "Blufor") then { continue };		   // maybe compatible, but complicates things
    A3A_saveTarget = [_serverID, _cid, _map];
    if (call _fnc_gameMissing) then { continue };	   // check there's actually data

    private _game = createHashMapFromArray [["serverID", _serverID], ["gameID", _cid], ["map", _map]];
    { _game set [_x, _x call A3A_fnc_returnSavedStat] } forEach _optionalVars;
    _saveData pushBack _game;

} forEach _saveList;

private _oldCampaignID = profileNameSpace getVariable ["ss_CampaignID", ""];
if !(_oldCampaignID in _campaignIDs) then {
    A3A_saveTarget = [_serverID, _oldCampaignID, worldName];                          // Pre 2.3 saves
    if (call _fnc_gameMissing) then { A3A_saveTarget set [1, ""] };                   // Original saves (no campaign ID)
    if (call _fnc_gameMissing) exitWith {};
    _saveData pushBack createHashMapFromArray [["serverID", _serverID], ["gameID", A3A_saveTarget#1], ["map", worldName]];
};

// missionProfileNamespace saves
private _saveList2 = [missionProfileNamespace getVariable "antistasiPlus2SavedGames"] param [0, [], [[]]];
{
    _x params ["_cid", "_map"];
    A3A_saveTarget = [false, _cid, _map];
    if (call _fnc_gameMissing) then { continue };	   // check there's actually data

    private _game = createHashMapFromArray [["serverID", false], ["gameID", _cid], ["map", _map]];
    { _game set [_x, _x call A3A_fnc_returnSavedStat] } forEach _optionalVars;
    _saveData pushBack _game;

} forEach _saveList2;

reverse _saveData;          // return newest games at the top
_saveData;
