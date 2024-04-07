// worker function for persistent save button
if (player == theBoss) then {
	[] remoteExecCall ["A3A_fnc_saveLoop", 2];
} else {
	[getPlayerUID player, player] remoteExecCall ["A3A_fnc_savePlayer", 2];
	closeDialog 0;
	hintC (localize "STR_hints_personal_save_success");
};
