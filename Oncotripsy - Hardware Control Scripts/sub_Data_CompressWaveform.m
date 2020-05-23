% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Compresses a waveform

function compressed_waveform = sub_Data_CompressWaveform(waveform)

try; waveform.RawData = []; catch; end;

s = size(waveform.XData);
if s(1) == 1;
    waveform.XData = waveform.XData';
end

d = diff(waveform.XData);
if std(d) < abs(d(1))

compressed_waveform.YData = waveform.YData;

if min(size(waveform.XData) == 1)    
    compressed_waveform.XDataComp.t0 = min(waveform.XData);
    compressed_waveform.XDataComp.dt = waveform.XData(2) - waveform.XData(1);
else
    d = min(size(waveform.XData));
    
    compressed_waveform.XDataComp.dt = waveform.XData(2,1) - waveform.XData(1,1);
    
    for i = 1:d
        compressed_waveform.XDataComp.t0(i) = min(waveform.XData(:,i));
    end
    
    
end

else
    disp('- WARNING: cannot compress, XData is not linearly increasing');
    compressed_waveform = waveform;
    compressed_waveform.DidNotCompress = 1;
end

end
