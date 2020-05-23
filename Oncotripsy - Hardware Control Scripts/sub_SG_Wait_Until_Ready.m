% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Wait until the signal generator has completed operations

function params = sub_SG_Wait_Until_Ready(params)

try
    if params.Debug == 1
        return
    end
catch
end

if params.SG.Initialized
    
if strcmp(params.SG.Instrument, 'TABOR')
% Code to Run for TABOR


elseif strcmp(params.SG.Instrument, 'BKP')
% Code to Run for BKP       
query(params.SG.visaObj, '*OPC?'); % Wait until operations complete

end   

end


end