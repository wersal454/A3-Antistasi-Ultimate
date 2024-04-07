//	Author: Socrates
// 
//	Description:
//	Creates Singular burning debris effect.
//
//	Returns:
//	Nothing
//
// 	How to use: 
// 	[_position, _lifeTime] remoteExec ["SCRT_fnc_effect_createBurningDebrisEffect",0];
//

params ["_position", "_lifeTime"];

if (!hasInterface) exitWith {};

private _shape = selectRandom [
    "\A3\data_f\ParticleEffects\Shard\shard.p3d", 
    "\A3\data_f\ParticleEffects\Shard\shard2.p3d", 
    "\A3\data_f\ParticleEffects\Shard\shard3.p3d", 
    "\A3\data_f\ParticleEffects\Shard\shard4.p3d"
];

private _fakeObject = "Land_HelipadEmpty_F" createVehicleLocal _position;

_effectEmitter = "#particlesource" createVehicleLocal position _fakeObject;
_effectEmitter setParticleClass "ObjectDestructionShardsBurning"; 
_effectEmitter setParticleCircle [0, [0, 0, 0]];
_effectEmitter setParticleParams [ 
    ["\A3\data_f\ParticleEffects\Shard\shard.p3d",1,0,1,0], 
    "", 
    "spaceObject", 
    1, 
    _lifeTime, 
    [0,0,0], 
    [0,6,0], 
    3,40,7.9,0.05, 
    [1,1,1,0], 
    [[1,1,1,1],[1,1,1,1]], 
    [1,1], 
    0.01, 
    0.08, 
    "", 
    "", 
    _fakeObject, 
    0, 
    true, 
    0.03, 
    [[0,0,0,0]] 
]; 

_effectEmitter setParticleRandom [0.5, [1, 1, 0.4], [0, 0, 4], 0, 0.5, [0, 0, 0, 0], 0, 0];
_effectEmitter setDropInterval 1;

sleep 2;
deleteVehicle _effectEmitter;
deleteVehicle _fakeObject;
