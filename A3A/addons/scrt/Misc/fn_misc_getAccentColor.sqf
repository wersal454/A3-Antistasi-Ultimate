params [["_isHex", false]];

private _accentColorRgba = [
	(profilenamespace getvariable ['GUI_BCG_RGB_R',0.376]),
	(profilenamespace getvariable ['GUI_BCG_RGB_G',0.125]),
	(profilenamespace getvariable ['GUI_BCG_RGB_B',0.043]),
	1
];

if (_isHex) then {
    _accentColorRgba = _accentColorRgba call BIS_fnc_colorRGBAtoHTML;
};

_accentColorRgba