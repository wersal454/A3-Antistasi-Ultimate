#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_unit"];

private _loadoutOverride = param [1];

_loadout = switch (side group _unit) do {
	case teamPlayer: {
		if (toLowerANSI worldName isEqualTo "enoch") then {
			[[],[],[],[selectRandom (FactionGet(civ,"uniforms") + FactionGet(reb,"uniforms")), []],[],[],"H_Hat_Tinfoil_F","",[],
			[(selectRandom unlockedmaps),"","",(selectRandom unlockedCompasses),(selectRandom unlockedwatches),""]];
		} else {
			[[],[],[],[selectRandom (FactionGet(civ,"uniforms") + FactionGet(reb,"uniforms")), []],[],[],selectRandom FactionGet(civ,"headgear"),"",[],
			[(selectRandom unlockedmaps),"","",(selectRandom unlockedCompasses),(selectRandom unlockedwatches),""]];
		};
	};
	
	default {
		[];
	};
};

_unit setUnitLoadout _loadout;

_unit selectWeapon (primaryWeapon _unit);
