function ptb_eyelink_cleanup(edfHostFile, edfLocalFile)
% Cleanup eyetracking and retrieve data file

% Finish up: stop recording eye-movements,
Eyelink('StopRecording');

% Close graphics window, close data file and shut down tracker
Eyelink('CloseFile');

% Download data file to stimulation PC
try
    fprintf('EYELINK : Receiving data file %s\n', edfHostFile );
    status = Eyelink('ReceiveFile', edfHostFile, edfLocalFile);
    
    if status > 0
        fprintf('EYELINK : ReceiveFile status %d\n', status);
    end
    
    if exist(edfLocalFile, 'file') == 2
        fprintf('EYELINK : Transfered %s to %s\n', edfHostFile, edfLocalFile);
    end
    
catch rdf
    fprintf('EYELINK : *** Problem receiving data file %s ***\n', edfHostFile );
    disp(rdf);
end

Eyelink('EYELINK : Shutdown');
