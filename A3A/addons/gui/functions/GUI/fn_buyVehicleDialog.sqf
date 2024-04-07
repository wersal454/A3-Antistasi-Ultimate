/*
Maintainer: DoomMetal
    Handles the initialization and updating of the Buy Vehicle dialog.
    This function should only be called from BuyVehicle onLoad and control activation EHs.
Arguments:
    <STRING> Mode, only possible value for this dialog is "onLoad"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.
Return Value:
    Nothing
Scope: Clients, Local Arguments, Local Effect
Environment: Scheduled for onLoad mode / Unscheduled for everything else unless specified
Public: No
Dependencies:
    None
Example:
    ["onLoad"] spawn A3A_fnc_buyVehicleDialog; // initialization
*/

#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params[
    ["_mode","onLoad"], 
    ["_params",[]]
];

switch (_mode) do
{
    case ("switchTab"):
    {       
        private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
        private _selectedTab = _params select 0;

        Debug_1("MainDialog switching tab to %1.", _selectedTab);

        private _selectedTabIDC = -1;
        switch (_selectedTab) do 
        {
            case ("civilian"): {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEMAIN;
            };
            case("rebel"): {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEMAIN;};
            case ("static"): {
                _selectedTabIDC = A3A_IDC_BUYSTATICMAIN;
            };
            case("other"): {
                _selectedTabIDC = A3A_IDC_BUYOTHERMAIN;
            };
        };

        if (_selectedTabIDC == -1) exitWith {
            Error("Attempted to access tab without permission : %1", _selectedTab);
        };

        private _allTabs = [
            A3A_IDC_BUYCIVVEHICLEMAIN,
            A3A_IDC_BUYREBVEHICLEMAIN,
            A3A_IDC_BUYSTATICMAIN,
            A3A_IDC_BUYOTHERMAIN,
            A3A_IDC_BUYVEHICLEPREVIEW
        ];

        // Hide all tabs
        Debug("Hiding all tabs");
        {
            private _ctrl = _display displayCtrl _x;
            _ctrl ctrlShow false;
        } forEach _allTabs;


        // Show selected tab
        Debug("Showing selected tab");
        private _selectedTabCtrl = _display displayCtrl _selectedTabIDC;
        _selectedTabCtrl ctrlShow true;
    };

    case ("onLoad"):
    {
        ['on'] call SCRT_fnc_ui_toggleMenuBlur;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLEMAIN, A3A_IDC_CIVVEHICLESGROUP, "civilian"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLEMAIN, A3A_IDC_REBVEHICLESGROUP, "military"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYSTATICMAIN, A3A_IDC_STATICSGROUP, "static"]] call A3A_fnc_buyVehicleTabs;
        ["other"] call A3A_fnc_buyVehicleTabs;

        // show the vehicle tab so that user don't freak out
        private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
        private _selectedTabCtrl = _display displayCtrl A3A_IDC_BUYCIVVEHICLEMAIN;
        _selectedTabCtrl ctrlShow true;
    };

    case ("onUnload"): 
    {
        ['off'] call SCRT_fnc_ui_toggleMenuBlur;
    };

    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("BuyVehicleDialog mode does not exist: %1", _mode);
    };
};
