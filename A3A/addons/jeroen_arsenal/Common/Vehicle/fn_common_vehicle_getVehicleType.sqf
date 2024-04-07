#include "defineCommon.inc"



params["_vehicle"];

private _type = typeOf _vehicle;
private _cfg = (configfile >> "CfgVehicles" >> _type);
private _simulation = gettext (_cfg >> "simulation");


private _index = switch (tolower _simulation) do {
	case "car";
	case "carx": {
		TYPE_CAR;
	};
	case "tank";
	case "tankx": {
		if (getnumber (_cfg >> "maxspeed") > 0) then {
			TYPE_ARMOR;
		} else {
			TYPE_STATIC;
		};
	};
	case "helicopter";
	case "helicopterx";
	case "helicopterrtd": {
		TYPE_HELI;
	};
	case "airplane";
	case "airplanex": {
		TYPE_PLANE;
	};
	case "ship";
	case "shipx";
	case "submarinex": {
		TYPE_NAVAL;
	};
	default {-1};
};

//return
_index
