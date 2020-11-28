function run_rest(debug)
% Simple resting state fixation cross with scan triggered eye tracking
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 2018-03-15 JMT Clone from PTB3 EyelinkExample.m
%          2018-03-27 JMT Harmonize with Julien's eyelink functions
%          2018-03-30 JMT Extract trigger wait and fixation cross to
%                         utilities
%          2018-07-24 JMT Add more status outputs
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

% Debug mode
if nargin < 1; debug = false; end  % Script debug mode

%% Parameters

% Task name for data output
taskName = 'rest';

% Key directories
userDir = char(java.lang.System.getProperty('user.home'));
dataDir = fullfile(userDir, 'Desktop', 'Data');

% Timing
if debug
    nTR = 10;
    TR = 0.7;
else
    nTR = 600;
    TR = 0.7;
end

% Total experiment duration in seconds, including 3 s tail
t_tot = nTR * TR + 3.0;

% Keyboard
KbName('UnifyKeyNames');
escKey = KbName('ESCAPE');
triggerKey = KbName('5%');

%% Get Subject ID
fprintf('-----------------------------------\n');
fprintf('Resting state with relaxed fixation\n');
fprintf('-----------------------------------\n\n');
subjectID = ptb_get_input_string('\nEnter subject ID: ');

%% Key filenames in Conte Core BIDS-ish style
edfLocalFile = conte_fname(dataDir, subjectID, taskName, 'gaze.edf');
edfHostFile = datestr(now, 'ddHHMMSS');

%% Ask user whether to use eyetracking
DoET = ptb_get_input_numeric('\nUse eyetracking? (0:no; 1:yes): ', [0, 1]);

%% Setup PTB
PsychDefaultSetup(2);

% Skip Sync Tests for dual display
Screen('Preference', 'SkipSyncTests', 1);

try
    
    fprintf('> Resting state with relaxed fixation\n');
    
    % Open a graphics window on the main screen
    % using the PsychToolbox's Screen function.
    screenNumber = max(Screen('Screens'));
    windowPtr = Screen('OpenWindow', screenNumber);
    
    % Initialize eyetracker
    if DoET
        fprintf('> Initializing Eyelink\n');
        DoET = ptb_eyelink_initialize(windowPtr, edfHostFile);
        fprintf('> Completed Eyelink initialization\n');
    end
    
    % Display the fixation cross
    fprintf('> Displaying fixation cross\n');
    conte_fixation_cross(windowPtr)
    
    % Wait for scan trigger
    fprintf('> Waiting for scan trigger ...\n');
    if conte_wait_trigger(triggerKey, escKey)
        t0 = GetSecs;
    else
        if DoET
            fprintf('> Shutting down Eyelink connect\n');
            Eyelink('EYELINK : Shutdown');
        end
        sca
        return
    end
    
    fprintf('> Trigger detected!\n');
    
    % Mark time origin in data file
    if DoET
        Eyelink('Message', 'SYNCTIME');
    end
    
    if debug
        
        fprintf('DEBUG MODE : Waiting 3 seconds\n');
        WaitSecs(3.0);
        
    else
        
        % Init continue flag
        keep_going = true;
        
        fprintf('> Starting resting state with fixation\n');

        while keep_going  % Loop until timeout or escape key pressed
            
            t = GetSecs;
            if t - t0 > t_tot
                fprintf('> Normal end of fixation\n')
                if DoET
                    Eyelink('Message', 'END OF FIXATION');
                end
                keep_going = false;
            end

            % Check for key press
            [~, ~, keyCode] = KbCheck;

            % Exit is stop key was pressed
            if keyCode(escKey)
                fprintf('> Escape key pressed\n')
                if DoET
                    Eyelink('Message', 'ESCAPE PRESSED');
                end
                keep_going = false;
            end

        end % Main loop
        
    end

    fprintf('> Normal end of experiment\n')
    if DoET
        Eyelink('Message', 'END OF EXPERIMENT');
    end
    
    if DoET
        fprintf('> Saving Eyelink data and closing down\n');
        ptb_eyelink_cleanup(edfHostFile, edfLocalFile);
    end
    sca;
    
    fprintf('> Clean exit\n');
    
catch
    
    % Safe cleanup on exception
    if DoET
        fprintf('> Saving Eyelink data and closing down\n');
        ptb_eyelink_cleanup(edfHostFile, edfLocalFile);
    end
    sca;
    psychrethrow(psychlasterror);

end