class iron_excelsior_Tobruk {
	population[] = {
		{"baccara", 110},{"marcuca", 59},{"solaro", 13},{"hariga", 122},{"perrone", 0},{"hotel", 143},{"tobruk", 1039},{"birauda", 151},{"hospital", 51},{"airenti", 3},{"oupost2", 499},{"kingscross", 25},{"outpost1", 0},{"maclub", 131},{"gubbi", 119},{"mahmud", 125},{"marsatobruk", 112},{"daud", 147},{"distillery", 14}
	};
	disabledTowns[] = {"marcuca","solaro","perrone","hospital","airenti","kingscross","outpost1","distillery"};
	antennas[] = {
	{4948.738,1732.944,0},{475.454,7961.95,0},{8831.038,1038.956,0},{5276.479,6441.453,0}
};
	antennasBlacklistIndex[] = {};
	banks[] = {}; //no suitable building available
	garrison[] = {
		{},{"outpost","outpost_1","seaport","seaport_1","control"},{},{"control"}
	};
	fuelStationTypes[] = {"Land_A_FuelStation_Feed","Land_Ind_FuelStation_Feed_EP1","Land_FuelStation_Feed_PMC","Land_Fuelstation","Land_Fuelstation_army","Land_Benzina_schnell"};
	milAdministrations[] = {
		{5997.239,6149.627,0.197}
	};
	climate = "arid";
	buildObjects[] = {
		{"Land_fortified_nest_big_EP1", 300}, {"Land_Fort_Watchtower_EP1", 300}, {"Fortress2", 200}, {"Fortress1", 100}, {"Fort_Nest", 60},
		{"Land_Shed_09_F", 120}, {"Land_Shed_10_F", 140}, {"ShedBig", 100}, {"Shed", 100}, {"ShedSmall", 60}, {"Land_GuardShed", 30},
		// CUP sandbag walls
		{"Land_BagFenceLong", 10}, {"Land_BagFenceShort", 10}, {"Land_BagFenceRound", 10},        //{"Land_BagFenceEnd", 0, 5}, 
		// Other CUP fences
		{"Land_fort_artillery_nest_EP1", 200}, {"Land_fort_rampart_EP1", 50}, {"Fort_Barricade", 50}, {"Fence", 20}, {"FenceWood", 10}, {"FenceWoodPalet", 10}, 
		// Non-camo vanilla stuff
		{"Land_SandbagBarricade_01_half_F", 20}, {"Land_SlumWall_01_s_2m_F", 5}, {"Land_PillboxBunker_01_hex_F", 200},
		{"Land_Barricade_01_4m_F", 30}, {"Land_GuardBox_01_brown_F", 80}, {"Land_Tyres_F", 10}
	};
	// Needs to be re-done when possible (?)
};
