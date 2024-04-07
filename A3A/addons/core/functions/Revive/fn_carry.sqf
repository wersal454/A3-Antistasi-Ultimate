params ["_carry", "_carrier"];

if (!alive _carry) exitWith {
	[localize  "STR_A3A_revive_carry_header", format [localize "STR_A3A_revive_carry_dead",name _carry]] call A3A_fnc_customHint;
};

if !(_carry getVariable ["incapacitated",false]) exitWith {
	[localize  "STR_A3A_revive_carry_header", format [localize "STR_A3A_revive_no_longer_need_help",name _carry]] call A3A_fnc_customHint;
};

if !(isNull attachedTo _carry) exitWith {
	[localize  "STR_A3A_revive_carry_header", format [localize "STR_A3A_revive_transported",name _carry]] call A3A_fnc_customHint;
};

if (captive _carrier) then {
	_carrier setCaptive false
};

_carrier playMoveNow "AcinPknlMstpSrasWrflDnon";
[_carry,"AinjPpneMrunSnonWnonDb"] remoteExec ["switchMove",_carry];
_carry setVariable ["helped",_carrier,true];
[_carry,"remove"] remoteExec ["A3A_fnc_flagaction",0,_carry];
_carry attachTo [_carrier, [0,1.1,0.092]];
_carry setDir 180;
_timeOut = time + 60;
_action = _carrier addAction [format [(localize "STR_antistasi_actions_release_carry"),name _carry], {{detach _x} forEach (attachedObjects player)},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"];

waitUntil {
	sleep 0.5; 
	(!alive _carry) or 
	!([_carrier] call A3A_fnc_canFight) or 
	!(_carry getVariable ["incapacitated",false]) or 
	({!isNull _x} count attachedObjects _carrier == 0) or 
	(time > _timeOut) or 
	(vehicle _carrier != _carrier)
};

[] call SCRT_fnc_misc_updateRichPresence;

_carrier removeAction _action;
if (count attachedObjects _carrier != 0) then {detach _carry};
_carrier playMove "amovpknlmstpsraswrfldnon";
[_carry,"UnconsciousReviveDefault"] remoteExec ["switchMove",_carry];
[_carry,"heal1"] remoteExec ["A3A_fnc_flagaction",0,_carry];
sleep 5;
_carry setVariable ["helped",objNull,true];
