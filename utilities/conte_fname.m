function fname = conte_fname(dataDir, subjectID, taskName, fileSuffix)
% Create timestamped BIDS-like filename with containing directory
%
% RETURNS: <dataDir>/sub-<subjectID>/...
%   sub-<subjectID>_task-<taskName>_acq-<ISO 8601 Timestamp>_<fileSuffix>
%
% fileSuffix should be in the form <suffix.ext>, eg 'gaze.edf'
%
% AUTHOR : Mike Tyszka
% DATES  : 2018-03-26 JMT Generalize for all file types
%          2018-03-27 JMT Combine suffix and extension
%
% % Copyright 2018 California Institute of Technology
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

% Safely create output data directory
subDataDir = fullfile(dataDir, ['sub-' subjectID]);
if ~exist(subDataDir, 'dir')
    fprintf('Creating subject data directory : %s\n', subDataDir);
    mkdir(subDataDir);
end

% Conte Core BIDS-ish output filename
tstamp = datestr(now, 30);  % ISO 8601 format timestamp
fname = fullfile(subDataDir, ...
    sprintf('sub-%s_task-%s_acq-%s_%s', ...
    subjectID, taskName, tstamp, fileSuffix));