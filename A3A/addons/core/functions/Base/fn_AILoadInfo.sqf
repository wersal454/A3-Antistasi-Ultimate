if (!isServer) exitWith {};
if (count hcArray == 0) exitWith {
	[petros,"hint",localize "STR_A3A_Base_AI_Load_Information_no_hc",localize "STR_A3A_Base_AI_Load_Information"] remoteExec ["A3A_fnc_commsMP",remoteExecutedOwner]
};

private _textX = "";

for "_i" from 0 to (count hcArray) - 1 do {
	_textX = format ["%1HC %2 AI<br/><br/>",_textX, _i];
	_west = 0;
	_east = 0;
	_indep = 0;
	_civ = 0;
	_total = 0;
	_client = hcArray select _i;
	{
	if (owner _x == _client) then
		{
		_total = _total + 1;
		switch (side _x) do
			{
			case teamPlayer: {_indep = _indep + 1};
			case Occupants: {_west = _west + 1};
			case Invaders: {_east = _east + 1};
			case civilian: {_civ = _civ + 1};
			};
		};
	} forEach allUnits select {alive _x};
	_textX = format [localize "STR_A3A_Base_AI_Info_String",_textX,_indep,_west,_east,_civ,_total];
};

[petros, "hint", _textX, localize "STR_A3A_Base_AI_Load_Information"] remoteExec ["A3A_fnc_commsMP",remoteExecutedOwner];
