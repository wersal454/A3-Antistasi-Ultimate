if (!hasInterface) exitWith {};
if (!playerIcons) exitWith {};

addMissionEventHandler [
	"Draw3D",
	{
		private _players = (call BIS_fnc_listPlayers - [player]) select {
			alive _x && {side player getFriend side _x > 0.5 && {(lifeState _x) isEqualTo "INCAPACITATED"}}
		};

		{
			//mark wounded friendly players
			private _distance = player distance _x;

			if (_distance > 100) then {
				continue;
			};

			private _position = getPosATLVisual _x;
			_position set [2, (_position select 2) + 1 + (_distance * 0.05)];

			drawIcon3D [
				"a3\ui_f\data\igui\cfg\revive\overlayiconsgroup\u100_ca.paa",
				[1,0,0,1 - (_distance / 100)], 
				_position, 
				1, 
				1, 
				0, 
				[(localize "STR_antistasi_actions_draw3d_unconscious_text"), name _x] joinString " ", 
				1, 
				0.04 - (_distance / 9000), 
				"PuristaMedium"
			];
		} forEach _players;
	}
];

