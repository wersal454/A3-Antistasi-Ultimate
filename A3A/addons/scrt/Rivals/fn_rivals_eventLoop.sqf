/*  This loop checks if condition for random game events are met.
    Execution on: Server

    Scope: Internal

    Params:
        None

    Returns:
        Nothing
*/

#include "..\defines.inc"
FIX_LINE_NUMBERS()

if(!isServer) exitWith {};
if (!areRivalsEnabled) exitWith {};
if (areRivalsDefeated) exitWith {};

Info("Rivals Event Loop Init.");

isRivalEventInProgress = false;
rivalEventCooldown = 0;

while {true} do {
    waitUntil {!isNil "A3A_activePlayerCount"};

    sleep 300;

    Info("Rivals event loop tick.");

	//if rivals are already defeated, we may exit the loop entirely as it makes no sense to work
	if (areRivalsDefeated) exitWith {
        Info("Rivals are already defeated, exiting update loop.");
    };

	if (!areRivalsDiscovered || {isRivalEventInProgress || {A3A_activePlayerCount == 0 }}) then { 
        sleep 60; 
        continue;
    };

    //cooldown is needed so players won't be flooded with events
    sleep rivalEventCooldown;
    if (rivalEventCooldown > 0) then {
        rivalEventCooldown = 0;
    };

    if (([] call SCRT_fnc_rivals_rollProbability)) then {
        [] call SCRT_fnc_rivals_selectAndExecuteEvent;
    } else {
        Info("Event doesn't rolled - low rivals activity.");
    };
};
