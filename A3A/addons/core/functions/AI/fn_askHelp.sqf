#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_target"];

private _helped = _unit getVariable ["helped", objNull];
if !(isNull _helped) exitWith { _helped };

// AIs don't ask for help if there's a downed player in the group
if (!isPlayer _target and {units _target findIf { isPlayer _x and {_x getVariable ["incapacitated", false]} } != -1}) exitWith { objNull };

// If the target is in a dangerous position and not a player, ignore them for the moment
private _enemy = _target findNearestEnemy _target;
if (!isPlayer _target and (_target distance _enemy < 100 or {[objNull, "VIEW"] checkVisibility [eyePos _enemy, eyePos _target] > 0})) exitWith { objNull };

private _firstAidKits = ["FirstAidKit","Medikit"] + (A3A_faction_reb get "firstAidKits") + (A3A_faction_reb get "mediKits");
private _unitNeedsFAK = count (_firstAidKits arrayIntersect items _target) == 0;

private _units = units group _target;
private _medics = _units select { [_x] call A3A_fnc_isMedic };
_units = _units - _medics;

private _fnc_canHelp = {
    params ["_unit"];
    if ((isPlayer _unit) or (vehicle _unit != _unit) or (_unit distance _target > 100)) exitWith { false };
    if !([_unit] call A3A_fnc_canFight) exitWith { false };
    if (currentCommand _unit == "STOP") exitWith { false };
    if ((_unit getVariable ["maneuvering", false]) or (_unit getVariable ["helping", false]) or (_unit getVariable ["rearming", false])) exitWith { false };
    if (!A3A_hasACEMedical and _unitNeedsFAK and {count (_firstAidKits arrayIntersect items _unit) == 0}) exitWith { false };
    true;
};

// Use available medics as priority
private _index = _medics findIf { _x call _fnc_canHelp };
if (_index != -1) exitWith {
    ServerDebug_2("Sending medic %1 to assist target %2", _medics select _index, _target);
    [_target, _medics select _index] spawn A3A_fnc_help;
    _medics select _index;
};

// Only medics will deal with non-incapped
if !(_target getVariable ["incapacitated", false]) exitWith { objNull };

private _index = _units findIf { _x call _fnc_canHelp };
if (_index != -1) exitWith {
    ServerDebug_2("Sending non-medic %1 to assist target %2", _units select _index, _target);
    [_target, _units select _index] spawn A3A_fnc_help;
    _units select _index;
};

objNull;
