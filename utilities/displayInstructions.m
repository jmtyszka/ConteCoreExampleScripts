function h = displayInstructions(h,ind)

if nargin<2
    ind = 1;
end
Screen('DrawTexture', h.window,  h.instr(ind),[],h.instrRect);
Screen(h.window, 'Flip', 0);

sendTTLsJD(h.TTL.startInstr(ind),0,h);
% wait for keypress (1)
[key,RT] = waitAndCheckKeys(h,inf,[h.key1 h.escKey],0);
sendTTLsJD(h.TTL.keypress,[key,RT],h)
if key == h.escKey
    h.endSignal = 1;
end
