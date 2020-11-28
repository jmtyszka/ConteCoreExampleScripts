function run_loi2(subjectID,inputDevice,w)
% ====================
% DEFAULTS
% ====================

KbName('UnifyKeyNames')

%% Paths %%
basedir = pwd;
datadir = fullfile(basedir, 'data');
screendir = fullfile(basedir, 'stimuli');
stimdir = fullfile(basedir, 'stimuli/loi2');
designdir = fullfile(basedir, 'designs');
utilitydir = fullfile(basedir, 'utilities');
addpath(utilitydir)

%% Text %%
theFont='Arial';    % default font
theFontSize=42;     % default font size
theFontSize2=46;
fontwrap=42;        % default font wrapping (arg to DrawFormattedText)

%% Timing %%
cueDur = 2.1;
maxDur = 1.7;
ISI = .3;
firstISI = .15;
nTrialsBlock = 8;

%% Response Keys %%
trigger = KbName('5%');
valid_keys = {'1!' '2@' '3#' '4$' 'ESCAPE'};

% ====================
% END DEFAULTS
% ====================

%% Print Title %%
script_name='-- Photo Judgment Test --'; boxTop(1:length(script_name))='=';
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
Screen('TextSize',w.win,theFontSize);
DrawFormattedText(w.win,sprintf('LOADING\n\n0%% complete'),'center','center',w.white,42);
Screen('Flip',w.win);
load([designdir filesep 'loi2_design.mat'])

% get design
designnum = 3; 
% try
%   d = dir(['sub' subjectID '_loi1_design*log']);
%   fn = d(1).name;
%   tmpidx = strfind(fn,'design');
%   designnum = str2num(fn(tmpidx+6));
% catch
%   disp('problem getting previous design');
%   randidx = randperm(length(alldesign));
%   designnum = randidx(1);
% end
design = alldesign{designnum};
ordered_questions = design.preblockcues(design.blockSeeker(:,4));
pbc_brief = regexprep(design.preblockcues,'Is the person ','');
isicues = design.isicues;
preblockcues = design.preblockcues; 
blockSeeker = design.blockSeeker;
trialSeeker = design.trialSeeker;
trialSeeker(:,6:9) = 0;
qim = design.qim;
qdata = design.qdata;
totalTime = design.totalTime;


%% Initialize Logfile (Trialwise Data Recording) %%
d=clock;
logfile=sprintf('sub%s_loi2_design%d.log',subjectID,designnum);
fprintf('\nA running log of this session will be saved to %s\n',logfile);
fid=fopen(logfile,'a');
if fid<1,error('could not open logfile!');end;
fprintf(fid,'Started: %s %2.0f:%02.0f\n',date,d(4),d(5));

%% For Adding Some Time to the SOAs %%
ons1 = blockSeeker(:,3);
ons1(end+1) = totalTime; 
soa1 = diff(ons1);
soa2 = soa1;
soa2(find(blockSeeker(:,2)<3)) = soa2(find(blockSeeker(:,2)<3)) + .5;
soa2(find(blockSeeker(:,2)>2)) = soa2(find(blockSeeker(:,2)>2)) + .25;
soa2(1) = soa1(1) + 1;
soa2(end) = 20;
ons2 = cumsum(soa2);
ons2 = ons2 + blockSeeker(1,3);
totalTime = round(ons2(end));
ons2(end) = [];
blockSeeker(2:end,3) = ons2;

%% For Replacing Some ISI Cues %%
isicues = regexprep(isicues, 'concern with health?', 'healthy');
isicues = regexprep(isicues, 'in an argument?', 'argument');
% isicues = regexprep(isicues, 'self-doubt?', 'doubting');
% isicues = regexprep(isicues, 'self-protection?', 'protecting');

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
instructTex = Screen('MakeTexture', w.win, imread([screendir filesep 'loi2_instruction.jpg']));
fixTex = Screen('MakeTexture', w.win, imread([screendir filesep 'fixation.jpg']));

%% Get Coordinates for Centering ISI Cues
for q = 1:length(isicues)
    [isicues_xpos(q) isicues_ypos(q)] = ptb_center_position(isicues{q},w.win);
end

% %% Test Button Box %%
% bbtester(inputDevice,w.win)

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
    pbcue = pbc_brief{blockSeeker(b,4)}; % preblock question stimulus
    isicue = isicues{blockSeeker(b,4)}; % isi stimulus
    isicue_x = isicues_xpos(blockSeeker(b,4));
    isicue_y = isicues_ypos(blockSeeker(b,4));
    
    %% Prepare Question Stimulus While Waiting %%
    Screen('TextSize',w.win,theFontSize); Screen('TextStyle',w.win,0);
    DrawFormattedText(w.win,'Is the person\n\n\n','center','center',w.white,46);
    Screen('TextStyle',w.win,1); Screen('TextSize',w.win,theFontSize2);
    DrawFormattedText(w.win,pbcue,'center','center',w.white,46);
    
    %% Present Question Stimulus and Prepare Blank Stimulus %%
    WaitSecs('UntilTime',anchor + blockSeeker(b,3)); Screen('Flip', w.win);
    Screen('FillRect', w.win, w.black);
    
    %% Present Blank Stimulus Prior to Trial 1 %%
    WaitSecs('UntilTime',anchor + blockSeeker(b,3) + cueDur); Screen('Flip', w.win);
    
    for t = 1:nTrialsBlock
        
        %% Prep Trial Stim %%
        Screen('DrawTexture',w.win,slideTex{tmpSeeker(t,5)})
        if t==1, WaitSecs('UntilTime',anchor + blockSeeker(b,3) + cueDur + firstISI);
        else WaitSecs('UntilTime',anchor + offset + ISI); end
        
        %% Present Photo Stimulus, Prepare Next Stimulus %%
        Screen('Flip',w.win);
        onset = GetSecs; tmpSeeker(t,6) = onset - anchor;
        if t==nTrialsBlock
            Screen('DrawTexture', w.win, fixTex);
        else
            Screen('DrawText', w.win, isicue, isicue_x, isicue_y);
%           DrawFormattedText(w.win,isicue,'center','center',w.white,46);
        end
        WaitSecs(.20)
        
        %% Look for Response
        resp = [];
        [resp rt] = ptb_get_resp_windowed_noflip(inputDevice, resp_set, maxDur);
        offset = GetSecs - anchor;
        
        %% Listen a Little Longer for a Response %%
        Screen('Flip', w.win);
        isiflag = isempty(resp);
        if isiflag, [resp rt] = ptb_get_resp_windowed_noflip(inputDevice, resp_set, .25); end
        if ~isempty(resp)
            tmpSeeker(t,8) = str2num(resp(1));
            tmpSeeker(t,7) = rt + (maxDur*isiflag);
        end
        tmpSeeker(t,9) = offset;

%         %-----------------
%         % Record response
%         %-----------------
%         noresp = 1;
%         while noresp && GetSecs - onset < maxDur
%             [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
%             keyPressed = find(keyCode);
%             if keyIsDown & ismember(keyPressed,resp_set)
%                 tmp = KbName(keyPressed);
%                 tmpSeeker(t,7) = secs - onset;
%                 tmpSeeker(t,8) = str2double(tmp(1));
%                 noresp = 0;
%            end;
%         end;
%         %--------------------------------------------
%         % Present ISI (or fixation, if last trial
%         %--------------------------------------------
%         Screen('Flip', w.win);
%         offset = GetSecs - anchor;
%         tmpSeeker(t,9) = offset;
%         if tmpSeeker(t,7)==0
%             while GetSecs - onset < maxDur + ISI - .1
%                 [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
%                 keyPressed = find(keyCode);
%                 if keyIsDown & ismember(keyPressed,resp_set)
%                     tmp = KbName(keyPressed);
%                     tmpSeeker(t,7) = secs - onset;
%                     tmpSeeker(t,8) = str2double(tmp(1));
%                 end;
%             end;
%         end
        
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
result.preblockcues = preblockcues; 
result.isicues = isicues; 

%% Save Data to Matlab Variable %%
d=clock;
outfile=sprintf('loi2_%s_design%d_%s_%02.0f-%02.0f.mat',subjectID,designnum,date,d(4),d(5));
try
    save([datadir filesep outfile], 'subjectID', 'result', 'slideName'); 
catch
	fprintf('couldn''t save %s\n saving to loi2.mat\n',outfile);
	save loi2.mat
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
catch
    disp('Could not email data... internet may not be connected.');
end


