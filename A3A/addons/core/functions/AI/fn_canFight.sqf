params ["_unit"];

if (!alive _unit) exitWith {false};         // also works as a null check
if (captive _unit) exitWith {false};
if (_unit getVariable ["incapacitated",false]) exitWith {false};
if (_unit getVariable ["surrendered",false]) exitWith {false};


true
