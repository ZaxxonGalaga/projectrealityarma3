#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: BadGuy

    Description:
    Performs a respawn after 5 seconds

    Parameter(s):
    0: Old Vehicle <Object>
    1: Vehicle Type <String>
    2: Object variable names <Array of Strings>
    3: Object variable valuess <Array of Any>

    Returns:
    None
*/

params ["_vehicle", "_type", "_varNames", "_varValues"];

if (!isNull _vehicle) then {
    deleteVehicle _vehicle;
};

[{
    params ["_type", "_varNames", "_varValues"];

    private _respawnCounter = 0;
    if ((toLower QGVAR(RespawnCounter)) in _varNames) then {
        _respawnCounter = _varValues select (_varNames find toLower QGVAR(RespawnCounter));
    };

    private _paramsString = "params [""_respawnCounter""];";

    private _condition = compile (_paramsString + (_varValues select (_varNames find toLower QGVAR(condition))));

    [{
        (_this select 1) params ["_type", "_varNames", "_varValues"];
        private _position = (_varValues select (_varNames find toLower QGVAR(RespawnPosition)));
        _position = [_position, 10, _type] call CFUNC(findSavePosition);
        private _vehicle = _type createVehicle _position;
        _vehicle setDir (_varValues select (_varNames find toLower QGVAR(RespawnDirection)));

        {
            _vehicle setVariable [_x, _varValues select _forEachIndex];
        } forEach _varNames;

        GVAR(VehicleRespawnAllVehicles) pushBack _vehicle;

        private _side = _vehicle getVariable [QGVAR(side),sideUnknown];

        [QGVAR(vehicleRespawnAvailable), _side, _vehicle] call CFUNC(targetEvent);

    }, _condition, [_respawnCounter, _this]] call CFUNC(waitUntil);
}, 3, [_type, _varNames, _varValues]] call CFUNC(wait);