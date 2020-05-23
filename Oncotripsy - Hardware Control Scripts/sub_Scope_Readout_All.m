% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
Readout multiple channels from oscilloscope

function params = sub_Scope_Readout_All(params)

% Clear previous data from channels
% for channel = 1:4
% eval(['params.Scope.Ch(' num2str(channel) ') = struct;']);
% end

try; params.Scope = rmfield(params.Scope, 'Ch'); catch; end;

if params.Debug == 1

    desired_loc = params.Stages.RandomLocation;

    loc = params.Stages.Position;
    if size(loc) == size(desired_loc)
        dPos = params.Stages.Position - desired_loc;
    else
        dPos = params.Stages.Position - desired_loc';
    end
    dPos = dPos * params.Stages.step_distance;
    
    dt = 3.1250e-08;
    dist = sqrt(sum(dPos.^2));
    amp = 1e-2 * (dist + 0.01)^-2;
    t_delay = (dist + 0.05) / params.Acoustic.MediumAcousticSpeed;

    t = (1:15999)' * dt;
    params.Scope.Ch(2).XData = t;
    params.Scope.Ch(3).XData = t;
    params.Scope.Ch(4).XData = t;

    wv = sin(2*pi*params.SG.Waveform.frequency*t);
    s_env = params.SG.Waveform.voltage * (t < params.SG.Waveform.cycles / params.SG.Waveform.frequency);
    h_env = amp * params.SG.Waveform.voltage * ((t > t_delay) & (t < t_delay + params.SG.Waveform.cycles / params.SG.Waveform.frequency));

    params.Scope.Ch(2).YData = s_env .* wv;
    params.Scope.Ch(3).YData = h_env .* wv + 0.0005 * rand(numel(t),1);
    params.Scope.Ch(4).YData = params.Scope.Ch(3).YData;
    return
end




% If no channels specified, default readout 2 and 3
if ~isfield(params.Scope, 'channels')
    params.Scope.channels = [2 3];
end

% Remove Channels that are not 1, 2, 3, 4
c = params.Scope.channels; c(c~=floor(c)) = []; c(c>4) = []; c(c<1) = [];
params.Scope.channels = unique(c);

try

% Acquire Fresh Waveform From Scope
fprintf(params.Scope.visaObj,':DIGITIZE');

if params.Scope.ArmTrigger;
    params = sub_SG_Trigger(params);
    params.Scope.ArmTrigger = 0;
end

operationComplete = str2double(query(params.Scope.visaObj,'*OPC?'));
while ~operationComplete
     pause(params.Scope.command_delay)
     operationComplete = str2double(query(params.Scope.visaObj,'*OPC?'));
end

% Collect data from scope
for channel = params.Scope.channels

fprintf(params.Scope.visaObj,[':WAVEFORM:SOURCE CHANNEL' num2str(channel)]);
pause(0.01); 


% Readout the preamble
preambleBlock = query(params.Scope.visaObj,':WAVEFORM:PREAMBLE?');
pause(0.01); 

% Process the preamble
preambleBlock = regexp(preambleBlock,',','split');
maxVal = 2^16;
waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
waveform.Type = str2double(preambleBlock{2});
waveform.Points = str2double(preambleBlock{3});
waveform.Count = str2double(preambleBlock{4});      % This is always 1
waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
waveform.XReference = str2double(preambleBlock{7});
waveform.YIncrement = str2double(preambleBlock{8}); % V
waveform.YOrigin = str2double(preambleBlock{9});
waveform.YReference = str2double(preambleBlock{10});
waveform.VoltsPerDiv = (maxVal * waveform.YIncrement / 8);      % V
waveform.Offset = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin);         % V
waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10 ; % seconds
waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds

% Readout the raw data
fprintf(params.Scope.visaObj,':WAV:DATA?');
pause(0.01);
waveform.RawData = binblockread(params.Scope.visaObj,'uint16'); 
%pause(0.01); 
fread(params.Scope.visaObj,1);
%pause(0.01); 

query(params.Scope.visaObj,'*OPC?');

if isempty(waveform.RawData)
    error('No data received from scope!');
end

% Generate X & Y Data
waveform.XData = (waveform.XIncrement.*(1:length(waveform.RawData))) - waveform.XIncrement + waveform.XOrigin;
waveform.YData = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin; 

eval(['params.Scope.Ch(' num2str(channel) ') = waveform;']);

end

catch ex
    disp(['ERROR: ' ex.message])
    h = waitbar(0, sprintf('Oscilloscope is not responding.  Attempting to reset connection\nERROR: %s', ex.message), 'CrateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
    tic
    while toc<2
        if getappdata(h,'canceling')
            error('Cancelled attempts to reconnect to oscillscope')
        end
        waitbar(toc/2,h)
    end

      
    connected = 0;
    while ~connected
        try
        params = sub_Scope_Initialize(params);
        connected = 1;
        catch ex
            disp(['ERROR: ' ex.message])
            waitbar(0, h, sprintf('Oscilloscope is not responding.  Attempting to reset connection\nERROR: %s', ex.message), 'CrateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
            tic
            while toc<10
                if getappdata(h,'canceling')
                    error('Cancelled attempts to reconnect to oscillscope')
                end
                waitbar(toc/10,h)
            end
        end
    end
    
    delete(h);
    params = sub_Scope_Readout_All(params);
end

end