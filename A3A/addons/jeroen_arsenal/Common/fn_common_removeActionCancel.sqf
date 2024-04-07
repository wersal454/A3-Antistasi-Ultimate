#include "defineCommon.inc"

params["_object",["_text",""]];

private _id = _object getVariable "jn_cancelAction_id";

if(isnil "_id")exitWith{};
_object removeAction _id;