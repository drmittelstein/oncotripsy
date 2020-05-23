% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Acquire waveform continually, refreshing as fast as possible
% Allows for capturing time varying phenomenon that are not linked
% To a signal for acquisition

sub_Close_All_Connections;

%% Prepare Parameters Variable
params = sub_AllSettings('Scan_Acquire_Cont');
params.Scope.averaging = 64;

%% Setup GUI
GUI.fig = figure(1); clf;
set(GUI.fig, 'MenuBar', 'None', 'Name', params.NameFull);
GUI.figmenu = uimenu(GUI.fig, 'Label','Scan_Acquire_Cont Commands');

GUI.Flags.Quit = 0;

uimenu(GUI.figmenu, 'Label', 'Clear', 'Callback', 'GUI.Flags.Clear = 1;');
uimenu(GUI.figmenu, 'Label', 'Stop and Save', 'Callback', 'GUI.Flags.Quit = 1;');

subplot(4,2,1:2);
GUI.progressgraph = plot(0,0,'k-o');
xlabel('Time (sec)');
ylabel('mVpp')

subplot(4,2,3:4);
GUI.distancegraph = plot(0,0,'k-o'); hold on;
GUI.distancetext = text(0,0,'0');
xlabel('Time (sec)');
ylabel('Distance (mm)');

subplot(4,2,5:6);
GUI.vppdistance = plot(0,0,'k-o'); hold on;
xlabel('Disance (mm)')
ylabel('mVpp')

subplot(4,2,7)
GUI.scopegraph = plot(0, 0, 'k-');
xlabel('Time (s)');

subplot(4,2,8); hold on;
GUI.fftgraph = plot(0, 0, 'k-');
GUI.fftgraph_foc = plot(0, 0, 'ro');
xlim([0 params.Transducer_Fc * 2])
xlabel('Frequency (Hz)');

%%

GUI.Flags.Clear = 0;

params.Results.Time = [];
params.Results.Objective = [];
params.Results.Distance = [];
params = sub_Scope_Initialize(params);

h_tic = tic;

while ~GUI.Flags.Quit
    
i = numel(params.Results.Time) + 1;
params.Scope.channels = [2 4];

params = sub_Scope_Readout_All(params);

t = params.Scope.Ch(4).XData; %Time vector
A = params.Scope.Ch(4).YData;% Signal
A = A - mean(A); % Remove offset

fs = 1/(t(2)-t(1)); %Sampling frequency
fft_pts = length(t); % Nb points

w = (0:fft_pts-1)./fft_pts.*fs;
w0 = params.Transducer_Fc;   
Aw = fft(A);

w_I = find(w>=w0,1,'first');

params.Results.Time(i) = toc(h_tic);
params.Results.Objective(i) = (max(A) - min(A)) * 1000;

A2 = params.Scope.Ch(2).YData; A2 = A2 - mean(A2); A2 = A2 ./ max(A2); A2(A2<-1) = -1;
A3 = -params.Scope.Ch(4).YData; A3 = A3 - mean(A3); A3 = A3 ./ max(A3); A3(A3<-1) = -1;
t = params.Scope.Ch(2).XData;
fs = 1/(t(2)-t(1)); %Sampling frequency

[pk2, tpk2] = findpeaks(A2,t,'MinPeakDistance',0.5/params.Transducer_Fc, 'MinPeakHeight',0.1);
[pk3, tpk3] = findpeaks(A3,t,'MinPeakDistance',0.5/params.Transducer_Fc, 'MinPeakHeight',0.1);

xlim([min(t), tpk3(1) + 0.0001])

t_dist = tpk3(1) - tpk2(1);
s_dist = t_dist * params.Acoustic.MediumAcousticSpeed;
params.Results.Distance(i) = s_dist;

set(GUI.scopegraph, 'XData', t);
set(GUI.scopegraph, 'YData', A);

set(GUI.progressgraph, 'XData', params.Results.Time);
set(GUI.progressgraph, 'YData', params.Results.Objective);

set(GUI.distancegraph, 'XData', params.Results.Time);
set(GUI.distancegraph, 'YData', params.Results.Distance *1000);
set(GUI.distancetext, 'Position', [params.Results.Time(end), params.Results.Distance(end) *1000] );
set(GUI.distancetext, 'String', sprintf('%1.2f mm', params.Results.Distance(end) *1000));
set(GUI.distancetext, 'BackgroundColor', [1,1,1])

xd = params.Results.Distance *1000;
yd = params.Results.Objective;

yd(xd < 0) = [];
xd(xd < 0) = [];

set(GUI.vppdistance, 'XData', xd)
set(GUI.vppdistance, 'YData', yd)

set(GUI.fftgraph, 'XData', w(1:floor(numel(w)/2)));
set(GUI.fftgraph, 'YData', abs(Aw(1:floor(numel(w)/2))));

set(GUI.fftgraph_foc, 'XData', w(w_I));
set(GUI.fftgraph_foc, 'YData', abs(Aw(w_I)));

drawnow()

if GUI.Flags.Clear
    params.Results.Time = [];
    params.Results.Distance = [];
    params.Results.Objective = [];
    GUI.Flags.Clear = 0;
    h_tic = tic;
end

end

%% Close All Connections
disp(['Finished at ' datestr(now)]);
set(GUI.figmenu, 'Label', ['Finished at ' datestr(now)], 'Enable', 'off');

sub_Close_All_Connections;


%% Save Results
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
save([fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.mat'], 'params')
