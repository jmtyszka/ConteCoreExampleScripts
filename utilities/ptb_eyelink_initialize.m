function success = ptb_eyelink_initialize(w, edfHostFile)
% Customized Eyelink initialization
% AUTHOR : Julien Dubois

% Set dummymode to 1 for dummy Eyelink connection
dummymode = 0;

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).

el = EyelinkInitDefaults(w);

% Turn off beeps!
% Set the second value in each line to 0 to turn off the sound
el.cal_target_beep=[600 0 0.05];
el.drift_correction_target_beep=[600 0 0.05];
el.calibration_failed_beep=[400 0 0.25];
el.calibration_success_beep=[800 0 0.25];
el.drift_correction_failed_beep=[400 0 0.25];
el.drift_correction_success_beep=[800 0 0.25];

% Colors
el.calibrationtargetcolour       = [255 255 255];
el.backgroundcolour              = [0 0 0];
el.foregroundcolour              = [255 255 255];
el.msgfontcolour                 = [255 255 255];
el.imgtitlecolour                = [255 255 255];

% You must call this function to apply the changes from above
EyelinkUpdateDefaults(el);

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode, 1)
    success = 0;
    return;
else
    success = 1;
end

[~,vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
% Make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% Open data file to record to
Eyelink('Openfile', edfHostFile);

% Calibrate the eye tracker
EyelinkDoTrackerSetup(el);

% Do a final check of calibration using driftcorrection
EyelinkDoDriftCorrection(el);

% Start recording gaze
Eyelink('StartRecording');
