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