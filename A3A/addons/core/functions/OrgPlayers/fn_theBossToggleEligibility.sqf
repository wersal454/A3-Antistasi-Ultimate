if !(isServer) exitWith {};
params ["_playerX", ["_newBoss", objNull]];

// Find real player unit, in case of remote control
_playerX = _playerX getVariable ["owner", _playerX];

private _forceElection = false;
private _text = "";
if (_playerX getVariable ["eligible",false]) then
{
	_playerX setVariable ["eligible",false,true];
	if (_playerX == theBoss) then
	{
		if(!isNull _newBoss && isPlayer _newBoss) then
		{
			if ([_newBoss] call A3A_fnc_makePlayerBossIfEligible) then {
				_text = format [localize "STR_A3A_OrgPlayers_resign_1", name _newBoss];
			}
			else {
				_text = format [localize "STR_A3A_OrgPlayers_resign_2", name _newBoss];
			};
		}
		else {
			_text = localize "STR_A3A_OrgPlayers_resign_3";
		};
	}
	else
	{
		_text = localize "STR_A3A_OrgPlayers_resign_4";
	};
}
else
{
	if ([_playerX] call A3A_fnc_isMember) then { _forceElection = true };
	_playerX setVariable ["eligible",true,true];
	_text = format [localize "STR_A3A_OrgPlayers_resign_5", A3A_faction_reb get "name"];
};

[localize "STR_antistasi_actions_commander_text", _text] remoteExec ["A3A_fnc_customHint", _playerX];

// Will remove current boss if now ineligible
[_forceElection] call A3A_fnc_assignBossIfNone;
