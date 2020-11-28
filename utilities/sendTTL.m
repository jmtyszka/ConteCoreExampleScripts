%
%sends a TTL value
%
function sendTTL(TTLValue)

%32-bit windows, windows XP
% writeIOw('3BC', TTLValue);

%64 bit windows, 32bit matlab or 64bit matlab (call correct input_io io32
%or io64)

outp(888, TTLValue);