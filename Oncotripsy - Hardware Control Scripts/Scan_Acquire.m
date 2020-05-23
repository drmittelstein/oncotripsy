% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Acquire a single waveform at one position

% Motor Stage - must be set near the focal point
%
% Function Generator must be manually set at center frequency
% - Run on repeat with timer at 1 ms, for 10 cycles
%
% Oscilloscope - must be configured to be able to see the waveform

sub_Close_All_Connections;

%% Prepare Parameters Variable
params = sub_AllSettings('Scan_Acquire');
params.Scope.averaging = 4096;
params.Scope.MaintainSettings = 0;
params = sub_Scope_Initialize(params);

params.Scope.channels = [1 2 3 4];

params = sub_Scope_Readout_All(params);

try; 

figure(1); clf;

clr = 'ygbr';
for i = 1:4
    try
        subplot(4,1,i)
        plot(params.Scope.Ch(i).XData, params.Scope.Ch(i).YData, clr(i));
        hold on;
    catch
    end
end
ylabel('Voltage (V)')
xlabel('Time (s)')


catch;
end;


%% Close All Connections
sub_Close_All_Connections;
try; params = rmfield(params, 'GUI'); catch; end

fsize = [4 4];
set(gcf,'PaperUnits','inches');
set(gcf,'PaperSize',fsize);
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperPosition', [0 0 fsize(1) fsize(2)]);
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
print(gcf, '-dpng', [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.png']);
clear fsize fld;

%% Data Management
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
filestr = [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.mat'];
save(filestr, 'params')
disp(['Scope Data Saved from Channels ' num2str(params.Scope.channels)]);
disp(['File: ' filestr])