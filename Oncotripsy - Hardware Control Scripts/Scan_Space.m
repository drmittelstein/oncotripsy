%% Prepare Parameters Variable
params = sub_AllSettings('Scan_Space');
params.Scope.averaging = 1024;

params.Debug = 0;

%% Scan Parameters

% Oscilloscope Connections
params.Scope.ChSG = 2;
params.Scope.ChHydrophone = 4;

% Dimension 1
params.Scan.dim1 = params.Stages.x_motor;
params.Scan.dim1_step = 0.002 / params.Stages.step_distance; % Motor steps between each scan

dim1_width = 0.008 / params.Stages.step_distance; 
params.Scan.dim1_total = floor(dim1_width / params.Scan.dim1_step); % Total number of scans on this dimension

% Dimension 2
params.Scan.dim2 = params.Stages.z_motor;
params.Scan.dim2_step = 0.0002 / params.Stages.step_distance;

dim2_width = 0.005 / params.Stages.step_distance;
params.Scan.dim2_total = floor(dim2_width / params.Scan.dim2_step); % Total number of scans on this dimension

% Dimension 3
params.Scan.dim3 = params.Stages.y_motor;
params.Scan.dim3_step = 0.0002 / params.Stages.step_distance;

dim3_width = 0.005 / params.Stages.step_distance;
params.Scan.dim3_total = floor(dim3_width / params.Scan.dim3_step); % Total number of scans on this dimension

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
loc(params.Scan.dim3) = loc(params.Scan.dim3) - params.Scan.dim3_step * params.Scan.dim3_total / 2 ...
    + dim3_offset;

for s1 = 1:params.Scan.dim1_total
    for s2 = 1:params.Scan.dim2_total
        for s3 = 1:params.Scan.dim3_total
            i = i + 1;
            params.Scan.Location(:,i) = loc;
            params.Scan.Objective(i) = 0;
            loc(params.Scan.dim3) = loc(params.Scan.dim3) + params.Scan.dim3_step;
        end
        loc(params.Scan.dim2) = loc(params.Scan.dim2) + params.Scan.dim2_step;
        loc(params.Scan.dim3) = loc(params.Scan.dim3) - params.Scan.dim3_step * params.Scan.dim3_total;
        
    end
    loc(params.Scan.dim1) = loc(params.Scan.dim1) + params.Scan.dim1_step;
    loc(params.Scan.dim2) = loc(params.Scan.dim2) - params.Scan.dim2_step * params.Scan.dim2_total;
end

steps_total = numel(params.Scan.Objective);

% %%%%% TEST
% 
% n = numel(params.Scan.Objective);
% var_grad = (1:n)'/i;
% figure(3); clf;
% scatter3(params.Scan.Location(1,:),params.Scan.Location(2,:),params.Scan.Location(3,:),20,[var_grad;var_grad.*0;var_grad.*0]');
% 
% pause
% 
% %%%%%


%% Setup GUI

GUI = struct;

GUI.fig = figure(1); clf;
set(GUI.fig, 'MenuBar', 'None', 'Name', params.NameFull);
GUI.figmenu = uimenu(GUI.fig, 'Label','Scan_Grid Commands');

GUI.Flags.Quit = 0;
GUI.Flags.BackToOrigin = 0;
GUI.Flags.MoveToMax = 0;

uimenu(GUI.figmenu, 'Label', 'Stop Search and Move To Max', 'Callback', 'GUI.Flags.Quit = 1; GUI.Flags.MoveToMax = 1;');
uimenu(GUI.figmenu, 'Label', 'Stop Search and Return to Origin', 'Callback', 'GUI.Flags.Quit = 1; GUI.Flags.BackToOrigin = 1;');

% need to finish coding the menu

subplot(3,2,1:4)
GUI.scatter = scatter3([],[],[],[]);
xlabel('X (mm)'); set(gca,'XDir','Reverse');
ylabel('Y (mm)'); set(gca,'ZDir','Reverse');
zlabel('Z (mm)'); set(gca,'YDir','Reverse');
cb = colorbar; cb.Label.String = 'Hydrophone (mVpp)';
axis square

subplot(3,2,5)
GUI.scopegraph = plot(0, 0, 'k-');
xlabel('Time (s)');

subplot(3,2,6); hold on;
GUI.fftgraph = plot(0, 0, 'k-');
GUI.fftgraph_foc = plot(0, 0, 'ro');
xlim([0 params.Transducer_Fc * 2])
xlabel('Frequency (Hz)');

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
    
steps_performed = i;

params = sub_Stage_Move_To(params, params.Scan.Location(:,i));

pause(.2); % Delay for Signal to Level Out
            
params = sub_Scope_Readout_All(params);
A = params.Scope.Ch(params.Scope.ChHydrophone).YData; A = A - mean(A);
t = params.Scope.Ch(params.Scope.ChHydrophone).XData;

fs = 1/(t(2)-t(1)); %Sampling frequency
fft_pts = length(t); % Nb points

w = (0:fft_pts-1)./fft_pts.*fs;
w0 = params.Transducer_Fc;
w_I = find(w>=w0,1,'first');

Aw = fft(A);
params.Scan.FFT_peak(i) = abs(Aw(w_I));
params.Scan.Pkpk(i) = max(A) - min(A);

params.Scan.Objective(i) = params.Scan.FFT_peak(i); %(max(A) - min(A)) * 1000;

time_per_step = toc(h_tic) / i;
trem = (steps_total - i) * time_per_step;
trem_str = '';

if trem > 60*60*24 % Day(s) remaining
    trem_str = [trem_str sprintf('%1.0f days, ', floor(trem/(24*60*60)))];
    trem = mod(trem, 24*60*60);
    trem_str = [trem_str sprintf('%02.0f hr, ', floor(trem/(60*60)))];
    trem = mod(trem, 60*60);
    trem_str = [trem_str sprintf('%02.0f min, ', floor(trem/(60)))];
    trem = mod(trem, 60);
    trem_str = [trem_str sprintf('%02.0f sec', floor(trem))];
    
elseif trem > 60*60 % Hours remaining
    trem_str = [trem_str sprintf('%02.0f hr, ', floor(trem/(60*60)))];
    trem = mod(trem, 60*60);
    trem_str = [trem_str sprintf('%02.0f min, ', floor(trem/(60)))];
    trem = mod(trem, 60);
    trem_str = [trem_str sprintf('%02.0f sec', floor(trem))];
    
elseif trem > 60 % Minutes remaining
    trem_str = [trem_str sprintf('%02.0f min, ', floor(trem/(60)))];
    trem = mod(trem, 60);
    trem_str = [trem_str sprintf('%02.0f sec', floor(trem))];
    
else % Seconds remaining
    trem_str = [trem_str sprintf('%02.0f sec', floor(trem))];
end

disp(sprintf('Step %05.0f (%02.2f%%) - Time Remaining: %s', ...
    steps_performed, ...
    100*steps_performed ./ steps_total, ...
    trem_str));

set(GUI.scatter, 'XData', (params.Scan.Location(params.Stages.x_motor,1:i) - params.Stages.Origin(params.Stages.x_motor)).*1000.*params.Stages.step_distance)
set(GUI.scatter, 'YData', (params.Scan.Location(params.Stages.y_motor,1:i) - params.Stages.Origin(params.Stages.y_motor)).*1000.*params.Stages.step_distance)
set(GUI.scatter, 'ZData', (params.Scan.Location(params.Stages.z_motor,1:i) - params.Stages.Origin(params.Stages.z_motor)).*1000.*params.Stages.step_distance)
set(GUI.scatter, 'CData', params.Scan.Objective(1:i)) 

set(GUI.scopegraph, 'XData', t);
set(GUI.scopegraph, 'YData', A);

set(GUI.fftgraph, 'XData', w(1:floor(numel(w)/2)));
set(GUI.fftgraph, 'YData', abs(Aw(1:floor(numel(w)/2))));

set(GUI.fftgraph_foc, 'XData', w(w_I));
set(GUI.fftgraph_foc, 'YData', abs(Aw(w_I)));
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

%% Turn off SG at completion
params = sub_SG_Initialize(params);
sub_SG_Stop(params);