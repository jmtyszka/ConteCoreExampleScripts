function handle=initCEDRUS

%try
%    handle = CedrusResponseBox('Open', 'COM3',[],0);
%    fprintf('Cedrus on COM3\n');
%catch
    try
        handle = CedrusResponseBox('Open', 'COM4',[],0);
        fprintf('Cedrus on COM4\n');
    catch
        try
            handle = CedrusResponseBox('Open', 'COM5',[],0);
            fprintf('Cedrus on COM5\n');
        catch
            try
                handle = CedrusResponseBox('Open', 'COM6',[],0);
                fprintf('Cedrus on COM6\n');
            catch
                try
                    handle = CedrusResponseBox('Open', 'COM7',[],0);
                    fprintf('Cedrus on COM7\n');
                catch
                    try
                        handle = CedrusResponseBox('Open', 'COM8',[],0);
                        fprintf('Cedrus on COM8\n');
                    catch
                        handle = CedrusResponseBox('Open', 'COM9',[],0);
                        fprintf('Cedrus on COM9\n');
                    end
                end
            end
        end
    end
%end