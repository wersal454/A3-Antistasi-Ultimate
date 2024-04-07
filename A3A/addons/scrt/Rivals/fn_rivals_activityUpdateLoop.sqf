/*
Maintainer: Socrates, based on Antistasi Community's aggro code
    Update rivals activity with each loop's tick (one minute).

Return Value:
    <NIL>

Scope: Server
Environment: Any
Public: Yes
Dependencies:
    <ARRAY> inactivityStackRivals

Example:
[] spawn SCRT_fnc_rivals_activityUpdateLoop;
*/
#include "..\defines.inc"
FIX_LINE_NUMBERS()


if (!areRivalsEnabled) exitWith {
    Info("Rivals are not enabled, exiting activity update loop.");
};

while {true} do {
	if (areRivalsDefeated) exitWith {
        Info("Rivals are already defeated, exiting activity update loop.");
	};

	//Sleep if no player is online or until rivals will be active
    if (!areRivalsDiscovered || {A3A_activePlayerCount == 0}) then { sleep 60; continue };

    waitUntil {!activityIsChanging};
    activityIsChanging = true;
    
    //Calculate new values for each element
    inactivityStackRivals = inactivityStackRivals apply {[(_x select 0) + (_x select 1), (_x select 1)]};
    //Filter out all elements which have passed the 0 value
    inactivityStackRivals = inactivityStackRivals select {(_x select 0) * (_x select 1) < 0};

	activityIsChanging = false;
    [] call SCRT_fnc_rivals_calculateActivity;

    sleep 60;
};
