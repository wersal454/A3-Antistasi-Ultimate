class namalsk {
	population[] = {
{"OldHospital", 81},
{"OldSawmill", 43},
{"TaraHarbor", 130},
{"Nemsk", 183},
{"NemskFactory", 34},
{"Jalovisko", 176},
{"Vorkuta", 301},
{"VorkutaOut", 139},
{"OldYard", 60},
{"Alakit", 31},
{"SebjanDam", 33},
{"SebjanAIR", 71},
{"SebjanCHEM", 65},
{"Sebjan", 232},
{"SebjanMINE", 40},
{"SebjanWAR", 41},
{"Lubjansk", 186},
{"TaraRAIL", 119},
{"BrenskRAIL", 149},
{"AII", 132},
{"AI", 6},
{"Brensk", 50},
{"Norinsk", 73}};
	disabledTowns[] = {"OldSawmill","NemskFactory","Alakit","SebjanDam","SebjanAIR","SebjanCHEM","SebjanMINE","SebjanWAR","BrenskRAIL"};
	antennas[] = {
		{7602.856,11245.77,0},{4807.747,10834.78,0},{4164.692,6654.220,0},{6301.125,9338.219,0},{7264.734,7077.224,0}
	};
	antennasBlacklistIndex[] = {0};
	banks[] = {}; //no suitable building available
	garrison[] = {
		{},{"milbase_1","outpost_5","outpost_8","seaport_1","control_2"},{},{"control_2"}
	};
	fuelStationTypes[] = {"Land_A_FuelStation_Feed","Land_Ind_FuelStation_Feed_EP1","Land_FuelStation_Feed_PMC","Land_Fuelstation","Land_Fuelstation_army","Land_Benzina_schnell"};
	milAdministrations[] = {
		{7347.248,7934.714,0},{5753.133,8670.256,0},{6672.96,11121.087,0}
	};
	climate = "temperate";
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
};
