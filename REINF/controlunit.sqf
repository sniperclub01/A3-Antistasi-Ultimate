private ["_units","_unit"];

_units = _this select 0;

_unit = _units select 0;

if (_unit == Petros) exitWith {hint "You cannot control Petros";};
//if (captive player) exitWith {hint "You cannot control AI while on Undercover"};
if (player != leader group player) exitWith {hint "You cannot control AI if you are not the squad leader"};
if (isPlayer _unit) exitWith {hint "You cannot control another player"};
if (!alive _unit) exitWith {hint "You cannot control a dead unit"};
if (lifeState _unit == "INCAPACITATED") exitWith {hint "You cannot control an unconscious unit"};
if (captive _unit) exitWith {hint "You cannot control an Undercover unit"};
//if ((not(typeOf _unit in soldadosSDK)) and (typeOf _unit != "b_g_survivor_F")) exitWith {hint "You cannot control a unit which does not belong to FIA"};
if (side _unit != buenos) exitWith {hint "You cannot control a unit which does not belong to Syndikat"};


_owner = player getVariable ["owner",player];
if (_owner!=player) exitWith {hint "You cannot control AI while you are controlling another AI"};

{
if (_x != vehicle _x) then
	{
	[_x] orderGetIn true;
	};
} forEach units group player;

_unit setVariable ["owner",player];
selectPlayer _unit;

_tiempo = 60;

_unit addAction ["Return Control to AI",{selectPlayer leader (group (_this select 0))}];

waitUntil {sleep 1; hint format ["Time to return control to AI: %1", _tiempo]; _tiempo = _tiempo - 1; (_tiempo == -1) or (isPlayer (leader group player))};

removeAllActions _unit;
selectPlayer (_unit getVariable ["owner",_unit]);
//_unit setVariable ["owner",nil,true];
{[_x] joinsilent group player} forEach units group player;
group player selectLeader player;
hint "";

