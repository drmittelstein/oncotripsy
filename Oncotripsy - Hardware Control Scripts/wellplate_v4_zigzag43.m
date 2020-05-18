% Wellplate allows you to load an 24 well plate experimental file and run
% the signal generator and motor stage to expose each well of the 24 well
% plate to a unique ultrasound signal.

%% Alignment

% Transducer must be perfectly aligned with well A1 prior to beginning
% expeirment.  The code assumes that the initial position of the stage
% positions the transducer to insonate A1

%% Experimental Filename

experimental_filename = 'Oncotripsy\Exp_ES_500kHz_COH_1ms_Only.xlsx';
skipwells = [];
override_duration = [];
% This is the filename of the excel document that we are load ing to run
% the code for the desired experiment.  It is important that this excel
% file is in the v4 format, with the following columns
% Well | ID | Freq | Pulse_Dur | Voltage | Duty_Cycle | Duration | Name
% (A1) | () | (Hz) | (s)       | (Vpp)   | ()         | (s)      | ()

% Where the voltage is the voltage that is applied to the transducer
% This program will use the amplifier settings under "AllSettings" to
% determine the appropriate driving voltage for the signal generator

%% Demo Mode Parameters

% If you want to demo just moving the stage around or just cycling through
% the different frequencies, set either of these parameters to 1, for
% normal operation, these must be set to 0
NoSG_Mode = 0;
NoStage_Mode = 0;

% If you want to set the oscilloscope to take a reading of each ultrasound
% waveform, then set this to 0.  In general this is not necessary, so by
% default we set this to 1
NoScope_Mode = 1;

%% Set up GUI and initial parameters
clc; close all
sub_Close_All_Connections;

%% GUI
close all;
try; close(params.GUI.Handle); catch; end;

params = sub_AllSettings(experimental_filename);
params.Scope.averaging = 1;
params.Scope.channels = 4;
params.Debug = 0;

params.GUI.alpha = 'ABCD';
params.GUI.Handle = wellplate_GUI();
set(params.GUI.Handle, 'Name', 'Well Plate Experiment', 'MenuBar', 'None');

params.GUI.figmenu = uimenu(params.GUI.Handle, 'Label','Wellplate Commands');
params.GUI.Flags.Quit = 0;
uimenu(params.GUI.figmenu, 'Label', 'Cancel and Return To Origin', 'Callback', 'params.GUI.Flags.Quit = 1;');

movegui(params.GUI.Handle,'center')
set(params.GUI.Handle,'Visible','off');
set(params.GUI.Handle,'Visible','on');

wellz = [0 1 1 0 0] .* params.Plate.welldiameter;
wellx = [1 1 0 0 1] .* params.Plate.welldiameter;
wellr = params.Plate.welldiameter /2;

params.GUI.h_Details = findobj(params.GUI.Handle,'Tag','h_Details');
params.GUI.h_Status = findobj(params.GUI.Handle,'Tag','h_Status');
params.GUI.h_ExpFileName = findobj(params.GUI.Handle,'Tag','h_ExpFileName');
params.GUI.h_Progress_Well = findobj(params.GUI.Handle,'Tag','h_Progress_Well');
params.GUI.h_ProgressTotal = findobj(params.GUI.Handle,'Tag','h_ProgressTotal');
params.GUI.h_TotalTime = findobj(params.GUI.Handle,'Tag','h_TotalTime');
params.GUI.h_WellTime = findobj(params.GUI.Handle,'Tag','h_WellTime');
params.GUI.h_axes = findobj(params.GUI.Handle,'Tag','h_axes1');

params.GUI.Title = params.Name;

params.GUI.TimersEnabled = 0;
params.GUI.Status = 'Status: Loading Parameters';
params.GUI.Details = ' ';
sub_wellplate_UpdateGUI(params)

%% Connect to Stage and Signal Generator
params.GUI.Status = 'Status: Prepping I/O';
sub_wellplate_UpdateGUI(params)
if ~NoSG_Mode; params = sub_SG_Initialize(params); end
if ~NoStage_Mode; params = sub_Stage_Initialize(params); end
if ~NoScope_Mode; params = sub_Scope_Initialize(params); end

%% Ensure SG is turned off
if ~NoSG_Mode
    params = sub_SG_Stop(params);
end

%% Take Blank Scope Reading
% if ~NoScope_Mode
%     params.GUI.Status = 'Status: Taking Blank Scope Reading';
%     sub_wellplate_UpdateGUI(params)
%     params = sub_Scope_Readout_All(params);
%     params.Plate.Blank.Waveform.Ch2 = params.Scope.Ch2.YData;
%     params.Plate.Blank.Waveform.Ch3 = params.Scope.Ch3.YData;
%     params.Plate.Blank.Waveform.t = params.Scope.Ch3.XData;
% end

%% Load Excel Data
params.GUI.Status = 'Status: Loading Plate Data';
sub_wellplate_UpdateGUI(params)

[~,~,xls_data] = xlsread(params.Name);
xls_data(1,:) = []; % Remove headers

% First load all data from Excel
for i = 1:24

    e = struct;
    
    e.id = cell2mat(xls_data(i,2));
    e.freq = cell2mat(xls_data(i,3));
    e.pulse_duration = cell2mat(xls_data(i,4));
    e.peak_to_peak = cell2mat(xls_data(i,5));
    e.duty_cycle = cell2mat(xls_data(i,6));
    e.exposure_duration = cell2mat(xls_data(i,7));
    e.name = cell2mat(xls_data(i,8));     
    
    params.Plate.Excel(i) = e;
end

%% This code can be modified to allow randomization of sample placement
% As currently configured, the plate is not randomized
% To randomize, replace j = 1:24; with j = rand(24,1);

j = 1:24; 
%j = rand(24,1);
[~,J] = sort(j);

%% Draw GUI and prepare wells based on J scheme
% In this instance, J scheme is not randomized

for i = 1:24

    w = struct;
    
    n = i-1;
    w.well = [params.GUI.alpha(floor(n/6)+1) num2str(mod(n,6)+1)];
    w.id = params.Plate.Excel(J(i)).id;
    
    w.freq = params.Plate.Excel(J(i)).freq;
    w.pulse_duration = params.Plate.Excel(J(i)).pulse_duration;
    w.peak_to_peak = params.Plate.Excel(J(i)).peak_to_peak;
    w.duty_cycle = params.Plate.Excel(J(i)).duty_cycle;
    w.exposure_duration = params.Plate.Excel(J(i)).exposure_duration;
    w.name = params.Plate.Excel(J(i)).name;
    
    if NoStage_Mode || NoSG_Mode
        w.exposure_duration = 3; % Speed through settings in test mode
    end
    if numel(override_duration) == 1
         w.exposure_duration = override_duration;
    end
    
    x = floor(n/6) * params.Plate.welldistance ./ params.Stages.step_distance;
    z = mod(n,6) * params.Plate.welldistance ./ params.Stages.step_distance;
    
    w.coor(params.Stages.x_motor) = x;
    w.coor(params.Stages.y_motor) = 0;
    w.coor(params.Stages.z_motor) = z;
    
    params.Plate.Wells(i) = w;
       
    zm = z * params.Stages.step_distance;
    xm = params.Stages.step_distance.*x;
    
    if w.exposure_duration > 0 && w.peak_to_peak > 0 && w.freq > 0 && w.pulse_duration && ~any(ismember(skipwells, i))
       string = sprintf('%1.0f kHz\n%1.2f Vpp\nPD %1.2f ms\n DC %s \nDur %s s', ...
           w.freq/1000, ...
           w.peak_to_peak, ...
           w.pulse_duration*1000, ...
           num2str(w.duty_cycle), ...
           num2str(w.exposure_duration));
       
       well_c = [1 1 1];
    else
       string = w.name;
       well_c = [.5 .5 .5];
    end
    
    if isnumeric(string)
        string = [string ' '];
    end
    
    % Matlab version is R2016b

    fill(params.GUI.h_axes, zm + wellz, xm + wellx, well_c)
    hold(params.GUI.h_axes, 'on')

    params.GUI.h_WellProgressSqare(i) = ...
        fill(params.GUI.h_axes, zm + wellz * 0, xm + wellx, [0.6 0.6 1]);

    plot(params.GUI.h_axes, zm + wellz, xm + wellx, 'k-')
    set(params.GUI.h_axes, 'Ydir','reverse')
    axis(params.GUI.h_axes, 'equal')

    text(params.GUI.h_axes, zm + wellr, xm + wellr, string, ...
        'FontSize', 8, ...
        'VerticalAlignment', 'middle', ...
        'HorizontalAlignment', 'center', ...
        'Interpreter','none');

    axis(params.GUI.h_axes, 'off');
end

%% Code pauses here to allow any last minute protocol steps
% For example, can add saponin to positive control wells here
params.GUI.Status = 'LOAD POSITIVE CONTROL';
params.GUI.Details = 'Then press any key to continue';
sub_wellplate_UpdateGUI(params)

pause()

%% Prepare to run experiment

params.GUI.TotalTime = 0;
params.GUI.PriorWellTime = 0;
params.GUI.CurrentWellTime = 0;
params.GUI.CurrentWellTotalTime = 0;

indexes = [];
for i = 1:24
    w = params.Plate.Wells(i);
    if w.exposure_duration > 0 && w.peak_to_peak > 0 && w.freq > 0 && w.pulse_duration > 0 && ~any(ismember(skipwells, i))
        indexes(end+1)=i;
        params.GUI.TotalTime = params.GUI.TotalTime + w.exposure_duration;
        % Only run if any ultrasound exposure is indicated
    end
end

params.GUI.TimersEnabled = 1;

%% Run Experiment

for i=indexes
    if params.GUI.Flags.Quit == 1; break; end
    
    w = params.Plate.Wells(i);
    params.GUI.CurrentWellTotalTime = w.exposure_duration;
    
    % Move To Coordinates on Well Plate
    if ~NoStage_Mode; params = sub_Stage_Move_To(params, w.coor + params.Stages.Origin); end
          
    if ~NoSG_Mode;
        % Set Waveform Parameters on SG
        params.SG.Waveform.ch = 1;
        params.SG.Waveform.cycles = w.pulse_duration * w.freq;
        params.SG.Waveform.period = w.pulse_duration / w.duty_cycle; 
        params.SG.Waveform.frequency = w.freq;
        params.SG.Waveform.voltage = w.peak_to_peak * 10^(-params.Amplifier.GainDB/20);

        params = sub_SG_ApplySettings(params);
        params = sub_SG_Start(params);  % Start SG
    end;
    
    if ~NoScope_Mode
        params.Scope.Settings.TimeRange =  0.9 * params.SG.Waveform.period;
        params.Scope.Settings.Position = 0.4 * params.SG.Waveform.period;
        params = sub_Scope_ApplySettings(params);
    end
    
    h_tic = tic;
    
    % Update GUI
    n = i-1;
    wellstr = ['Well ' params.GUI.alpha(floor(n/6)+1) num2str(mod(n,6)+1)];
    params.GUI.Status = [wellstr ': Ultrasound'];
    
    % Motor steps for each zigzag
    zigzag_diag_disp = 0; %50;
    z3 = zigzag_diag_disp * cosd(20);
    z1 = zigzag_diag_disp * sind(20);
    zigzag_diag_vec = [-z1, 0, z3];
    zigzag_diag = 0;
    
    zigzag_horiz_disp = 0; %50;
    zigzag_hoirz_vec = [0, zigzag_horiz_disp, 0];
    zigzag_horiz = 0;
    
    continueflag = 1;
    while continueflag
        
        continueflag = toc(h_tic) < w.exposure_duration;
        if params.GUI.Flags.Quit == 1; 
            continueflag = 0;
        end
        
        offset = [0 0 0];

        if zigzag_diag == 0
            zigzag_diag = 1;
            offset = offset + 0.0 * zigzag_diag_vec;
            
        elseif zigzag_diag == 1
            zigzag_diag = 2;
            offset = offset + 0.5 * zigzag_diag_vec;
            
        elseif zigzag_diag == 2
            zigzag_diag = 3;
            offset = offset + 1.0 * zigzag_diag_vec;
            
        elseif zigzag_diag == 3
            zigzag_diag = 4;
            offset = offset + 1.5 * zigzag_diag_vec;
            
        else
            zigzag_diag = 0;
            offset = offset + 2.0 * zigzag_diag_vec;
        end
        
        if zigzag_horiz == 0
            zigzag_horiz = 1;
            offset = offset + 0.5 * zigzag_hoirz_vec;
        elseif zigzag_horiz == 1
            zigzag_horiz = 2;
            offset = offset + 0.0 * zigzag_hoirz_vec;
        else
            zigzag_horiz = 0;
            offset = offset - 0.5 * zigzag_hoirz_vec;
        end
        
        if ~NoStage_Mode; 
            params.Stages.Speed = 500;
            params = sub_Stage_Move_To(params, w.coor + params.Stages.Origin + offset); 
            params.Stages.Speed = 2000;
        end
        
        zm = mod(n,6) * params.Plate.welldistance;

        progress_fraction = min(toc(h_tic) / w.exposure_duration, 1);
        set(params.GUI.h_WellProgressSqare(i), 'XData', zm + wellz .* progress_fraction)
        
        params.GUI.CurrentWellTime = toc(h_tic);
        params.GUI.Details = sprintf([...
            'ID: %s \n' ... 
            '   Frequency (Hz): %s \n' ... 
            '   Pulse Duration (s): %s \n' ... 
            '   Peak-to-Peak (V): %s \n' ... 
            '   Duty Cycle (): %s \n' ... 
            '   Exposure Duration (s): %s'], ... 
            num2str(w.id), ...
            num2str(w.freq), ...
            num2str(w.pulse_duration), ...
            num2str(w.peak_to_peak), ...
            num2str(w.duty_cycle), ...
            num2str(w.exposure_duration));
        
        sub_wellplate_UpdateGUI(params)
    end
    
    if ~NoScope_Mode;
        params = sub_Scope_Readout_All(params);
        params.Plate.Wells(i).Waveform.Hydrophone = params.Scope.Ch(4).YData;
        params.Plate.Wells(i).Waveform.t = params.Scope.Ch(4).XData;
        params = sub_Scope_Run(params);
    end
    
    if ~NoSG_Mode; params = sub_SG_Stop(params); end; % Stop SG
    
%     if w.exposure_duration > 60
%         params.GUI.Status = [wellstr ': Transducer Cooldown, pause 10 sec'];
%         sub_wellplate_UpdateGUI(params);
%         drawnow;
%         pause(10); 
%     end
    
    params.GUI.CurrentWellTime = params.GUI.CurrentWellTotalTime;
    params.GUI.Status = [wellstr ': Moving to Next Well'];
    sub_wellplate_UpdateGUI(params)
    
    params.GUI.PriorWellTime = params.GUI.PriorWellTime + w.exposure_duration;
        
end

%% Finish Experiment

disp(['Finished at ' datestr(now)]);
% Return stage to origin
if ~NoStage_Mode; params = sub_Stage_Move_To(params,params.Stages.Origin); end

%% Save the code form this script in params file
try
    IO = fopen([mfilename '.m'],'r');
    params.ScriptCode = textscan(IO,'%s','Delimiter','\n'); 
    fclose(IO);
    clear IO;
catch
    disp('Could not save a copy of script code in params file')
end
%% Data Management

if params.GUI.Flags.Quit ~= 1; 
 fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
 mkdir(fld);
 save([fld '\experiment_' params.Name(strfind(params.Name,'\')+1:strfind(params.Name,'.xlsx')-1) '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.mat'], 'params')
end

% Close GUI
close all;
close(params.GUI.Handle);
params = rmfield(params, 'GUI');
