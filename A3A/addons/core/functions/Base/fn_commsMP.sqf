if (!hasInterface) exitWith {};
if (isNil "teamPlayer") exitWith {};
if (!(side player in [teamPlayer,civilian])) exitWith {};

params [["_unit", objNull], ["_typeX", ""], ["_textX", ""], ["_titleX", ""]];

switch (_typeX) do {
	case "sideChat": {
		_unit sideChat format ["%1", _textX];
	};
	case "hint": {
		[_titleX, format ["%1",_textX]] call A3A_fnc_customHint;
	};
	case "hintS": {
		[_titleX, format ["%1",_textX], true] call A3A_fnc_customHint;
	};
	case "intelError": {
		[_titleX, format [localize "STR_A3A_Base_commsMp_download_error",_textX]] call A3A_fnc_customHint;
	};
	case "globalChat": {
		_unit globalChat format ["%1", _textX];
	};
	case "countdown": {
		_textX = format [localize "STR_A3A_Base_commsMp_countdown_desc",_textX];
		[localize "STR_A3A_Base_commsMp_countdown_header", format ["%1",_textX]] call A3A_fnc_customHint;
	};
	case "income": {
		waitUntil {sleep 0.2; !incomeRep};
		private _layer = ["A3A_infoRight"] call BIS_fnc_rscLayer;
		incomeRep = true;
		playSound "A3AP_UiSuccess";
		[_textX, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], 0.5, 5, 0, 0, _layer] spawn bis_fnc_dynamicText;
		incomeRep = false;
		[] spawn A3A_fnc_statistics;
	};
	case "taxRep": {
		private _layer = ["A3A_infoRight"] call BIS_fnc_rscLayer;
		incomeRep = true;
		playSound "A3AP_UiSuccess";
		[_textX, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], 0.5, 5, 0, 0, _layer] spawn bis_fnc_dynamicText;
		sleep 10;
		incomeRep = false;
		[] spawn A3A_fnc_statistics;
	};
	case "tier": {
		waitUntil {sleep 0.2; !incomeRep};
		private _layer = ["A3A_infoRight"] call BIS_fnc_rscLayer;
		incomeRep = true;
		playSound "A3AP_UiSuccess";
		_textX = format ["War Level Changed<br/><br/>Current Level: %1",tierWar];
		[_textX, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], 0.5, 5, 0, 0, _layer] spawn bis_fnc_dynamicText;
		incomeRep = false;
		[] spawn A3A_fnc_statistics;
	};
	case "support": {
		private _layer = ["A3A_infoDown"] call BIS_fnc_rscLayer;
		[_textX, [safeZoneX + (0.65 * safeZoneW), (0.2 * safeZoneW)], 0.65, 8, 0, 0, _layer] spawn BIS_fnc_dynamicText;
		playSound "A3AP_UiSuccess";
		[] spawn A3A_fnc_statistics;
	};
	case "announce": {
		private _layer = ["A3A_infoDown"] call BIS_fnc_rscLayer;
		[_textX, [safeZoneX + (0.65 * safeZoneW), (0.2 * safeZoneW)], 0.45, 8, 0, 0, _layer] spawn BIS_fnc_dynamicText;
		playSound "A3AP_UiSuccess";
	};
	case "unlock": {
		private _layer = ["A3A_infoUnlock"] call BIS_fnc_rscLayer;
		switch (tierWar) do {
			case (3): {
				_textX = localize "STR_A3A_Base_commsMp_unlock_tier_general";
				if (player == theBoss) then {
					_textX = _textX + localize "STR_A3A_Base_commsMp_unlock_tier3_theBoss";
				};
			};

			case (4): {
				_textX = localize "STR_A3A_Base_commsMp_unlock_tier_general";
				if (player == theBoss) then {
					_textX = _textX + localize "STR_A3A_Base_commsMp_unlock_tier4_theBoss";
				};
			};

			case (5): {
				_textX = localize "STR_A3A_Base_commsMp_unlock_tier_general";
				if (player == theBoss) then {
					_textX = _textX + localize "STR_A3A_Base_commsMp_unlock_tier5_theBoss";
				};
			};
		};

		if (!isSupportAnnounced) then {
			private _outposts = {sidesX getVariable [_x,sideUnknown] == teamPlayer} count outposts;
			if(_outposts > 4 && {player == theBoss}) then {
				_textX = _textX + localize "STR_A3A_Base_commsMp_unlock_support_points";
				isSupportAnnounced = true;
				publicVariable "isSupportAnnounced";
			};
		};

		if(tierWar > 3 && {!isPowPaycheckAnnounced}) then {
			_textX = _textX + format [localize "STR_A3A_Base_commsMp_idap", A3A_faction_reb get "name", A3A_faction_occ get "name"];
			isPowPaycheckAnnounced = true; 
			publicVariable "isPowPaycheckAnnounced";
		};

		[_textX, [safeZoneX + (0.55 * safeZoneW), (0.2 * safeZoneW)], 0.45, 8, 0, 0, _layer] spawn BIS_fnc_dynamicText;
	};
};
