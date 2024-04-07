params ["_man", "_sightHeight"];

while {sleep 1; alive _man} do { 
    { 
        private _relPos = _man getRelPos [700, _x];
        _man lookAt [_relPos select 0, _relPos select 1, _sightHeight]; 
        sleep random [2.5, 4, 5]; 
    } forEach [0, 90, 180, 270]; 
};