#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
#define SPACING     1

params ["_marker", "_placementMarker"];

private ["_vehicleMarker", "_heliMarker", "_hangarMarker", "_mortarMarker", "_planeMarker", "_markerPrefix", "_markerSplit", "_first", "_fullName"];

_vehicleMarker = [];
_heliMarker = [];
_hangarMarker = [];
_mortarMarker = [];
_samMarker = [];
_planeMarker = [];

//Calculating marker prefix
_markerPrefix = "";
_markerSplit = _marker splitString "_";
switch (_markerSplit select 0) do
{
  case ("airport"): {_markerPrefix = "airp_";};
  case ("outpost"): {_markerPrefix = "outp_";};
  case ("resource"): {_markerPrefix = "reso_";};
  case ("factory"): {_markerPrefix = "fact_";};
  case ("seaport"): {_markerPrefix = "seap_";};
  case ("milbase"): {_markerPrefix = "milb_";};
};
if(count _markerSplit > 1) then
{
  _markerPrefix = format ["%1%2_", _markerPrefix, _markerSplit select 1];
};

//Sort marker
_mainMarker = getMarkerPos _marker;
{
  _first = (_x splitString "_") select 0;
  _fullName = format ["%1%2", _markerPrefix, _x];
  if(_mainMarker distance (getMarkerPos _fullName) > 500) then
  {
    Error_2("Placementmarker %1 is more than 500 meter away from its mainMarker %2. You may want to check that!", _fullName, _marker);
  };
  switch (_first) do
  {
    case ("vehicle"): {_vehicleMarker pushBack _fullName;};
    case ("helipad"): {_heliMarker pushBack _fullName;};
    case ("hangar"): {_hangarMarker pushBack _fullName;};
    case ("plane"): {_planeMarker pushBack _fullName;};
    case ("mortar"): {_mortarMarker pushBack _fullName;};
	case ("sam"): {_samMarker pushBack _fullName;};
  };
  _fullName setMarkerAlpha 0;
} forEach _placementMarker;

if(count _vehicleMarker == 0) then
{
  // Not automatically wrong. Some locations may not have any vehicle places
  Info_1("InitSpawnPlaces: Could not find any vehicle places on %1!", _marker);
};

private ["_markerSize", "_distance", "_buildings", "_hangars", "_garages", "_helipads", "_markerX"];

_markerSize = markerSize _marker;
_distance = sqrt ((_markerSize select 0) * (_markerSize select 0) + (_markerSize select 1) * (_markerSize select 1));

_buildings = nearestObjects [getMarkerPos _marker, ["Land_Hangar_2", "Helipad_Base_F", "land_bunker_garage", "Land_vn_b_helipad_01", "Land_BludpadCircle", "Land_Hangar_F", "Land_TentHangar_V1_F", "Land_Airport_01_hangar_F", "Land_Mil_hangar_EP1", "Land_Ss_hangar", "Land_Ss_hangard", "Land_vn_helipad_base", "Land_vn_airport_01_hangar_f", "Land_vn_usaf_hangar_01", "Land_vn_usaf_hangar_02", "Land_vn_usaf_hangar_03"], _distance, true];

_hangars = [];
_helipads = [];
_garages = [];

{
  if((getPos _x) inArea _marker) then {
    private _type = typeOf _x;
    switch (true) do {
      case (_x isKindOf "Land_BludpadCircle");
      case (_x isKindOf "Land_vn_helipad_base");
      case (_x isKindOf "Land_vn_b_helipad_01");
      case (_x isKindOf "Helipad_Base_F"): {
        _helipads pushBack _x;
      };
      case (_type in ["Land_Hangar_2","land_bunker_garage"]): {
        _garages pushBack _x;
      };
      default {
        _hangars pushBack _x;
      };
	};
  };
} forEach _buildings;

private _heliCount = count _helipads;
private _hangarCount = count _hangars;

//Find additional helipads and hangars (maybe a unified system would be better??)
{
  _markerX = _x;
  _markerSize = markerSize _x;
  _distance = sqrt ((_markerSize select 0) * (_markerSize select 0) + (_markerSize select 1) * (_markerSize select 1));
  _buildings = nearestObjects [getMarkerPos _x, ["Land_BludpadCircle", "Land_vn_b_helipad_01", "Helipad_Base_F", "Land_vn_helipad_base"], _distance, true];
  {
    if((getPos _x) inArea _markerX) then
    {
      _helipads pushBackUnique _x;
    };
  } forEach _buildings;
} forEach _heliMarker;

{
  _markerX = _x;
  _markerSize = markerSize _x;
  _distance = sqrt ((_markerSize select 0) * (_markerSize select 0) + (_markerSize select 1) * (_markerSize select 1));
  _buildings = nearestObjects [getMarkerPos _x, ["Land_Hangar_F", "Land_TentHangar_V1_F", "Land_Airport_01_hangar_F", "Land_Mil_hangar_EP1", "Land_Ss_hangar", "Land_Ss_hangard", "Land_vn_airport_01_hangar_f", "Land_vn_usaf_hangar_01", "Land_vn_usaf_hangar_02", "Land_vn_usaf_hangar_03"], _distance, true];
  {
    if((getPos _x) inArea _markerX) then
    {
      _hangars pushBackUnique _x;
    };
  } forEach _buildings;
} forEach _hangarMarker;
//All additional hangar and helipads found

if (_heliCount != count _helipads or _hangarCount != count _hangars) then {
  Debug_5("Marker %1 buildings diff: %2;%3 %4;%5", _marker, _heliCount, count _helipads, _hangarCount, count _hangars);
};

private ["_vehicleSpawns", "_size", "_width", "_height", "_vehicleCount", "_realLength", "_realSpace", "_markerDir", "_dis", "_pos", "_heliSpawns", "_dir", "_planeSpawns", "_vehSpawns", "_mortarSpawns", "_spawns"];

_vehicleSpawns = [];
{
    _markerX = _x;
    _size = getMarkerSize _x;
    _width = (_size select 0) * 2;
    _height = (_size select 1) * 2;
    if(_width < (4 + 2 * SPACING)) then
    {
      Error_2("InitSpawnPlaces: Marker %1 is not wide enough for vehicles, required are %2 meters!", _x , (4 + 2 * SPACING));
    }
    else
    {
      if(_height < 10) then
      {
        Error_1("InitSpawnPlaces: Marker %1 is not long enough for vehicles, required are 10 meters!", _x);
      }
      else
      {
        //Cleaning area
        private _radius = [0,0] vectorDistance [_width, _height];
        if (!isMultiplayer) then
        {
          {
            if((getPos _x) inArea _markerX) then
            {
              _x hideObject true;
            };
          } foreach (nearestTerrainObjects [getMarkerPos _markerX, ["Tree","Bush", "Hide", "Rock", "Fence"], _radius, true]);
        }
        else
        {
          {
            if((getPos _x) inArea _markerX) then
            {
              [_x,true] remoteExec ["hideObjectGlobal",2];
            }
          } foreach (nearestTerrainObjects [getMarkerPos _markerX, ["Tree","Bush", "Hide", "Rock", "Fence"], _radius, true]);
        };

        //Create the places
        _vehicleCount = floor ((_width - SPACING) / (4 + SPACING));
        _realLength = _vehicleCount * 4;
        _realSpace = (_width - _realLength) / (_vehicleCount + 1);
        _markerDir = markerDir _markerX;
        for "_i" from 1 to _vehicleCount do
        {
          _dis = (_realSpace + 2 + ((_i - 1) * (4 + _realSpace))) - (_width / 2);
          _pos = [getMarkerPos _markerX, _dis, (_markerDir + 90)] call BIS_fnc_relPos;
          _pos set [2, ((_pos select 2) + 0.1) max 0.1];
          _vehicleSpawns pushBack [_pos, _markerDir];
        };
      };
    };
} forEach _vehicleMarker;

_heliSpawns = [];
{
    _pos = getPos _x;
    _pos set [2, 0.4];
    if (!isMultiplayer) then
    {
      {
        _x hideObject true;
      } foreach (nearestTerrainObjects [_pos, ["Tree","Bush", "Hide", "Rock"], 5, true]);
    }
    else
    {
      {
        [_x,true] remoteExec ["hideObjectGlobal",2];
      } foreach (nearestTerrainObjects [_pos, ["Tree","Bush", "Hide", "Rock"], 5, true]);
    };
    _dir = direction _x;
    _heliSpawns pushBack [_pos, _dir];
} forEach _helipads;

_planeSpawns = [];
{
    _pos = getPos _x;
    _pos set [2, ((_pos select 2) + 0.1) max 0.1];
    _dir = direction _x;
    if(_x isKindOf "Land_Hangar_F" || {_x isKindOf "Land_Airport_01_hangar_F" || {_x isKindOf "Land_Mil_hangar_EP1" || {_x isKindOf "Land_Ss_hangar" || {_x isKindOf "Land_Ss_hangard" || {_x isKindOf "Land_vn_airport_01_hangar_f" || {_x isKindOf "Land_vn_usaf_hangar_01" || {_x isKindOf "Land_vn_usaf_hangar_02" || {_x isKindOf "Land_vn_usaf_hangar_03"}}}}}}}}) then
    {
      //This hangar is facing the wrong way...
      _dir = _dir + 180;
    };
    _planeSpawns pushBack [_pos, _dir];
} forEach _hangars;

{
  _planeSpawns pushBack [markerPos _x, markerDir _x];
} forEach _planeMarker;

{
    _pos = getPos _x;
    _dir = direction _x;

    if(_x isKindOf "land_bunker_garage") then {
      _pos = _pos vectorAdd [2, -6, 0];
    };

    // if (_x isKindOf "Land_GarageRow_01_large_F") then {
    //   _pos = _pos vectorAdd [8, -3.5, 0.3];
    //   _dir = _dir - 180;
    // };

    if (_x isKindOf "Land_Hangar_2") then {
      _pos = _pos vectorAdd [0,6, 0.3];
      _dir = _dir - 180;
    };

    _vehicleSpawns pushBack [_pos, _dir];
} forEach _garages;

_mortarSpawns = [];
{
  _pos = getMarkerPos _x;
  _pos set [2, ((_pos select 2) + 0.1) max 0.1];
  _mortarSpawns pushBack [_pos, 0];
} forEach _mortarMarker;

_samSpawns = [];
{
  _pos = getMarkerPos _x;
  _pos set [2, ((_pos select 2) + 0.1) max 0.1];
  _samSpawns pushBack [_pos, 0];
} forEach _samMarker;

_spawns = [_vehicleSpawns, _heliSpawns, _planeSpawns, _mortarSpawns, _samSpawns];

//Debug_2("%1 set to %2", _marker, [_vehicleSpawns, _heliSpawns, _planeSpawns, _mortarSpawns]);

//Create the spawn places and initial used-slot arrays
{
    if (_x#0 isEqualTo []) then { continue };
    private _varName = format ["%1_%2", _marker, _x#1];
    spawner setVariable [_varName + "_places", _x#0, true];
    spawner setVariable [_varName + "_used", (_x#0) apply {false}, true];
} forEach [[_vehicleSpawns, "vehicle"], [_heliSpawns, "heli"], [_planeSpawns, "plane"], [_mortarSpawns, "mortar"], [_samSpawns, "sam"]];