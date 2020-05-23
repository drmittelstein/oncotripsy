% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Decompress waveform

function decompressed_waveform = sub_Data_DecompressWaveform(waveform)

decompressed_waveform.YData = waveform.YData;

if isfield(waveform, 'XData')
    % Waveform already decompressed
    decompressed_waveform = waveform;
    
else
if numel(waveform.XDataComp.t0) == 1

    decompressed_waveform.XData = ...
    waveform.XDataComp.t0 + ...
    (0 : (numel(waveform.YData) - 1))' .* waveform.XDataComp.dt;

else
   
    d = numel(waveform.XDataComp.t0);
    e = max(size(waveform.YData));
    
    decompressed_waveform.XData = waveform.YData .* 0;
    
    for i = 1:d
        decompressed_waveform.XData(:,i) = ...
            waveform.XDataComp.t0(i) + ...
            (0 : (e - 1))' .* waveform.XDataComp.dt;
    end
    
    
end
end

end
