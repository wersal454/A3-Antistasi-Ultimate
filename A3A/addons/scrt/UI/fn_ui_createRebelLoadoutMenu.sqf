createDialog 'rebelLoadoutMenu';

private _addLoadoutMark = {
    params ["_control"];
    private _oldText = ctrlText _control;
    _control ctrlSetText format ["%1 %2", _oldText, "[x]"];
};

private _display = findDisplay 120000;

if (str (_display) != "no display") then {
    if ((A3A_faction_reb get "unitRifle") in rebelLoadouts) then {
        [(_display displayCtrl 120001)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitMG") in rebelLoadouts) then {
        [(_display displayCtrl 120002)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitMedic") in rebelLoadouts) then {
       [(_display displayCtrl 120003)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitEng") in rebelLoadouts) then {
        [(_display displayCtrl 120004)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitGL") in rebelLoadouts) then {
        [(_display displayCtrl 120005)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitSniper") in rebelLoadouts) then {
        [(_display displayCtrl 120006)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitLAT") in rebelLoadouts) then {
        [(_display displayCtrl 120007)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitCrew") in rebelLoadouts) then {
        [(_display displayCtrl 120008)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitSL") in rebelLoadouts) then {
        [(_display displayCtrl 120009)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitExp") in rebelLoadouts) then {
        [(_display displayCtrl 120010)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitAT") in rebelLoadouts) then {
        [(_display displayCtrl 120011)] call _addLoadoutMark;
    };

    if ((A3A_faction_reb get "unitAA") in rebelLoadouts) then {
        [(_display displayCtrl 120012)] call _addLoadoutMark;
    };
};