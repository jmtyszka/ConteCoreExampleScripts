function sendTTLsJD(TTLcode,addinfo,h,skipTTL)
if nargin<4
    skipTTL = false;
end

if h.mode==2 && ~skipTTL
    sendTTL(TTLcode);
end
if h.eyeLinkMode
    Eyelink('Message', ['TTL=' num2str(TTLcode)]);
end

if ~iscell(addinfo)
    infoStr = num2str(addinfo(1));
    for i = 2:length(addinfo),
        infoStr = [infoStr,',',num2str(addinfo(i))];
    end
else
    infoStr = addinfo{1};
    for i = 2:length(addinfo),
        infoStr = [infoStr,',',addinfo{i}];
    end
end
writeLog(h.fidLog, TTLcode,infoStr);

