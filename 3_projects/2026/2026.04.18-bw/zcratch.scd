// This will tell us if 9001 is free or busy
(
try { 
    n = OSCFunc({ |msg| msg.postln }, '/test', recvPort: 8000); 
    "Port 9001 is OPEN and working".postln;
    n.free;
} { 
    "Port 9001 is BLOCKED by another app".postln; 
};
)
OSCFunc.trace(false);
