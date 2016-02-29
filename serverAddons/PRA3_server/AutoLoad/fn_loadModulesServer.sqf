#include "macros.hpp"
/*
	Project Reality ArmA 3 - Autoload\fn_loadModulesServer.sqf

	Author: NetFusion

	Description:
	Server side modules loader (used when AME is present on client too). Prepares the functions for transmission to clients. Should run before client register with server.

	Parameter(s):
	- ARRAY - server only: the names of the requested modules

	Returns:
	-

	Example:
	["Module1", "Module2"] call FNC(loadModulesServer);
*/


// Find all functions which are part of the requested modules and store them in an array.
GVAR(requiredFunctions) = [];
{
	// Extract the module name out of the full function name.
	// 1: Remove "AME_" prefix
	private _functionModuleName = _x select [4, count _x - 5];
	// 2: All characters until the next "_" are the module name.
	_functionModuleName = _functionModuleName select [0, _functionModuleName find "_"];

	// Push the function name on the array if its in the requested module list.
	if (_functionModuleName in _this) then {
		GVAR(requiredFunctions) pushBack _x;
	};
	true
} count GVAR(functionCache);

// EH for client registration. Starts transmission of function code.
if (isServer) then {
	QGVAR(registerClient) addPublicVariableEventHandler {

		// Determine client id by provided object (usually the player object).
		private _clientID = owner (_this select 1);

		{
			//@todo progress is not correct if we keep the server files server only
			//if (_x find "_fnc_serverInit" < 0) then {
			// Extract the code out of the function.
			private _functionCode = str (missionNamespace getVariable [_x, {}]);
			// Remove leading and trailing braces from the code.
			_functionCode = _functionCode select [1, count _functionCode - 2];

			// Transfer the function name, code and progress to the client.
			GVAR(receiveFunction) = [_x, _functionCode, _forEachIndex / (count GVAR(requiredFunctions) - 1)];
			_clientID publicVariableClient QGVAR(receiveFunction);
			//};
		} forEach GVAR(requiredFunctions);
	};
};

// Call all required function on the server.
call FNC(callModules);
