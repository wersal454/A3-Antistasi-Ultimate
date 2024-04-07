#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_group", "_vehicle", "_preference"];

/*  Checks if the given group matches the given vehicle and preference
*   Params:
*     _group : ARRAY of STRINGS : The typenames of the units in the group
*     _vehicle : STRING : The vehicle typename of the group
*     _preference : STRING : The preferred group type
*
*   Returns:
*     _result : BOOLEAN : True if group matches preference and vehicle, false otherwise
*/

private ["_result", "_vehicleSeats"];
_result = false;

private _occGroupData = FactionGet(occ, "groups");
private _invGroupData = FactionGet(occ, "groups");

//Tanks are always combined with an AT team
if(_vehicle == "LAND_TANK") exitWith {
  private _occGroup = [(FactionGet(occ,"groupTierAT"))] call SCRT_fnc_unit_getTiered;
  private _invGroup = [(FactionGet(inv,"groupTierAT"))] call SCRT_fnc_unit_getTiered;
  _group == _occGroup || {_group == _invGroup}
};

//AA is always combined with an AA team
if(_vehicle == "LAND_AIR") exitWith {
  private _occGroup = [(FactionGet(occ,"groupTierAA"))] call SCRT_fnc_unit_getTiered;
  private _invGroup = [(FactionGet(inv,"groupTierAA"))] call SCRT_fnc_unit_getTiered;
  _group == _occGroup || {_group == _invGroup}
};

//Check group size to determine
if(_preference == "SQUAD") then
{
  _result = (count _group == 8);
};
if(_preference == "GROUP") then
{
  _result = (count _group == 4);
};

//Check if vehicle can hold group
_vehicleSeats = ([_vehicle, true] call BIS_fnc_crewCount) - ([_vehicle, false] call BIS_fnc_crewCount);
_result = (_result && (count _group <= _vehicleSeats));

_result;
