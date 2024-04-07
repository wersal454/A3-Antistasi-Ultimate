/*
Author: [A3A Team]
    Enemy near searches
Arguments:
    0.<ANY>  location/postion that will be used for the center of search
    1.<NUMBER> Search radius, will be defaulted to enemyNearDistance if not used
Return Value:
    <BOOL> 		if enemies are near

Scope: Clients
Environment: Unscheduled
Public: yes
Dependencies: 

Example:
    [cursorObject] call A3A_fnc_enemyNearCheck; 
*/

params [
    "_unitPos",
    ["_distance", enemyNearDistance]
];

private _nearEnemies = ((units Occupants + units Invaders) inAreaArray [
    _unitPos, _distance, _distance]) select { behaviour _x isEqualTo "COMBAT" && {_x call A3A_fnc_canFight} };

(_nearEnemies isNotEqualTo [])
