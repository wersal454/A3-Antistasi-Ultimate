/*  Initiates the prefered garrison types and size
*   Params:
*     Nothing
*
*   Returns:
*     Nothing
*/

//Setting up airport preferences
private _preference =
[
  ["LAND_AIR", -1, "AA"],
  ["LAND_APC", -1, "SQUAD"],
  ["LAND_START", -1, "SQUAD"],
  ["LAND_LIGHT", 0, "EMPTY"],       //Empty light vehicle
  ["HELI_LIGHT", -1, "GROUP"],
  ["HELI_LIGHT", -1, "GROUP"],
  ["HELI_LIGHT", 0, "EMPTY"],       //Empty helicopter
  ["AIR_DRONE", -1, "EMPTY"],
  ["AIR_DRONE", 0, "EMPTY"]         //Empty plane
];

garrison setVariable ["Airport_preference", _preference];
garrison setVariable ["Airport_statics", 0.35];

//Setting up airport preferences
_preference =
[
  ["LAND_START", -1, "SQUAD"],
  ["LAND_START", -1, "SQUAD"],
  ["LAND_APC", -1, "SQUAD"],
  ["LAND_APC", 0, "EMPTY"],
  ["LAND_TANK", -1, "SQUAD"],
  ["LAND_TANK", 0, "EMPTY"],
  ["LAND_LIGHT", 0, "EMPTY"],
  ["HELI_LIGHT", -1, "GROUP"]  
];

garrison setVariable ["MilitaryBase_preference", _preference];
garrison setVariable ["MilitaryBase_statics", 0.3];

//Setting up outpost preferences
_preference =
[
  ["LAND_START", -1, "SQUAD"],
  ["LAND_START", -1, "SQUAD"],
  ["LAND_LIGHT", 0, "EMPTY"],       //Empty light vehicle
  ["HELI_LIGHT", -1, "GROUP"],
  ["HELI_LIGHT", 0, "EMPTY"]        //Empty helicopter
];

garrison setVariable ["Outpost_preference", _preference];
garrison setVariable ["Outpost_statics", 0.2];

//Setting up city preferences
_preference =
[
  //No units in cities at start
];
garrison setVariable ["City_preference", _preference];
garrison setVariable ["City_statics", 0];

//Setting up other preferences
_preference =
[
  ["LAND_START", -1, "SQUAD"],
  ["LAND_START", -1, "SQUAD"],
  ["LAND_LIGHT", 0, "EMPTY"]      //Empty light vehicle
];

garrison setVariable ["Other_preference", _preference];
garrison setVariable ["Other_statics", 0];
