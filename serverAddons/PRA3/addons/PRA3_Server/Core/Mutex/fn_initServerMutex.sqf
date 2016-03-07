#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: NetFusion

    Description:
    -

    Parameter(s):
    -

    Returns:
    -
*/
// Variable which indicates if some client is currently executing
GVAR(mutexLock) = false;

// Queue of clients who requested mutex executing
GVAR(mutexQueue) = [];

// EH which fired if some client requests mutex executing
QGVAR(mutexToken) addPublicVariableEventHandler {
    // We enqueue the value in the queue
    GVAR(mutexQueue) pushBackUnique (_this select 1);
};

// We check on each frame if we can switch the mutex client
[{
    // Check if mutex lock is open and client in the queue
    if (!GVAR(mutexLock) && !(GVAR(mutexQueue) isEqualTo [])) then {
        // Lock the mutex
        GVAR(mutexLock) = true;
        // Tell the client that he can start and remove him from the queue
        (owner (GVAR(mutexQueue) deleteAt 0)) publicVariableClient QGVAR(mutexLock);
    };
}] call CFUNC(addPerFrameHandler);