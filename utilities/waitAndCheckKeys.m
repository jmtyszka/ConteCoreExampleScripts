function [keys,RT,secs] = waitAndCheckKeys(h,waitDur,keySet,logTrigger,beepInterval)

start = GetSecs;
keys  = [];
RT    = [];
secs  = [];

if h.useCedrus
    % reset internal Cedrus timer
    CedrusResponseBox('ResetRTTimer', h.handle);
    % flush Cedrus buffer
    buttons = 1;
    while any(buttons(1,:))
        buttons = CedrusResponseBox('FlushEvents', h.handle);
    end
end
if nargin<3
    keySet = [];
end
if nargin<4
    logTrigger = 0;
end
if nargin<5
    beepInterval = inf;
end

if ~h.useCedrus
    keyList = zeros(1,256);
    keyList(keySet)=1;
    if h.mode==1 && logTrigger
        keyList(h.triggerKey) = 1;
    end
    KbQueueCreate([],keyList);
    KbQueueStart([]);
end

while GetSecs - start < waitDur,
    % check if any button has been pressed to abort experiment
    if h.useCedrus
        WaitSecs('Yieldsecs', 0.01); % wait 10ms with Cedrus Box 
        evt = CedrusResponseBox('GetButtons', h.handle);
        if ~isempty(evt)
            while ~isempty(evt)
                if ismember(evt.button,keySet),
                    if evt.action==1,
                        keys = [keys evt.button];
                        RT   = [RT evt.rawtime];
                        secs = [secs start+evt.rawtime];
                    end
                end
                evt = CedrusResponseBox('GetButtons', h.handle);
            end
        end
        if ~isempty(keys)
            break
        end
    else
        WaitSecs('Yieldsecs', 0.001); % wait 1ms with KbCheck
        [pressed, firstPress, firstRelease, lastPress, lastRelease] = ...
            KbQueueCheck([]);
        if pressed,
            % which keys were pressed?
            keys = find(firstPress>0);
            if logTrigger && ismember(h.triggerKey,keys),
                sendTTLsJD(h.TTL.keypress,0,h)
                keys = keys(~ismember(keys,h.triggerKey));
                firstPress(h.triggerKey) = 0;
            end
            if ~isempty(keys),
                secs = firstPress(firstPress>0);
                RT   = secs - start;
                KbQueueStop([]);
                break
            end
        end
    end
end

inputemu({...
    'key_normal','H\BACKSPACE'}');% Simulating keyboard input to prevent win going to sleep
