class WW2_Omaha_Beach {
	population[] = {
{"ww2_location_fr_1", 359},

{"ww2_location_fr_2", 225},

{"ww2_location_fr_3", 297},

{"ww2_location_fr_4", 160},

{"ww2_location_fr_5", 179},

{"ww2_location_fr_6", 126},

{"ww2_location_fr_7", 168},

{"ww2_location_fr_8", 141},

{"ww2_location_fr_9", 159},

{"ww2_location_fr_10", 276},

{"ww2_location_fr_11", 276},

{"ww2_location_fr_12", 163}
			}; 
	disabledTowns[] = {
			};
	antennas[] = {
		{726.183,434.142,0},{3823.263,2381.742,-0.003},{4827.065,4857.306,-0.001},{1637.561,3384.089,0}
	};
	antennasBlacklistIndex[] = {};
	banks[] = {}; //no suitable/defined buildings
	garrison[] = {
		{},{"airport_1"},
		{},{}
	};
	fuelStationTypes[] = {
		"Land_FuelStation_Feed_F","Land_fs_feed_F","Land_FuelStation_01_pump_malevil_F","Land_FuelStation_01_pump_F","Land_FuelStation_02_pump_F","Land_FuelStation_03_pump_F","SPE_Fuel_Barrel_German_01","SPE_Fuel_Barrel_US_01"
	};
	milAdministrations[] = {
		{1626.364,2466.555,0}, {4243.402,1221.156,0}
	};
	climate = "temperate";
	buildObjects[] = {
		// Pillbox bunkers
		{"Land_PillboxBunker_01_hex_F", 200}, {"Land_PillboxBunker_01_rectangle_F", 300},
		// SPE sandbag walls
		{"Land_SPE_Sandbag_Long", 15}, {"Land_SPE_Sandbag_Short", 10}, {"Land_SPE_Sandbag_Nest", 15}, {"Land_SPE_Sandbag_Curve", 20},
		// Some extra stuff from vanilla
		{"Land_Barricade_01_4m_F", 30}, {"Land_GuardBox_01_brown_F", 80}, {"Land_Tyres_F", 10}
	};
};
