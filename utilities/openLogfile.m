function [fid,fname,timestampStr] = openLogfile(label, outDir)
% Open a text log file for psychophysics experiments
%
% AUTHOR : Julien Dubois
% urut/april15 added argument for path
% 2018-03-27 JMT Switched to ISO 8601 timestamp

if nargin < 2
    outDir='c:\experiments\logs\';
end

% ISO 8601 format timestamp
timestampStr = datestr(now, 30);

% Log filename stub
fname = fullfile(outDir, [label timestampStr]);
fid = fopen([fname, '_events.txt'],'w+');