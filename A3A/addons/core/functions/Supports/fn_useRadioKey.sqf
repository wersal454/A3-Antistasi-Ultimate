/*
    Spend a radio key (if available) to boost reveal value

Scope: Server
Arguments:
    <SIDE> The side (occupants or invaders) which should send the support.
    <POS> Target position of support/attack/whatever.
    <NUMBER> How much information to reveal about support, 0 low 1 high.

Returns:
    <NUMBER> Modified reveal value
*/

params ["_side", "_position", "_reveal"];

// Don't waste a key if we already have max info
if (_reveal >= 0.8) exitWith { _reveal };

if(_position distance2D markerPos "Synd_HQ" < distanceMission) then
{
    if(_side == Occupants && occupantsRadioKeys > 0) then {
        occupantsRadioKeys = occupantsRadioKeys - 1;
        _reveal = 1;
    };
    if(_side == Invaders && invaderRadioKeys > 0) then {
        invaderRadioKeys = invaderRadioKeys - 1;
        _reveal = 1;
    };
};

_reveal;
