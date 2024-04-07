params ["_vehicle", "_action"];

switch (_action) do {
    case "load":{
        private _loadActionID = _vehicle getVariable ["loadActionID", nil];
        if(!isnil "_loadActionID")then{
            _vehicle removeAction _loadActionID;
            _vehicle setVariable ["loadActionID", nil];
        };
    };
    case "unload": {
        private _unloadActionID = _vehicle getVariable ["unloadActionID", nil];
        if(!isnil "_unloadActionID")then{
            _vehicle removeAction _unloadActionID;
            _vehicle setVariable ["unloadActionID", nil];
        };
    };
};