params ["_markerX"];


private _size = 0;
private _area = markerSize _markerX;

_size = _area select 0;
if (_size < _area select 1) then {_size = _area select 1};


_size