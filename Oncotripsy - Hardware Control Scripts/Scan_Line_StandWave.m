%% Prepare Parameters Variable
params = sub_AllSettings('Scan_Line_StandWave');

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
params.Scope.averaging = 128;
params = sub_Scope_Initialize(params);
params = sub_Stage_Initialize(params);

%% Setup GUI
GUI.fig = figure(1); clf;
GUI.scatter = scatter3([],[],[],[]);
xlabel('X (mm)'); set(gca,'XDir','Reverse');
ylabel('Y (mm)'); set(gca,'ZDir','Reverse');
zlabel('Z (mm)'); set(gca,'YDir','Reverse');
cb = colorbar; cb.Label.String = 'Hydrophone Channel (mVpp)';

GUI.fig5 = figure(5); clf
GUI.A2 = plot(0,0,'b'); hold on
GUI.A3 = plot(0,0,'r');
GUI.A2pk = plot(0,0,'bv');
GUI.A3pk = plot(0,0,'rv'); 

%% Search
params.Scan = struct();

%step_ds = 0.0001 / params.Stages.step_distance;
%step_tot = 450;

step_ds    = 0.000125 / params.Stages.step_distance; % Motor steps between each scan
dim1_width = 0.01 / params.Stages.step_distance; 
step_tot = floor(dim1_width / step_ds); % Total number of scans on this dimension


params.Scan.dim1 = params.Stages.z_motor;
params.Scan.step_ds = step_ds;
params.Scan.step_tot = step_tot;

i = 0;
       


sub_Stage_Move(params, params.Scan.dim1, -step_ds*step_tot/2);

for s1 = 1:step_tot

        pause(0.2); % Wait for signal to level out
        params = sub_Stage_Update_Positions(params);
        params.Scope.channels = [2 4];
        params = sub_Scope_Readout_All(params);

        i = i+1;
        params.Scan.Location(:,i) = params.Stages.Position;

        A2 = params.Scope.Ch(2).YData; A2 = A2 - mean(A2); A2 = A2 ./ max(A2); A2(A2<-1)=-1;
        A3 = params.Scope.Ch(4).YData; A3 = A3 - mean(A3); A3 = A3 ./ max(A3); A3(A3<-1)=-1;
        t = params.Scope.Ch(2).XData;

        [pk2, tpk2] = findpeaks(A2,t,'MinPeakDistance',0.5/params.Transducer_Fc, 'MinPeakHeight',0.1);
        [pk3, tpk3] = findpeaks(A3,t,'MinPeakDistance',0.5/params.Transducer_Fc, 'MinPeakHeight',0.1);

        t_dist = tpk3(1) - tpk2(1);

        params.Scan.Distance(i) = t_dist * params.Acoustic.MediumAcousticSpeed;

        A = params.Scope.Ch(4).YData; A = A - mean(A);
        t = params.Scope.Ch(4).XData;

        fs = 1/(t(2)-t(1)); %Sampling frequency
        fft_pts = length(t); % Nb points

        w = (0:fft_pts-1)./fft_pts.*fs;
        w0 = params.Transducer_Fc;
        w_I = find(w>=w0,1,'first');

        Aw = fft(A);
        w_I = find(w>=w0,1,'first');
        w_I1 = find(w>=0.75 * w0,1,'first');
        w_I2 = find(w>=1.25 * w0,1,'first');
        %params.Scan.Objective(i) = trapz(A_clp.^2); %trapz(abs(Aw(w_I1:w_I2)));  

        %params.Scan.Objective(i) = trapz(abs(Aw(w_I1:w_I2)));
        params.Scan.Objective(i) = (max(A) - min(A));
        params.Results.Waveforms(i) = sub_Data_CompressWaveform(params.Scope.Ch(4));
        
        disp(sprintf('Scan %3.0f: X=%1.0f Y=%1.0f Z=%1.0f    P = %1.3e', i, params.Scan.Location(params.Stages.x_motor,i), params.Scan.Location(params.Stages.y_motor,i), params.Scan.Location(params.Stages.z_motor,i), params.Scan.Objective(i)))

        set(GUI.scatter, 'XData', 1000*(params.Scan.Location(params.Stages.x_motor,:) - params.Stages.Origin(params.Stages.x_motor)).*params.Stages.step_distance)
        set(GUI.scatter, 'YData', 1000*(params.Scan.Location(params.Stages.y_motor,:) - params.Stages.Origin(params.Stages.y_motor)).*params.Stages.step_distance)
        set(GUI.scatter, 'ZData', 1000*(params.Scan.Location(params.Stages.z_motor,:) - params.Stages.Origin(params.Stages.z_motor)).*params.Stages.step_distance)
        set(GUI.scatter, 'CData', 1000*params.Scan.Objective)  

        set(GUI.line, 'XData', params.Scan.Distance);
        set(GUI.line, 'YData', params.Scan.Objective);

        set(GUI.line3, 'XData', params.Scan.Distance);
        set(GUI.line3, 'YData', params.Scan.Location(params.Scan.dim1,:));

        set(GUI.A2, 'XData', t);
        set(GUI.A2, 'YData', A2);
        set(GUI.A3, 'XData', t);
        set(GUI.A3, 'YData', A3);
        set(GUI.A2pk, 'XData', tpk2);
        set(GUI.A2pk, 'YData', pk2);
        set(GUI.A3pk, 'XData', tpk3);
        set(GUI.A3pk, 'YData', pk3); 

        sub_Stage_Move(params, params.Scan.dim1, step_ds);
end         
           
sub_Stage_Move_To(params, params.Stages.Origin);

params = sub_Stage_Update_Positions(params);


%% Close All Connections
sub_Close_All_Connections;

%% Data Management
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
save([fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.mat'], 'params')

%% Graphs

t = params.Scope.Ch(4).XData;
y = (0:params.Scan.step_ds:(params.Scan.step_tot-1)*params.Scan.step_ds) * params.Stages.step_distance;
t_N = numel(t);
y_N = numel(params.Results.Waveforms);

M = zeros(t_N,y_N);

for i = 1:y_N
    M(:,i) = params.Results.Waveforms(i).YData;
end

M_max = max(abs(M(:)));
figure(10); clf;
subplot(311)
plot(t*1e6,params.Scope.Ch(2).YData)

subplot(312)
imagesc(y*1e3,t*1e6,abs(M),[0, M_max])
colorbar
xlabel('Distance (mm)')
ylabel('Time (us)')

subplot(313)
plot(y*1e3,max(abs(M),[],1)')
colorbar
xlabel('Distance (mm)')
ylabel('Max Pressure in Line')
yl = ylim;
ylim([0, yl(2)])

subplot(311)
title([params.Name ' ' params.Time], 'Interpreter', 'None');

fsize = [4 6];
set(10,'PaperUnits','inches');
set(10,'PaperSize',fsize);
set(10,'PaperPositionMode','manual');
set(10,'PaperPosition', [0 0 fsize(1) fsize(2)]);
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
print(10, '-dpng', [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.png']);