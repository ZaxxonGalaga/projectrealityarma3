#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: joko // Jonas

    Description:
    Attach Object to Player and let him drag it

    Parameter(s):
    0: Object that the Unit will Drag <Object>
    1: Player that Drag the Object <Object>

    Returns:
    None
*/

#define __DRAGANIMSTATE ["amovpercmstpslowwrfldnon_acinpknlmwlkslowwrfldb_2", "amovpercmstpsraswpstdnon_acinpknlmwlksnonwpstdb_2", "amovpercmstpsnonwnondnon_acinpknlmwlksnonwnondb_2", "acinpknlmstpsraswrfldnon", "acinpknlmstpsnonwpstdnon", "acinpknlmstpsnonwnondnon"]
#define __MAXWEIGHT 800

params ["_draggedObject", "_unit"];
private _currentWeight = _draggedObject call FUNC(getWeight);
if (_currentWeight >= __MAXWEIGHT) exitWith {
    hint format["The box is %1 KG to heavy", _currentWeight - __MAXWEIGHT];
};

if (_draggedObject isKindOf "StaticWeapon") then {
    private _gunner = gunner _draggedObject;
    if (!isNull _gunner && alive _gunner) then {
        private _gunner setPosASL getPosASL _gunner;
    };
};
private _attachPoint = [0,0,0];
_unit setVariable [QGVAR(Item), _draggedObject, true];
_draggedObject setVariable [QGVAR(Player), _unit, true];
if (_draggedObject isKindOf "StaticWeapon" || _currentWeight >= __MAXWEIGHT /2) then {
    _unit playActionNow "grabDrag";
    //waitUntil {animationState _unit in __DRAGANIMSTATE};
    _attachPoint = [0, 1.3, ((_draggedObject modelToWorld [0,0,0]) select 2) - ((_unit modelToWorld [0,0,0]) select 2)];
} else {
    _unit action ["WeaponOnBack",_unit];
    _attachPoint = [0, 1.3, ((_draggedObject modelToWorld [0,0,0]) select 2) - ((_unit modelToWorld [0,0,0]) select 2) + 0.5];
    _unit forceWalk true;
};
_draggedObject attachTo [_unit, _attachPoint];

// TODO replace with PFH

GVAR(GetInVehiclePFH) = [{
    if (_unit == vehicle _unit) exitWith {};
    private _draggedObject = _unit getVariable [QGVAR(Item), objNull];
    detach _draggedObject;
    if (isNull _draggedObject) exitWith {};
    _unit setVariable [QGVAR(Item), objNull, true];
    _draggedObject setVariable [QGVAR(Player), objNull, true];
    detach _draggedObject;
    _unit forceWalk false;
    _draggedObject setDamage 0;
    [[_draggedObject, true], "enableSimulationGlobal", false, false, true] call BIS_fnc_MP;
    private _position = getPosATL _draggedObject;
    if (_position select 2 < 0) then {
        _position set [2, 0];
        _draggedObject setPosATL _position;
   };
    [GVAR(GetInVehiclePFH)] call CFUNC(removePerFrameHandler);
}] call CFUNC(addPerFrameHandler);
