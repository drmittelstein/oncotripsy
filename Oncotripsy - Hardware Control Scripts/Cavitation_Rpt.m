% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Measure scattered signal from cavitating sample
% Acquires multiple pulses of signal

% Configuration with FUS Tx and Cavitation Detector Tx co-aligned on target

% Cable Connections
% SG Ch 1 <-> Scope Ext Trg <-> SG Ext Trig
% SG Ch 2 <-> Amp In
% Amp Out <-> FUS Tx
% Cavitation Detector Tx <-> Scope Ch 4

sub_Close_All_Connections;
clearvars;

params = sub_AllSettings('Cavitation_Rpt');
params.Scope.averaging = 1;
params.Scope.channels = 4;

params = sub_Scope_Initialize(params);
params = sub_SG_Initialize(params);

fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
ttl = [params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM-SS')];
fname = [fld '\results_' ttl '.mat'];
dname = [fname(1:end-4) '.dat'];
iname = [fname(1:end-4) '.gif'];
i1name = [fname(1:end-4) '.png'];
i2name = [fname(1:end-4) '_Energy.png'];

fprintf(params.Scope.visaObj, ':TRIG:SOURCE EXT');
fprintf(params.Scope.visaObj, ':TRIG:HOLD 9')
fprintf(params.Scope.visaObj, ':MEAS:CLE');
fprintf(params.Scope.visaObj, ':TRIGger:EDGE:LEVel: 0.5')
fprintf(params.Scope.visaObj, ':ACQuire:MODE RTIMe');
fprintf(params.Scope.visaObj, ':TRIGger:EDGE:Source EXTernal');
fprintf(params.Scope.visaObj, ':CHANnel1:DISPlay OFF');
fprintf(params.Scope.visaObj, ':CHANnel2:DISPlay OFF');
fprintf(params.Scope.visaObj, ':CHANnel3:DISPlay OFF');
fprintf(params.Scope.visaObj, ':CHANnel4:DISPlay ON');
fprintf(params.Scope.visaObj, ':CHANnel4:SCALe 5mV');
fprintf(params.Scope.visaObj, ':CHANnel4:IMPedance ONEMeg');

t_PD = 0.1;
LimitSG = 0;

params.SG.Waveform.ch = 1;

params.SG.Waveform.frequency = 4.94E+05;
params.SG.Waveform.voltage = 49.97 * 10^(-params.Amplifier.GainDB/20);

params.SG.Waveform.cycles = params.SG.Waveform.frequency * t_PD;
params.SG.Waveform.period = t_PD * 10;
params.SG.Waveform.repeats = 1;
params.SG.LimitSG = LimitSG;

params.Scope.Settings.Position = t_PD / 2;  
params.Scope.Settings.TimeRange = t_PD;
params = sub_Scope_ApplySettings(params);

h_tic = tic;

params = sub_SG_Stop(params);
pause(0.5)
if LimitSG
    params = sub_SG_ApplySettingsForTrigger(params);
else
    params = sub_SG_ApplySettings(params);
end
pause(1)
params = sub_SG_Start(params);
pause(2);

close all;
fig1 = figure(1); clf;
set(fig1, 'Color', 'w', 'Units', 'inches', 'Position', [0 0 4 6]);

fig2 = figure(2); clf;
set(fig2, 'Color', 'w', 'Units', 'inches', 'Position', [0 7 4 3]);

NUMRPT = 20;

for j = 1:NUMRPT
 
    params.Scope.ArmTrigger = 1;
    params = sub_Scope_Readout_HQ(params); % Because ArmTrigger = 1, this will cause the Tabor to trigger   
    params.Results.TimeOfAq(j) = toc(h_tic);
    
    disp(sprintf('%1.0f - %1.2f s', j, params.Results.TimeOfAq(j)));
    
    params.Results.waveforms{j} = sub_Data_CompressWaveform(params.Scope.Ch(4));
    
	t = params.Scope.Ch(4).XData;
    A = params.Scope.Ch(4).YData; 
    A = A - mean(A);
    
    dt_sample = 0.00005;

    t_sample = 0:dt_sample:t_PD-dt_sample;
    n = numel(t_sample);

    tn_sub = floor(numel(t) / n);
    fs = 1/(t(2)-t(1)); %Sampling frequency
    fft_pts = tn_sub; % Nb points
    w = (0:fft_pts-1)./fft_pts.*fs;
    i_plot = 50:floor(numel(w)/2);
    
    w = w(i_plot);
    
    data = zeros(n, numel(i_plot));

    for i = 0:n-1
        indices = (1 + i * tn_sub) : ((i+1)* tn_sub);

        A_sub = A(indices);
        Aw = abs(fft(A_sub));

        data(i+1,:) = Aw(i_plot);

    end
    
        params.Results.WaveEnergy(j) = sum(A.^2);
    
     figure(2); 
     hold off;
     for i = 1:j
     scatter(i, 10*log10(params.Results.WaveEnergy(i)), 25, [1-i/20,0,0])
     hold on;
     end
     
     xlabel('Pulse Number');
     ylabel('PCD Signal Energy (dB)');
     title(ttl, 'Interpreter','none');

     figure(1);
     subplot(311);
     plot(t * 1000,A);
     xlabel('Time (ms)')
     ylabel('PCD signal');
     ylim([-0.03 0.03]);
     xlim([0 t_PD * 1000]);
     title(ttl, 'Interpreter','none');

     subplot(312);
     imagesc(t_sample * 1000, w/1e6, 20*log10(data')); 
     ylabel('Freq (MHz)'); 
     xlabel('Time (ms)');
     c = colorbar;
     c.Label.String = 'dB';
     c.Location = 'NorthOutside';
     set(gca,'CLim',[-50 50]) % dB Range

     subplot(313); plot(t_sample * 1000, sum(20*log10(data),2));
     xlabel('Time (ms)');
     ylabel('Sum of dB');

     drawnow();
    
           frame = getframe(gcf); 
      im = frame2im(frame); 
      [imind, cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if j == 1 
          imwrite(imind,cm,iname,'gif', 'Loopcount',1,'DelayTime',1/3); 
          imwrite(imind,cm,i1name,'png'); 
      else 
          imwrite(imind,cm,iname,'gif','WriteMode','append','DelayTime',1/3); 
      end 
     
    % Progress Notification Sound
    sound(sin(2*pi*250*(0:1/8192:0.2)))
    pause(0.2)
      
end

figure(2);
frame = getframe(gcf); 
im = frame2im(frame); 
[imind, cm] = rgb2ind(im,256); 
imwrite(imind,cm,i2name,'png'); 

%% Save the code form this script in params file
try
    IO = fopen([mfilename '.m'],'r');
    params.ScriptCode = textscan(IO,'%s','Delimiter','\n'); 
    fclose(IO);
    clear IO;
catch
    disp('Could not save a copy of script code in params file')
end


%% Close All Connections
fprintf(params.Scope.visaObj, ':TIMebase:MODE ROLL')
fprintf(params.Scope.visaObj, ':RUN')

params = sub_SG_Stop(params);
sub_Close_All_Connections;

%% Save Results
disp('Saving data');
params = rmfield(params, 'Scope');

fileID = fopen(dname, 'w');
eng = 0;
f2eng = 0;
for j = 1:numel(params.Results.waveforms)
    y = params.Results.waveforms{j}.YData(:);
    y = y - mean(y);
    eng = eng +  sum(y.^ 2);
    
    dt = params.Results.waveforms{j}.XDataComp.dt;
    t = (1:numel(y)) * dt;
    fs = 1/(t(2)-t(1));
    fft_pts = numel(y);
    w = (0:fft_pts-1)./fft_pts.*fs;
    Aw = fft(y);
    
    i1 = find(w>1e6, 1, 'first');
    i2 = find(w>max(w)/2, 1, 'first');

    f2eng = f2eng + mean(abs(Aw(i1:i2).^2));
    
end
fprintf(fileID, '%s\t%1.3f\t%1.3f', ttl, eng, f2eng);
fclose(fileID);
disp(sprintf('- All   Energy: %1.2f', eng));
disp(sprintf('- F>2F0 Energy: %1.2f', f2eng));

a = whos('params');
clear A t data A_sub Aw indices i_plot w t_sample FFT

disp(sprintf('- Saving Data (%1.0f MB)', a.bytes/(1e6)));
disp(['- ' ttl]);
disp('- Please wait...');
save(fname, 'params', '-v7.3')
disp('- Done!');

% Completion Sound
sound(sin(2*pi*400*(0:1/8192:0.5)))

clearvars
