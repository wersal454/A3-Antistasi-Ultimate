//WS - config.cpp

#include "..\script_component.hpp"

class CfgPatches 
{
    class PATCHNAME(WS) 
    {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"A3_Data_F_AoW_Loadorder", "Vehicles_F_lxWS"};
        skipWhenMissingDependencies = 1; // makes this entire config not load if any requiredAddons are not present
        author = AUTHOR;
        authors[] = { AUTHORS };
        authorUrl = "";
        VERSION_CONFIG;
    };
};

#include "CfgWeapons.hpp"