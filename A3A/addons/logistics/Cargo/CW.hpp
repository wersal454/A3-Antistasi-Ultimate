//Crates/Boxes

//Weapons
//MGs
class 3AS_3AS_Static_HeavyRepeater_3AS_HeavyRepeaterShieldStatic_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, 0, 1.5};
    rotation[] = {0,-1,0}; //You can turn those ingame
    size = 2;
    recoil = 200;
	isWeapon = 1;
};
class 3AS_3AS_Static_HeavyRepeater_3AS_HeavyRepeaterStatic_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, 0, 1.5};
    rotation[] = {0,-1,0}; //You can turn those ingame
    size = 2;
    recoil = 200;
	isWeapon = 1;
};
//AA
//Flak 30/38 same Model
class 3AS_3AS_Static_ParticleCannon_3AS_ParticleCannon_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, -2, 1};
    rotation[] = {-1.5, -2, 0};
    size = 4;
    recoil = 2000;
	isWeapon = 1;
};
class CWDependencies_aaturret_turret : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, 0.1, 1.4};
    rotation[] = {0,1,0};
    size = 4;
    recoil = 1500;
	isWeapon = 1;
	blackList[] = {};
};
//Mortars
class ls_vehicles_ground_mortar_ls_ground_mortar_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0, 0.5, 0.8};
    rotation[] = {0,-1,0};
    size = 2;
    recoil = 2000;
	isWeapon = 1;
};
class 3AS_3as_static_Mortar_model_republicmortar_p3d : TRIPLES(ADDON,Cargo,Base)
{
    offset[] = {0.2, 0.2, 0.7};
    rotation[] = {0,-1,0};
    size = 2;
    recoil = 2000;
	isWeapon = 1;
};
// Fuel Barrels
