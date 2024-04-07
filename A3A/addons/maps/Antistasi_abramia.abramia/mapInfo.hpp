class abramia {
	population[] = {};
	disabledTowns[] = {};
	antennas[] = {
		{8247.17,8508.42,0},{1279.23,7194.89,0},{355.621,3020.95,0},{1260.02,1607.94,0},{4786.39,6836.08,0},{4193.22,3819.86,0},{6536.41,2014.64,0},{6906.09,770.765,0},{6237.4,4675.6,0}
	};
	antennasBlacklistIndex[] = {};
	banks[] = {
		{1126.75,5762.61,0},{1247.99,6384.2,0},{188.976,1507.52,0},{161.512,1692.07,0},{159.84,1706.39,0},{197.559,1512.86,0},{2687.69,1548.56,0},{7257.44,5873.08,0}
	}; 
	garrison[] = {
		{},{"airport_2"},{},{}
	};
	fuelStationTypes[] = {"Land_A_FuelStation_Feed","Land_Ind_FuelStation_Feed_EP1","Land_FuelStation_Feed_PMC","Land_Fuelstation","Land_Fuelstation_army","Land_Benzina_schnell"};
	milAdministrations[] = {
		{3580.250,3246.514,0},{9363.495,9231.574,0.253},{1877.148,7733.872,0},{8286.685,474.321,0}
	};
	climate = "temperate";
	buildObjects[] = {
		// Large vanilla arid structures
		{"Land_BagBunker_Large_F", 300}, {"Land_BagBunker_Tower_F", 300}, {"Land_BagBunker_Small_F", 60},
		{"Land_Shed_09_F", 120}, {"Land_Shed_10_F", 140},
		// Vanilla arid sandbag walls
		{"Land_BagFence_Long_F", 10}, {"Land_BagFence_Round_F", 10}, {"Land_BagFence_Short_F", 10},
		// Non-camo vanilla stuff
		{"Land_SandbagBarricade_01_half_F", 20}, {"Land_SlumWall_01_s_2m_F", 5}, {"Land_PillboxBunker_01_hex_F", 200},
		{"Land_Barricade_01_4m_F", 30}, {"Land_GuardBox_01_brown_F", 80}, {"Land_Tyres_F", 10}
	};
};
