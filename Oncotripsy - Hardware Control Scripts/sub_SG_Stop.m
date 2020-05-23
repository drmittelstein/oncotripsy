% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Turn the output from the signal generator to be OFF

function params = sub_SG_Stop(params)

try
    if params.Debug == 1
        return
    end
catch
end

if params.SG.Initialized

if strcmp(params.SG.Instrument, 'TABOR')
% Code to Run for TABOR
fprintf(params.SG.visaObj,':INSTRUMENT CH1'); % Use Channel 1
fprintf(params.SG.visaObj,'OUTPUT 0');
fprintf(params.SG.visaObj,':OUTPUT:SYNC 0');

elseif strcmp(params.SG.Instrument, 'BKP')
% Code to Run for BKP


try
    %fprintf(params.SG.visaObj, 'C1:OUTP OFF'); 
    fprintf(params.SG.visaObj, 'C2:OUTP OFF');
    
catch ex
    h = waitbar(0, sprintf('SG is not responding.  Attempting to reset connection\nERROR: %s', ex.message), 'CrateCancelBtn', 'setappdata(gcbf,''canceling'',1)');  
    connected = 0;
    while ~connected
        try
        
        params = sub_SG_Initialize(params);
        fprintf(params.SG.visaObj, s);
        
        connected = 1;
        catch ex
            disp(['ERROR: ' ex.message])
            h = waitbar(0, sprintf('SG is not responding.  Attempting to reset connection\nERROR: %s', ex.message), 'CrateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
            tic
            while toc<2
                if getappdata(h,'canceling')
                    error('Cancelled attempts to reconnect to SG')
                end
                waitbar(toc/2,h)
            end
        end
        
    end
    
    delete(h);
    
end


end

end

end