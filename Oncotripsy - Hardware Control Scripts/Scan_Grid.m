% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Uses Velmex stage to move in a predefined pattern to get pressure waveform at all points

%% Initiatlize
% Users can change these parameters to control how acquisition is performed
% by oscilloscope

params = sub_AllSettings('Scan_Grid');  % Prepares parameters variable
params.Scope.averaging = 1024;   % Set to configure oscilloscope 
                                 % averaging used in acquisition

params.Debug = 0; % Set to 1 to generate simulated data instead of reading 
                  % from oscilloscpe

%% Scan Parameters
% Users can change these parameters to control how the grid of data points
% is acquired

params.Scan.SaveWaveforms = 1;
% Recommended 1
% Set to 1 to save the full waveform acquired at every location on the grid
% this is required to observe phase information of the signal
% If set to 0, only the peak-to-peak voltage and energy at each point will
% be saved

% Oscilloscope Connections (update if changed from default)
params.Scope.ChSG = 2; % Default 2
params.Scope.ChHydrophone = 4; % Default 4
% Not recommended to change from default wiring

%% Dimensions
% Note that the "params.Stages.step_distance" constant is the distance in
% meters of one motor step size

% Dimension 1
params.Scan.dim1 = params.Stages.x_motor;
params.Scan.dim1_step = 0.001 / params.Stages.step_distance; 
% Motor steps between each acquisition

dim1_width = 0.02 / params.Stages.step_distance; 
params.Scan.dim1_total = floor(dim1_width / params.Scan.dim1_step); 
% Total number of acquisitions on this dimension

% Dimension 2
params.Scan.dim2 = params.Stages.y_motor;
params.Scan.dim2_step = 0.001 / params.Stages.step_distance;
% Motor steps between each acquisition

dim2_width = 0.02 / params.Stages.step_distance;
params.Scan.dim2_total = floor(dim2_width / params.Scan.dim2_step); 
% Total number of scans on this dimension

% Dimension 3
params.Scan.dim3 = params.Stages.y_motor;

% Total
steps_total = params.Scan.dim1_total * params.Scan.dim2_total;

% Add an offset
dim1_offset = 0 / params.Stages.step_distance;
dim2_offset = 0 / params.Stages.step_distance;
dim3_offset = 0 / params.Stages.step_distance;

%% Save the code form this script in params file
try
    IO = fopen([mfilename '.m'],'r');
    params.ScriptCode = textscan(IO,'%s','Delimiter','\n'); 
    fclose(IO);
    clear IO;
catch
    disp('Could not save a copy of script code in params file')
end

%% Initialize Hardware Interfaces
sub_Close_All_Connections;
params = sub_Scope_Initialize(params);
params.Scope.channels = [params.Scope.ChSG, params.Scope.ChHydrophone];
params = sub_Stage_Initialize(params);

%% Construct Location Matrix

% 2D Scan, choose two dimensions over which to scan
params = sub_Stage_Update_Positions(params);
loc = params.Stages.Position;

i = 0;
loc(params.Scan.dim1) = loc(params.Scan.dim1) - params.Scan.dim1_step * params.Scan.dim1_total / 2 ...
    + dim1_offset;
loc(params.Scan.dim2) = loc(params.Scan.dim2) - params.Scan.dim2_step * params.Scan.dim2_total / 2 ...
    + dim2_offset;
loc(params.Scan.dim3) = loc(params.Scan.dim3) ...
    + dim3_offset;

for s1 = 1:params.Scan.dim1_total
    for s2 = 1:params.Scan.dim2_total
        
        i = i + 1;
        params.Scan.Location(:,i) = loc;
        params.Scan.Objective(i) = 0;
        loc(params.Scan.dim2) = loc(params.Scan.dim2) + params.Scan.dim2_step;
        
    end
    loc(params.Scan.dim1) = loc(params.Scan.dim1) + params.Scan.dim1_step;
    loc(params.Scan.dim2) = loc(params.Scan.dim2) - params.Scan.dim2_step * params.Scan.dim2_total;
end

%% Setup GUI

GUI = struct;

% Axes in units of mm
ax1 = (-(params.Scan.dim1_total - 1)/2:1:(params.Scan.dim1_total-1)/2) ...
    .* params.Scan.dim1_step .* params.Stages.step_distance * 1000;

ax2 = (-(params.Scan.dim2_total - 1)/2:1:(params.Scan.dim2_total-1)/2) ...
    .* params.Scan.dim2_step .* params.Stages.step_distance * 1000;

GUI.fig = figure(1); clf;
set(GUI.fig, 'MenuBar', 'None', 'Name', params.NameFull);
GUI.figmenu = uimenu(GUI.fig, 'Label','Scan_Grid Commands');

GUI.Flags.Quit = 0;
GUI.Flags.BackToOrigin = 0;
GUI.Flags.MoveToMax = 0;

uimenu(GUI.figmenu, 'Label', 'Stop Search and Move To Max', 'Callback', 'GUI.Flags.Quit = 1; GUI.Flags.MoveToMax = 1;');
uimenu(GUI.figmenu, 'Label', 'Stop Search and Return to Origin', 'Callback', 'GUI.Flags.Quit = 1; GUI.Flags.BackToOrigin = 1;');

subplot(3,2,1:4)
GUI.im = imagesc(ax1, ax2, reshape(params.Scan.Objective, params.Scan.dim2_total, params.Scan.dim1_total));
GUI.cb = colorbar; 

axistitles = 'ZYX';
xlabel(sprintf('%s (mm)', axistitles(params.Scan.dim1)))
ylabel(sprintf('%s (mm)', axistitles(params.Scan.dim2)))
axis image

subplot(3,2,5)
params = sub_Scope_Readout_All(params);
params.Scan.CenterWaveform.ChSG = params.Scope.Ch(params.Scope.ChSG);
params.Scan.CenterWaveform.ChHydrophone = params.Scope.Ch(params.Scope.ChHydrophone);

GUI.scopegraph_SG = plot(0, 0, 'g-');
hold on;
GUI.scopegraph_HP = plot(0, 0, 'r-');
GUI.scopegraph_leg = legend(...
    sprintf('SG: %1.1 mVpp', 0), ...
    sprintf('HP: %1.1 mVpp', 0));
set(gca,'YTick',[])
xlabel('Time (s)');
t = params.Scope.Ch(params.Scope.ChHydrophone).XData;
xlim([min(t), max(t)])

subplot(3,2,6); hold on;
GUI.fftgraph_SG = plot(0, 0, 'g-');
GUI.fftgraph_HP = plot(0, 0, 'r-');
xlim([0 params.Transducer_Fc * 10])
set(gca,'YTick',[])
xlabel('Frequency (Hz)');

%% Scripts to Draw Figures
% Call these scripts immediately after loading the params file
% For example, this would reproduce the image plot
% eval(params.Scripts.PlotImage);

params.Scripts.PlotImage = [...
    'figure(1); clf; ' ...
    'ax1 = (-(params.Scan.dim1_total - 1)/2:1:(params.Scan.dim1_total-1)/2)' ...
    '.* params.Scan.dim1_step .* params.Stages.step_distance * 1000;' ...
    'ax2 = (-(params.Scan.dim2_total - 1)/2:1:(params.Scan.dim2_total-1)/2)' ...
    '.* params.Scan.dim2_step .* params.Stages.step_distance * 1000;' ...
    'imagesc(ax1, ax2, reshape(params.Scan.Objective,' ...
    'params.Scan.dim2_total, params.Scan.dim1_total));' ...
    'xlabel(''Distance (mm)'');' ...
    'ylabel(''Distance (mm)'');' ...
    'axis image; ' ...
    'colorbar;' ...
    'title([params.Name '' '' params.Time], ''Interpreter'', ''None''); ' ...
    'clear ax1 ax2;'];

params.Scripts.PlotImageAndSave = [params.Scripts.PlotImage ...
    'fsize = [4 4];' ...
    'set(1,''PaperUnits'',''inches'');' ...
    'set(1,''PaperSize'',fsize);' ...
    'set(1,''PaperPositionMode'',''manual'');' ...
    'set(1,''PaperPosition'', [0 0 fsize(1) fsize(2)]);' ...
    'fld = [''results\'' datestr(params.Time, ''yyyy-mm-dd'')];' ...
    'mkdir(fld);' ...
    'print(1, ''-dpng'', [fld ''\results_'' params.Name ''_'' datestr(params.Time, ''yyyy-mm-dd_HH-MM'') ''.png'']);' ...
    'clear fsize fld;'];

params.Scripts.PlotCenterWaveform = [...
    'figure(2); clf; ' ...
    't = params.Scan.CenterWaveform.ChSG.XData; ' ...
    'A2 = params.Scan.CenterWaveform.ChSG.YData; ' ...
    'A3 = params.Scan.CenterWaveform.ChHydrophone).YData; ' ...
    'plot(t,A2,''g-'',t,A3,''b-''); ' ...
    'xlabel(''Time (s)''); ' ...
    'ylabel(''Voltage (V)''); ' ...
    'title([params.Name '' '' params.Time], ''Interpreter'', ''None''); ' ...
    'clear t A2 A3;'];


%% Perform Scan
% Data is NOT saved during the scan, only at the end
% If you cancel scan, manually run the Save Results code at the bottom 
% of the script to save data

params = sub_Scope_Readout_All(params);
params.Scan.CenterWaveform.ChSG = params.Scope.Ch(params.Scope.ChSG);
params.Scan.CenterWaveform.ChHydrophone = params.Scope.Ch(params.Scope.ChHydrophone);

h_tic = tic;

for i = 1:size(params.Scan.Location,2)

if GUI.Flags.Quit == 1; break; end
    


params = sub_Stage_Move_To(params, params.Scan.Location(:,i));

if ~params.Debug
    pause(.2); % Delay for Signal to Level Out
end
            
params = sub_Scope_Readout_All(params);
params.Scan.Waveforms(i) = sub_Data_CompressWaveform(params.Scope.Ch(params.Scope.ChHydrophone));

t = params.Scope.Ch(params.Scope.ChHydrophone).XData;

H = params.Scope.Ch(params.Scope.ChHydrophone).YData; H = H - mean(H);
S = params.Scope.Ch(params.Scope.ChSG).YData; S = S - mean(S);

fs = 1/(t(2)-t(1)); %Sampling frequency
fft_pts = length(t); % Nb points
w = (0:fft_pts-1)./fft_pts.*fs;
w0 = params.Transducer_Fc;
w_I = find(w>=w0,1,'first');

Hw = fft(H);
Sw = fft(S);

params.Scan.Pkpk(i) = max(H) - min(H);
params.Scan.Eng(i) = sum(H.^2);
try
params.Scan.FFT_peak(i) = abs(H(w_I));
catch
end

w_2F0 = find(w>=2*w0,1,'first');

params.Scan.Objective(i) = sum(abs(H).^2); %sum(abs(Hw(w_2F0:numel(w)/2)).^2); 
params.Scan.ObjectiveTitle = 'Energy'; %'Energy F>2F0';

time_per_step = toc(h_tic) / i;
sub_Data_Countdown((steps_total - i) * time_per_step, i ./ steps_total);

set(GUI.im, 'CData', reshape(params.Scan.Objective, params.Scan.dim2_total, params.Scan.dim1_total));

set(GUI.scopegraph_SG, 'XData', t);
set(GUI.scopegraph_SG, 'YData', S/ max(abs(S(:))));
set(GUI.scopegraph_HP, 'XData', t);
set(GUI.scopegraph_HP, 'YData', H / max(abs(H(:))));

set(GUI.scopegraph_leg, 'String', {
    sprintf('SG: %1.1f mVpp', 1000*(max(S)-min(S))), ...
    sprintf('HP: %1.1f mVpp', 1000*(max(H)-min(H)))});

set(GUI.fftgraph_HP, 'XData', w(1:floor(numel(w)/2)));
fftHP = abs(Hw(1:floor(numel(w)/2)));
set(GUI.fftgraph_HP, 'YData', fftHP / max(fftHP));

GUI.cb.Label.String = params.Scan.ObjectiveTitle;
drawnow
end         

if GUI.Flags.MoveToMax
    [~, i_max] = max(params.Scan.Objective); % Find location of maximum pressure
    disp(sprintf('Moving to Location %1.0f', i_max))
    params = sub_Stage_Move_To(params, params.Scan.Location(:, i_max));
else
    sub_Stage_Move_To(params, params.Stages.Origin);
end

params = sub_Stage_Update_Positions(params);

disp(['Finished at ' datestr(now)]);
set(GUI.figmenu, 'Label', ['Finished at ' datestr(now)], 'Enable', 'off');

%% Close All Connections
sub_Close_All_Connections;

%% Save Results
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
save([fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.mat'], 'params')

figure(1); clf; 
ax1 = (-(params.Scan.dim1_total - 1)/2:1:(params.Scan.dim1_total-1)/2) ...
    .* params.Scan.dim1_step .* params.Stages.step_distance * 1000;
ax2 = (-(params.Scan.dim2_total - 1)/2:1:(params.Scan.dim2_total-1)/2) ...
    .* params.Scan.dim2_step .* params.Stages.step_distance * 1000;
imagesc(ax1, ax2, reshape(params.Scan.Objective, ...
    params.Scan.dim2_total, params.Scan.dim1_total));
xlabel('Distance (mm)');
ylabel('Distance (mm)');
axis image;
colorbar;
title([params.Name ' ' params.Time], 'Interpreter', 'None'); 


%eval(params.Scripts.PlotImageAndSave);

%% Turn off SG at completion
params = sub_SG_Initialize(params);
sub_SG_Stop(params);