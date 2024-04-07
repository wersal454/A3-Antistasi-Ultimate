if (player != theBoss) exitWith {
    [localize "STR_A3A_Dialogs_clear_forest_header", localize "STR_A3A_Dialogs_clear_forest_only_comm"] call SCRT_fnc_misc_deniedHint;
};

{[_x,true] remoteExec ["hideObjectGlobal",2]} forEach (nearestTerrainObjects [getMarkerPos respawnTeamPlayer,["tree","bush","small tree"],70]);

chopForest = true;
publicVariable "chopForest";

playSound "A3AP_UiSuccess";
[localize "STR_A3A_Dialogs_clear_forest_header", localize "STR_A3A_Dialogs_clear_forest_success"] call A3A_fnc_customHint;
