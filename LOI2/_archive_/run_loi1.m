function run_loi1(subjectID,inputDevice,w)
try
KbName('UnifyKeyNames');

%% Paths %%
basedir = pwd;
datadir = fullfile(basedir, 'data');
screendir = fullfile(basedir, 'stimuli');
stimdir = fullfile(basedir, 'stimuli/loi1');
designdir = fullfile(basedir, 'designs');
utilitydir = fullfile(basedir, 'utilities');
addpath(utilitydir)

%% Text %%
theFont='Arial';    % default font
theFontSize=42;     % default font size
theFontSize2=46;
fontwrap=42;        % default font wrapping (arg to DrawFormattedText)

%% Timing %%
maxDur = 1.25;
maxRepDur = .75;
ISI = .15;
% firstISI = .15;
% nTrialsBlock = 8;

%% Response Keys %%
trigger = KbName('5%');
valid_keys = {'1!' '2@' '3#' '4$' 'ESCAPE'};

% ====================
% END DEFAULTS
% ====================

%% Print Title %%
script_name='-- Image Observation Test --'; boxTop(1:length(script_name))='=';
fprintf('%s\n%s\n%s\n',boxTop,script_name,boxTop)

if nargin==0

    %% Get Subject ID %%
    subjectID = ptb_get_input_string('\nEnter subject ID: ');

    %% Setup Input Device(s) %%
    switch upper(computer)
      case 'MACI64'
        inputDevice = ptb_get_resp_device('Choose Participant Response Device'); % input device
      case {'PCWIN','PCWIN64'}
        % JMT:
        % Do nothing for now - return empty chosen_device
        % Windows XP merges keyboard input and will process external keyboards
        % such as the Silver Box correctly
        inputDevice = [];
      otherwise
        % Do nothing - return empty chosen_device
        inputDevice = [];
    end
    
    %% Initialize Screen %%
    w = ptb_setup_screen(0,250,theFont,theFontSize); % setup screen

end
resp_set = ptb_response_set(valid_keys); % response set
screenres = w.res(3:4); % screen resolution

%% Load Design and Setup Seeker Variable %%
DrawFormattedText(w.win,sprintf('LOADING\n\n0%% complete'),'center','center',w.white,42);
Screen('Flip',w.win);
load([designdir filesep 'loi1_design.mat'])
randidx = randperm(length(alldesign));
% designnum = randidx(1);
designnum = 3; 
design = alldesign{randidx(1)};
blockSeeker = design.blockSeeker;
trialSeeker = design.trialSeeker;
trialSeeker(:,6:9) = 0;
qim = design.qim;
qdata = design.qdata;
totalTime = design.totalTime;

%% Initialize Logfile (Trialwise Data Recording) %%
d=clock;
logfile=sprintf('sub%s_loi1_design%d.log',subjectID,designnum);
fprintf('\nA running log of this session will be saved to %s\n',logfile);
fid=fopen(logfile,'a');
if fid<1,error('could not open logfile!');end;
fprintf(fid,'Started: %s %2.0f:%02.0f\n',date,d(4),d(5));

% blockSeeker
% -------------
% 1 - block #
% 2 - condition (1=EH,2=AH,3=EL,4=AL)
% 3 - onset (s)
% 4 - cue # (corresponds to variables preblockcues & isicues, which are
% cell arrays containing the filenames for the cue screens contained in the
% folder "questions")

% trialSeeker
% -------------
% 1 - block #
% 2 - trial #
% 2 - condition (1=FH,2=AH,3=FL,4=AL)
% 4 - normative response (1=Yes, 2=No)
% 5 - stimulus # (corresponds to order in qim+qdata)
% 6 - actual onset
% 7 - response time (s) [0 if NR]
% 8 - actual response [0 if NR]
% 9 - actual offset

%% Make Images Into Textures %%
for i = 1:length(qim)
    slideName{i} = qim{i,2};
    tmp1 = imread([stimdir filesep slideName{i}]);
    tmp2 = tmp1;
    slideTex{i} = Screen('MakeTexture',w.win,tmp2);
    DrawFormattedText(w.win,sprintf('LOADING\n\n%d%% complete', ceil(100*i/length(qim))),'center','center',w.white,42);
    Screen('Flip',w.win);
end;
instructTex = Screen('MakeTexture', w.win, imread([screendir filesep 'loi1_instruction.jpg']));
fixTex = Screen('MakeTexture', w.win, imread([screendir filesep 'fixation.jpg']));

%% Test Button Box %%
bbtester(inputDevice,w.win)

% ====================
% START TASK
% ====================

%% Present Instructions %%
Screen('DrawTexture',w.win, instructTex); Screen('Flip',w.win);

% %% Present Motion Reminder %%
% KbWait(exptDevice);
% Screen('FillRect', w.win, w.black); Screen('Flip',w.win); WaitSecs(.25);
% Screen('DrawTexture',w.win,reminderTex); Screen('Flip',w.win);

%% Wait for Trigger to Start %%
DisableKeysForKbCheck([]);
KbQueueRelease()
secs=KbTriggerWait(trigger,inputDevice);	
anchor=secs;	
RestrictKeysForKbCheck(resp_set);
try

nBlocks = length(blockSeeker);

% totalTime = 15; 
% nBlocks = 1;

for b = 1:nBlocks
    
    %% Present Fixation %%
    Screen('DrawTexture',w.win, fixTex); Screen('Flip',w.win);
    
    %% Grab Data for Current Block %%
    tmpSeeker = trialSeeker(trialSeeker(:,1)==b,:);
    nTrialsBlock = length(tmpSeeker(:,1));
    
    for t = 1:nTrialsBlock
        
        %% Prep Trial Stim %%
        Screen('DrawTexture',w.win,slideTex{tmpSeeker(t,5)})

        %% Check for Escape Key
        if t==1
            winopp = (anchor + blockSeeker(b,3)) - GetSecs; 
        else
            winopp = (anchor + offset + ISI) - GetSecs; 
        end
        doquit = ptb_get_force_quit(inputDevice, KbName('ESCAPE'), winopp*.99);
        if doquit
            sca; 
            fprintf('\nESCAPE KEY DETECTED\n'); return
        end
        
%         if t==1, WaitSecs('UntilTime', anchor + blockSeeker(b,3));
%         else WaitSecs('UntilTime',anchor + offset + ISI); end
%         
        
        
        %% Present Photo Stimulus, Prepare Next Stimulus %%
        Screen('Flip',w.win);
        onset = GetSecs; tmpSeeker(t,6) = onset - anchor;
        if t==nTrialsBlock
            Screen('DrawTexture', w.win, fixTex);
        else
            Screen('FillRect', w.win, w.black);
        end
        resp = [];
        if tmpSeeker(t,3)==4
            %% Look for Response %%
            [resp rt] = ptb_get_resp_windowed_noflip(inputDevice, resp_set, maxRepDur);
            Screen('Flip', w.win);
            WaitSecs(.15);
        else
            WaitSecs('UntilTime',anchor + (onset-anchor) + maxDur);
            Screen('Flip', w.win);
        end
        offset = GetSecs - anchor;
            
        %% Listen a Little Longer for a Response %%
        if ~isempty(resp)
            tmpSeeker(t,8) = str2num(resp(1));
            tmpSeeker(t,7) = rt;
        end
        tmpSeeker(t,9) = offset;

        
    end % TRIAL LOOP

    %% Store Block Data & Print to Logfile
    trialSeeker(trialSeeker(:,1)==b,:) = tmpSeeker;
    for t = 1:size(tmpSeeker,1), fprintf(fid,[repmat('%d\t',1,size(tmpSeeker,2)) '\n'],tmpSeeker(t,:)); end

end % BLOCK LOOP

    WaitSecs('UntilTime', anchor + totalTime);

catch
    
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
    rmpath(utilitydir)
    
end;

%% Results Structure %%
result.blockSeeker = blockSeeker; 
result.trialSeeker = trialSeeker;
result.qim = qim;
result.qdata = qdata;

%% Save Data to Matlab Variable %%
d=clock;
outfile=sprintf('loi1_%s_design%d_%s_%02.0f-%02.0f.mat',subjectID,designnum,date,d(4),d(5));
try
    save([datadir filesep outfile], 'subjectID', 'result', 'slideName'); 
catch lasterr
	fprintf('couldn''t save %s\n saving to loi1.mat\n',outfile);
	save loi1.mat
  rethrow(lasterr)
end;

if nargin==0
    %% Exit %%
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
    rmpath(utilitydir)
end
try
    disp('Backing up data... please wait.');
    bob_sendemail({'bobspunt@gmail.com','conte3@caltech.edu'},'conte loi behavioral data','see attached', [datadir filesep outfile]);
    disp('All done!');
catch lasterr
    disp('Could not email data... internet may not be connected.');
    rethrow(lasterr)
end
catch lasterr
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
    rmpath(utilitydir)
    rethrow(lasterr)
end


