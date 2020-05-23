% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Send a trigger command to the signal generator

function params = sub_SG_Trigger(params)

try
    if params.SG.LimitSG == 0
        return
    end
    if params.Debug == 1
        return
    end

catch
end

if params.SG.Initialized

    if strcmp(params.SG.Instrument, 'TABOR')
        
        fprintf(params.SG.visaObj,':TRG'); 
        
    elseif strcmp(params.SG.Instrument, 'BKP')
        disp('TRIG')
        fprintf(params.SG.visaObj,'C2:BTWV TRSR,EXT;');
        fprintf(params.SG.visaObj,'C1:BTWV TRSR,MAN;');
        fprintf(params.SG.visaObj,'C1:BTWV MTRIG,1;');
        fprintf(params.SG.visaObj,'C2:BTWV TRSR,EXT;'); 
    end
end
        
end