/*
Maintainer: Socrates
    Returns current size of rivals radius.

Return Value:
    <NUMBER> radius

Scope: Server
Environment: Any
Public: Yes
Dependencies:
    <NUMBER> inactivityLevelRivals

Example:
[] call SCRT_fnc_rivals_getOperationRadius;
*/

if (!areRivalsEnabled || {!areRivalsDiscovered || {areRivalsDefeated}}) exitWith {
    0;
};

(sqrt 2 / 2 * worldSize) / (inactivityLevelRivals + 2)

