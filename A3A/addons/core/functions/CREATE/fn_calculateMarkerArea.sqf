params ["_marker"];

private _result = 0;
private _size = getMarkerSize _marker;

switch (markerShape _marker) do {
    case "ELLIPSE": {
      _result = PI * (_size select 0) * (_size select 1);
    };
    case "ELLIPSE": {
      _result = (_size select 0) * (_size select 1) * 4;
    };
};

_result;
