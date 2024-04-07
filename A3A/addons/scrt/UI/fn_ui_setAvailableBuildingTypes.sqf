#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

disableSerialization;

private _display = findDisplay 80000;

if (str (_display) == "no display") exitWith {};

private _buildingTypeCombobox = _display displayCtrl 505;
private _index = lbCurSel _buildingTypeCombobox;
private _constructionType = _buildingTypeCombobox lbData _index;
private _shopLookupArray = nil;

switch(_constructionType) do {
	case("TRENCH"): {
        _shopLookupArray = ["Land_SandbagBarricade_01_half_F", "Land_SandbagBarricade_01_F", "Land_BasaltKerb_01_pile_F", "Land_SandbagBarricade_01_hole_F", "Land_BagFence_01_long_green_F", "Land_BagFence_Round_F", "Land_BagFence_Long_F", "Land_BagFence_01_round_green_F","Land_GarbageHeap_01_F", "Land_Tyres_F"];
    };
    case("OBSTACLE"): {
        _shopLookupArray = ["Land_CzechHedgehog_01_old_F","Land_DragonsTeeth_01_1x1_old_F", "Land_Barricade_01_10m_F", "Land_Barricade_01_4m_F", "Land_GarbageWashingMachine_F", "Land_Fortress_01_bricks_v1_F", "Land_Fortress_01_bricks_v2_F","Land_WoodPile_large_F", "Land_JunkPile_F", "Land_WoodPile_F", "Land_Razorwire_F", "Land_Wall_IndCnc_2deco_F", "Land_CncBarrier_dam_F"];
    };
    case("LIGHT_BUNKER"): {
        _shopLookupArray = ["Land_BagBunker_01_small_green_F", "Fort_Nest", "Land_BagBunker_Large_F", "Land_GuardTower_02_F", "Land_GuardTower_01_F", "Land_GuardBox_01_brown_F"];
    };
    case("HEAVY_BUNKER"): {
        _shopLookupArray = ["Land_Bunker_02_light_left_F", "Land_Bunker_02_light_right_F", "Land_PillboxBunker_01_hex_F", "Land_PillboxBunker_01_big_F", "Land_PillboxBunker_01_rectangle_F"];
    };
    case("MISC"): {
        _shopLookupArray = ["CamoNet_BLUFOR_F", "CamoNet_BLUFOR_open_F", "CamoNet_BLUFOR_big_F", "Land_CanvasCover_02_F", "Land_CanvasCover_01_F", "Land_LampShabby_F", "Land_MedicalTent_01_NATO_generic_outer_F", "Land_MedicalTent_01_NATO_generic_inner_F"];
    };
    default { 
        [1, format ["Bad Construction Type - %1 ", _constructionType], "fn_ui_setAvailableBuildingTypes"] call A3A_fnc_log;
    };
};

if (isNil "_shopLookupArray") exitWith {
    Error("Fatal Error - no lookup array for building menu, aborting.");
};


private _buildingCombobox = _display displayCtrl 506;
lbClear _buildingCombobox;

private _fillCombo = {
    params ["_buildings", "_comboBox"];

    {
        private _name = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
        _comboBox lbAdd _name;
        _comboBox lbSetData [_forEachIndex, _x];
    } forEach _buildings;
};

[_shopLookupArray, _buildingCombobox] call _fillCombo;

_buildingCombobox lbSetCurSel 0;