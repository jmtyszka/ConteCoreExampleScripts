try

  home;
  
  %% Check for Psychtoolbox %%
  try
      ptbVersion = PsychtoolboxVersion;
      if ~strcmp(ptbVersion, '3.0.10')
        disp('Run fix_psychtoolbox_path.m to correct the Psychtoolbox installation');  
      end
  catch
      url = 'https://github.com/Psychtoolbox-3/Psychtoolbox-3';
      fprintf('Psychophysics Toolbox may not be installed or in your search path.\nSee: %s\n', url);
  end

  %% Paths %%
  basedir = pwd;
  datadir = fullfile(basedir, 'data');
  utilitydir = fullfile(basedir, 'utilities');
  addpath(utilitydir)

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

  %% Setup Input Device(s) %%
  w = ptb_setup_screen(0,250,'Arial',54); % setup screen

  %% Test Screen Resolution (stimPC should be at 1280 x 1024)
  if ~isequal([w.res(3) w.res(4)],[1280 1024])
      fprintf('\n\n\n\nERROR: Set screen resolution to 1280 x 1024\n\n\n\n');
      Screen('CloseAll');
      Priority(0);
      ShowCursor;
      return
  end

  %% Run LOI 1 %%
  run_loi1(subjectID,inputDevice,w)

  %% Display interim message
  display_message('You have completed the\nImage Observation Test.',w.win,inputDevice); % message

  %% Run LOI 2 %%
  run_loi2(subjectID,inputDevice,w)

  %% Display interim message
  display_message('You have completed the\nPhoto Judgment Test.',w.win,inputDevice); % message

  %% Close Screens %%
  Screen('CloseAll');
  Priority(0);
  ShowCursor;
  rmpath(utilitydir)

catch lasterr
  Screen('CloseAll');
  Priority(0);
  ShowCursor;
  rethrow(lasterr)
end




