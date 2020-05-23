% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Moves motor stage in 3 dimensions to ascend the gradient to a local maximum
% Attention!  Monitor the hydrophone used to measure pressure here, this script may cause
% the transducer to directly collide with the transducer!

% Motor Stage - must be set near the focal point
%
% Function Generator must be manually set at center frequency
% - Run on repeat with timer at 1 ms, for 10 cycles
%
% Oscilloscope - must be configured to be able to see the waveform from the
% hydrophone on Ch 3

%% Scan Values

step_ds = 100; % Motor units in each step

step_tot = 40; % Number of steps to progress in each dimension

runs = 5; % Number of repeats for each set of dimensions


%% Prepare Parameters Variable
sub_Close_All_Connections;
params = sub_AllSettings('Scan_FindMax_v4');
params.Scope.averaging = 128;
params.Debug = 0;

%% Initialize Hardware Interfaces
params = sub_Scope_Initialize(params);
params = sub_Stage_Initialize(params);

%% Setup GUI
GUI.fig = figure(1); clf;
set(GUI.fig, 'MenuBar', 'None', 'Name', params.NameFull);
GUI.figmenu = uimenu(GUI.fig, 'Label','Scan_FindMax Commands');

GUI.Flags.Quit = 0;
GUI.Flags.BackToOrigin = 0;
GUI.Flags.MoveToMax = 0;

uimenu(GUI.figmenu, 'Label', 'Stop Search', 'Callback', 'GUI.Flags.Quit = 1;');
uimenu(GUI.figmenu, 'Label', 'Stop Search and Move To Max', 'Callback', 'GUI.Flags.Quit = 1; GUI.Flags.MoveToMax = 1;');
uimenu(GUI.figmenu, 'Label', 'Stop Search and Return to Origin', 'Callback', 'GUI.Flags.Quit = 1; GUI.Flags.BackToOrigin = 1;');

subplot(4,2,1:2);
GUI.progressgraph = plot(0,0,'k-o');
hold on;
GUI.progressmax = plot(0,0,'ro');
xlabel('Scan Number');
ylabel('mVpp')

subplot(4,2,3:6)
GUI.scatter = scatter3([],[],[],[]);
xlabel('X (mm)'); set(gca,'XDir','Reverse');
ylabel('Y (mm)'); set(gca,'ZDir','Reverse');
zlabel('Z (mm)'); set(gca,'YDir','Reverse');
cb = colorbar; cb.Label.String = 'Hydrophone (mVpp)';
axis square

subplot(4,2,7)
GUI.scopegraph = plot(0, 0, 'k-');
xlabel('Time (s)');

subplot(4,2,8); hold on;
GUI.fftgraph = plot(0, 0, 'k-');
GUI.fftgraph_foc = plot(0, 0, 'ro');
xlim([0 params.Transducer_Fc * 2])
xlabel('Frequency (Hz)');

%% Search
params.Scope.channels = 4;

params.Scan = struct();

dims = zeros(3,3);

% Search along x axis
dims(1, params.Stages.x_motor) = 1;
dims(1, params.Stages.y_motor) = 0;
dims(1, params.Stages.y_motor) = 0;

% Search on y-z plane considering that the transducer is aligned 30 degrees
% off of the y-axis

angle = 15; %15;
% Axial motion of the transducer relative to needle
dims(2, params.Stages.x_motor) = 0;
dims(2, params.Stages.y_motor) = cos(deg2rad(angle));
dims(2, params.Stages.z_motor) = -sin(deg2rad(angle));

% Lateral motion of transducer relative to needle
dims(3, params.Stages.x_motor) = 0;
dims(3, params.Stages.y_motor) = sin(deg2rad(angle));
dims(3, params.Stages.z_motor) = cos(deg2rad(angle));

i = 0; 
tic;

for run = 1:runs
    if GUI.Flags.Quit == 1; break; end
    
    for dim = 1:3
        if GUI.Flags.Quit == 1; break; end
        
    % Search along each dimension
    
        step_ds_run = step_ds; % * (0.75 ^ floor((runs-1)/2));
        
        uvec = dims(dim,:); % Unit vector
        
        params = sub_Stage_Move_Vec(params, uvec .* -step_ds_run*step_tot/2);
        i_dim = i;
        
        centered = 0;
        
        while ~centered
            if GUI.Flags.Quit == 1; break; end
            
            for s = 1:step_tot
                if GUI.Flags.Quit == 1; break; end
                
                i = i+1;
                
                pause(0.2); % Wait for signal to level out

                params = sub_Stage_Update_Positions(params);
                params = sub_Scope_Readout_All(params);

                params.Scan.Location(:,i) = params.Stages.Position;

                t = params.Scope.Ch(params.Scope.channels).XData;
                A = params.Scope.Ch(params.Scope.channels).YData; 
                A = A - mean(A);
                
                fs = 1/(t(2)-t(1)); %Sampling frequency
                fft_pts = length(t); % Nb points

                w = (0:fft_pts-1)./fft_pts.*fs;
                w0 = params.Transducer_Fc;   
                Aw = fft(A);
                
                w_I = find(w>=w0,1,'first');
                
                params.Scan.Objective(i) = abs(Aw(w_I));
                %params.Scan.Objective(i) = (max(A) - min(A)) * 1000;
                
                dx = params.Scan.Location(params.Stages.x_motor,i) - params.Stages.Origin(params.Stages.x_motor);
                dy = params.Scan.Location(params.Stages.y_motor,i) - params.Stages.Origin(params.Stages.y_motor);
                dz = params.Scan.Location(params.Stages.z_motor,i) - params.Stages.Origin(params.Stages.z_motor);
                
                str = sprintf('Scan %3.0f (%+1.3f, %+1.3f, %+1.3f mm): %1.1f mVpp', i, dx * 1000 * params.Stages.step_distance, dy * 1000 * params.Stages.step_distance, dz * 1000 * params.Stages.step_distance, params.Scan.Objective(i));
                if params.Scan.Objective(i) == max(params.Scan.Objective)
                    str = [str '   NEW MAX'];
                end
                disp(str);
                    
                [o_max, i_max] = max(params.Scan.Objective);
                
                set(GUI.scatter, 'XData', (params.Scan.Location(params.Stages.x_motor,:) - params.Stages.Origin(params.Stages.x_motor)).*1000.*params.Stages.step_distance)
                set(GUI.scatter, 'YData', (params.Scan.Location(params.Stages.y_motor,:) - params.Stages.Origin(params.Stages.y_motor)).*1000.*params.Stages.step_distance)
                set(GUI.scatter, 'ZData', (params.Scan.Location(params.Stages.z_motor,:) - params.Stages.Origin(params.Stages.z_motor)).*1000.*params.Stages.step_distance)
                set(GUI.scatter, 'CData', params.Scan.Objective)  

                set(GUI.scopegraph, 'XData', t);
                set(GUI.scopegraph, 'YData', A);
                
                set(GUI.progressgraph, 'XData', 1:numel(params.Scan.Objective));
                set(GUI.progressgraph, 'YData', params.Scan.Objective);
                set(GUI.progressmax, 'XData', i_max)
                set(GUI.progressmax, 'YData', o_max)
                               
                set(GUI.fftgraph, 'XData', w(1:floor(numel(w)/2)));
                set(GUI.fftgraph, 'YData', abs(Aw(1:floor(numel(w)/2))));
                
                set(GUI.fftgraph_foc, 'XData', w(w_I));
                set(GUI.fftgraph_foc, 'YData', abs(Aw(w_I)));
                
                params = sub_Stage_Move_Vec(params, uvec .* step_ds_run);
                params = sub_Stage_Update_Positions(params);

            end
          
            if GUI.Flags.Quit == 0; 
            [~, i_max] = max(params.Scan.Objective); % Find location of maximum pressure
            disp(sprintf('Moving to Location %1.0f', i_max))
            params = sub_Stage_Move_To(params, params.Scan.Location(:, i_max));
                        
            if i_max == i
                % Maximum value found at the last point examined, so 
                % continue scanning in this direction
                centered = 0;
                params = sub_Stage_Move_Vec(params, uvec * step_ds_run);
                i_dim = i;
                
            elseif i_max == i_dim + 1
                % Maximum value found at the first point examined, so now 
                % that we have moved back to the first point, move an 
                % entire scan frame further back and continue scanning
                centered = 0;
                params = sub_Stage_Move_Vec(params, uvec .* -step_ds_run*step_tot);
                i_dim = i;
                
            else
                centered = 1;
                
            end
            end
            
        end
    end
         step_ds = step_ds*0.85;        
       
end

if GUI.Flags.BackToOrigin
    disp('Moving to Origin')
    params = sub_Stage_Move_To(params, params.Stages.Origin);
    
elseif GUI.Flags.MoveToMax
    [~, i_max] = max(params.Scan.Objective); % Find location of maximum pressure
    disp(sprintf('Moving to Location %1.0f', i_max))
    params = sub_Stage_Move_To(params, params.Scan.Location(:, i_max));
end

disp(['Finished at ' datestr(now)]);
set(GUI.figmenu, 'Label', ['Finished at ' datestr(now)], 'Enable', 'off');

%% Close Down the Connections

params = sub_Scope_Run(params); % Set scope to show live image
sub_Close_All_Connections;