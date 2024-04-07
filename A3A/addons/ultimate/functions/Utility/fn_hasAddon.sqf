params [["_class", ""]];

if (_class isEqualTo "") exitWith {false};

private _check = [];

if (_class isEqualType []) exitWith {
    {
        if (isClass (configFile >> "cfgPatches" >> _x)) then {[format ["cfgPatches class %1 does exist.", _x], _fnc_scriptName] call A3U_fnc_log; _check pushBack true} else {[format ["cfgPatches class %1 does not exist.", _x], _fnc_scriptName] call A3U_fnc_log; _check pushBack false};
    } forEach _class;
    if (false in _check) exitWith {false};
    true
};

if (isClass (configFile >> "cfgPatches" >> _class)) then {
    true
} else {
    false
};