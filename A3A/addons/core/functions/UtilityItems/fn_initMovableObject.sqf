/*
Author: Killerswin2
    add actions for the to light the player
Arguments:
    0.<Object> Object that we try to add actions to 
    1.<String> Custom JIP key to prevent overwriting 

Return Value:
    <nil>

Scope: Clients
Environment: Unscheduled
Public: No
Dependencies: 

Example:
    [_object, ] call A3A_fnc_initMovableObject; 
*/

params [["_object", objNull, [objNull]]];

_object addAction [
    localize "STR_A3A_carryObject",
    {
        [_this#3, true] call A3A_fnc_carryItem;
    },
    _object,
    1.5,
    true,
    true,
    "",
    "(
        (([_this] call A3A_fnc_countAttachedObjects) isEqualTo 0)
        and (attachedTo _target isEqualTo objNull)
    )", 
    8
];

_object addAction [
    localize "STR_A3A_rotateObject",
    {
        [_this#3] call A3A_fnc_rotateItem;
    },
    _object,
    1.5,
    true,
    true,
    "",
    "(
        !(_originalTarget getVariable ['A3A_rotatingObject',false]) 
        and (attachedTo _originalTarget isEqualTo objNull)
    )",
    8
];

nil;