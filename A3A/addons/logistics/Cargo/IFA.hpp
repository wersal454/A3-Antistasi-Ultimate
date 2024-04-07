//Crates/Boxes
class WW2_Assets_m_Weapons_Ammoboxes_m_IF_GER_Weapons_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, 0, -0.1};
    rotation[] = {0,0,0};
    size = 1;
    recoil = 0;
};
class WW2_Assets_m_Weapons_Ammoboxes_m_IF_SU_Arty_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, 0, -0.1};
    rotation[] = {0,0,0};
    size = 1;
    recoil = 0;
};
//Weapons
//MGs
class WW2_Assets_m_Vehicles_StaticWeapons_m_IF_MG42_Lafette_High_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, -1.5, 0};
    rotation[] = {0,-1,0}; //You can turn those ingame
    size = 2;
    recoil = 200;
	isWeapon = 1;
};
class WW2_Assets_m_Vehicles_StaticWeapons_m_WW2_MG34_lafette_high_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, -1.5, 0};
    rotation[] = {0,-1,0}; //You can turn those ingame
    size = 2;
    recoil = 150;
	isWeapon = 1;
};
//AA
//Flak 30/38 same Model
class WW2_Assets_m_Vehicles_StaticWeapons_m_IF_FlaK_38_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, -0.4, 0};
    rotation[] = {0,1,0};
    size = 3;
    recoil = 2000;
	isWeapon = 1;
};
class WW2_Assets_m_Vehicles_StaticWeapons_m_IF_Flakvierling_38_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, 0, 0.07};
    rotation[] = {0,1,0};
    size = 3;
    recoil = 1500;
	isWeapon = 1;
	blackList[] = {"LIB_SdKfz_7","LIB_SdKfz_7_w","LIB_DAK_SdKfz_7", "LIB_OpelBlitz_Open_Y_Camo", "LIB_DAK_OpelBlitz_Open", "LIB_OpelBlitz_Open_Y_Camo_w", "LIB_OpelBlitz_Open_G_Camo_w"};
};
//Mortars
class WW2_Assets_m_Weapons_Mortars_m_WW2_M2_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, -0.4, 1};
    rotation[] = {0,-1,0};
    size = 2;
    recoil = 1700;
	isWeapon = 1;
};
class WW2_Assets_m_Weapons_Mortars_m_IF_GrWr34_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, -0.1, 1};
    rotation[] = {0,-1,0};
    size = 2;
    recoil = 2000;
	isWeapon = 1;
};
class WW2_Assets_m_Weapons_Mortars_m_IF_Bm37_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, -0.3, 1};
    rotation[] = {0,-1,0};
    size = 2;
    recoil = 2000;
	isWeapon = 1;
};
// Fuel Barrels
