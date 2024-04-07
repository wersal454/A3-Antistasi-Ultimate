

if (!musicON) exitWith {
	1 fadeMusic 0.5; playMusic ""
};

if (isNil "EHMusic") then {
	playMusic selectRandom ["LeadTrack01_F", "LeadTrack01a_F", "LeadTrack01b_F", "LeadTrack02_F", "AmbientTrack03_F", "BackgroundTrack01_F", "BackgroundTrack01a_F", "Track02_SolarPower"];
	EHMusic = addMusicEventHandler ["MusicStop", {
		if (!musicOn) exitWith {};

		private _song = "";
		private _behaviour = behaviour player;

		switch (true) do {
			case (_behaviour isEqualTo "COMBAT"): {
				_song = selectRandom (["LeadTrack03_F", "LeadTrack04_F", "LeadTrack04a_F", "LeadTrack05_F", "BackgroundTrack03_F", "Track01_Proteus", "Track07_ActionDark","Track10_StageB_action"] - [_this select 0]);
			};
			case (_behaviour isEqualTo "STEALTH"): {
				_song = selectRandom (["LeadTrack06_F", "AmbientTrack01_F", "AmbientTrack01a_F", "AmbientTrack01b_F", "AmbientTrack04a_F", "AmbientTrack04_F", "Track04_Underwater1","Track05_Underwater2"] - [_this select 0]);
			};
			case ((daytime > 18) || (daytime < 6)): {
				_song = selectRandom (["Track08_Night_ambient", "Track09_Night_percussions","Track11_StageB_stealth"] - [_this select 0]);
			};
			default {
				_song = selectRandom (["LeadTrack01_F", "LeadTrack01a_F", "LeadTrack01b_F", "LeadTrack02_F", "AmbientTrack03_F", "BackgroundTrack01_F", "BackgroundTrack01a_F", "Track02_SolarPower"] - [_this select 0]);
			};
		};

		1 fadeMusic 0.5;
		playmusic _song;

	}];
} else {
	private _song = "";
	private _behaviour = behaviour player;
	switch (true) do {
		case (_behaviour isEqualTo "COMBAT"): {
			_song = selectRandom (["LeadTrack03_F", "LeadTrack04_F", "LeadTrack04a_F", "LeadTrack05_F", "BackgroundTrack03_F", "Track01_Proteus", "Track07_ActionDark","Track10_StageB_action"] - [_this select 0]);
		};
		case (_behaviour isEqualTo "STEALTH"): {
			_song = selectRandom (["LeadTrack06_F", "AmbientTrack01_F", "AmbientTrack01a_F", "AmbientTrack01b_F", "AmbientTrack04a_F", "AmbientTrack04_F", "Track04_Underwater1","Track05_Underwater2"] - [_this select 0]);
		};
		case ((daytime > 18) || (daytime < 6)): {
			_song = selectRandom (["Track08_Night_ambient", "Track09_Night_percussions","Track11_StageB_stealth"] - [_this select 0]);
		};
		default {
			_song = selectRandom (["LeadTrack01_F", "LeadTrack01a_F", "LeadTrack01b_F", "LeadTrack02_F", "AmbientTrack03_F", "BackgroundTrack01_F", "BackgroundTrack01a_F", "Track02_SolarPower"] - [_this select 0]);
		};
	};
	1 fadeMusic 0.5;
	playmusic _song;
};