function params = sub_Scope_ApplySettings(params)

%fprintf(params.Scope.visaObj, ':TRIG:SOUR CHAN1');
%fprintf(params.Scope.visaObj, ':TRIG:HOLD 2');

fprintf(params.Scope.visaObj,':ACQUIRE:MODE RTIM'); 
fprintf(params.Scope.visaObj,':TIMEBASE:MODE MAIN'); 

if params.Scope.averaging < 2
    fprintf(params.Scope.visaObj,[':ACQuire:TYPE NORMal']); 
else
    fprintf(params.Scope.visaObj,[':ACQuire:TYPE AVERage']); 
    fprintf(params.Scope.visaObj,[':ACQuire:COUNt ' num2str(min(round(params.Scope.averaging),65536))]); 
end

% If no channels specified, default readout 2 and 3
if ~isfield(params.Scope, 'channels')
    params.Scope.channels = [2 3];
end

% Remove Channels that are not 1, 2, 3, 4
c = params.Scope.channels; c(c~=floor(c)) = []; c(c>4) = []; c(c<1) = [];
params.Scope.channels = unique(c);

for channel = params.Scope.channels
 fprintf(params.Scope.visaObj,[':WAVEFORM:SOURCE CHANNEL' num2str(channel)]); 
 fprintf(params.Scope.visaObj,':WAVEFORM:POINTS:MODE NORMAL'); 
 fprintf(params.Scope.visaObj,':WAVEFORM:FORMAT WORD'); 
 fprintf(params.Scope.visaObj,':WAVEFORM:BYTEORDER LSBFirst'); 
end


try
    fprintf(params.Scope.visaObj,...
    sprintf(':TIMebase:RANGe %1.3e', params.Scope.Settings.TimeRange));

fprintf(params.Scope.visaObj,...
    sprintf(':TIMebase:POSition %1.3e', params.Scope.Settings.Position));
catch
end
end