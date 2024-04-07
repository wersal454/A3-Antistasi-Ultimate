#define AMOUNT 250

private ["_resourcesPlayer","_pointsXJ","_target"];
_resourcesPlayer = player getVariable "moneyX";
if (_resourcesPlayer < AMOUNT) exitWith {
	[localize "STR_A3A_OrgPlayers_donateMoney_header", format [localize "STR_A3A_OrgPlayers_donateMoney_less250", A3A_faction_civ get "currencySymbol"]] call SCRT_fnc_misc_deniedHint;
};

if (count _this == 0) exitWith {
	[0,AMOUNT] remoteExec ["A3A_fnc_resourcesFIA",2];
	_pointsXJ = (player getVariable "score") + 1;
	player setVariable ["score",_pointsXJ,true];
	[-AMOUNT] call A3A_fnc_resourcesPlayer;
	[localize "STR_A3A_OrgPlayers_donateMoney_header", format [localize "STR_A3A_OrgPlayers_donateMoney_success", A3A_faction_civ get "currencySymbol"]] call A3A_fnc_customHint;
};
_target = cursorTarget;

if (!isPlayer _target) exitWith {
	[localize "STR_A3A_OrgPlayers_donateMoney_header",localize "STR_A3A_OrgPlayers_donateMoney_no_player"] call SCRT_fnc_misc_deniedHint;
};

[-AMOUNT] call A3A_fnc_resourcesPlayer;
[AMOUNT] remoteExec ["A3A_fnc_resourcesPlayer", _target];

[localize "STR_A3A_OrgPlayers_donateMoney_header", format [localize "STR_A3A_OrgPlayers_donateMoney_player", name _target, A3A_faction_civ get "currencySymbol"]] call A3A_fnc_customHint;