% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Transducer Response Script
% Cycles through a set of voltages and frequencies to determine the
% transducer response to signal generator signal using a hydrophone setup.

sub_Close_All_Connections;

if ~exist('resume', 'var')
    resume = 0;
    % This resume value will be 1 if this script ever crashes
    % This will allow us to resume from the crash point without losing old
    % data
end

if ~resume

%% Prepare Parameters Variable
params = sub_AllSettings('Scan_TransducerResponse');
fulldata = struct(); % This structure will contain all raw data from all scans

end;

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
params.Scope.averaging = 1024;
params = sub_Scope_Initialize(params);
params = sub_SG_Initialize(params);
disp(' ');

%% INPUT VARIABLES FOR TRIAL


% Hydrophone to use (the name of the probe, starting from SNFP), all caps
% This name must be the precise name as in the calibration file
params.hydrophone_notes_model = 'FOH44 + FP214-02T';
params.hydrophone_notes_mV_per_MPa = 138;


params.hydrophone_name = 'FLAT';
load('Hydrophone_Calibration_Data_2017_Mar.mat');
params.hydrophone_calibration = eval(params.hydrophone_name);

% Bandwidth / Voltage Scan Parameters (Hz, V)
params.Freq_Vol.frequencies = (4.82)*(1e5); 
params.Freq_Vol.voltages = (0.5:0.5:65) .* 10^(params.Amplifier.GainDB/-20);

params.SG.FrequencyOveride = 1;

fulldata.Freq_Vol = params.Freq_Vol;

%% GUI

params.GUI.BWfig = figure(1); clf;
subplot(3,2,1:4);  hold on;

if numel(params.Freq_Vol.frequencies) > 1
    leg = cell(numel(params.Freq_Vol.voltages),1);
    colors = 'rygcbmk'; 
    colors = [colors colors colors colors colors colors];
    for b = 1:numel(params.Freq_Vol.voltages)
        params.GUI.BWfig_plt(b) = plot(params.Freq_Vol.frequencies, params.Freq_Vol.frequencies .* 0, [colors(mod(b,numel(colors))+1) 'o:']);
        leg(b) = mat2cell(sprintf('V = %1.1f V',params.Freq_Vol.voltages(b) .* 10^(params.Amplifier.GainDB/20)),1);
    end
    legend(leg)
else
    v = [params.Freq_Vol.voltages] * 10^(params.Amplifier.GainDB/20);
    
    params.GUI.Vplt = plot([0 v],[0 v .*0],'ko:'); hold on;
    
    xlabel('Voltage (V)')
    ylabel(sprintf('%s PNP (Pa)', params.hydrophone_name), 'Interpreter', 'none')
    legend(sprintf('f = %1.0f Hz',params.Freq_Vol.frequencies(1)));
    
end

ylabel(sprintf('%s PNP (Pa)', params.hydrophone_name), 'Interpreter', 'none')


subplot(3,2,5)
params.GUI.scopegraph = plot(0, 0, 'k-');
ylabel('Pressure (Pa)')
xlabel('Time (s)');

subplot(3,2,6); hold on;
params.GUI.fftgraph = plot(0, 0, 'k-');
xlim([0.9*min(params.Freq_Vol.frequencies), 1.1*max(params.Freq_Vol.frequencies)])
xlabel('Frequency (Hz)');
params.GUI.ffttext = text(0,0,'0 kHz');

%% Setup the Initial SG Parameters
params.SG.Waveform.ch = 1;
params.SG.Waveform.frequency = median(params.Freq_Vol.frequencies);
params.SG.Waveform.voltage = min(params.Freq_Vol.voltages);

cycles = params.SG.Waveform.frequency * 0.0001;
params.SG.Waveform.period = cycles / params.SG.Waveform.frequency * 10;
params.SG.Waveform.cycles = cycles;
    
%% Perform the Frequency / Voltage Scan

f_tot = numel(params.Freq_Vol.frequencies);
v_tot = numel(params.Freq_Vol.voltages);

if ~resume
params.Results.PNP = zeros(f_tot, v_tot);
params.Results.PII = zeros(f_tot, v_tot);
params.Results.Isspa = zeros(f_tot, v_tot);
end

resume = 1;
% Set resume to 1 that way we do not delete any collected data until
% program is complete


% Take blank read
sub_SG_Stop(params);
pause(2); % Pause to ensure signal updates
params.Scope.channels = [2 4];
params = sub_Scope_Readout_All(params);
fulldata.c2_blank = params.Scope.Ch(2).YData;
fulldata.c4_blank = params.Scope.Ch(4).YData;
fulldata.t_blank = params.Scope.Ch(4).XData;
t_clp = fulldata.t_blank;
A_clp = fulldata.c4_blank; A_clp = A_clp - mean(A_clp);

HP_calcs = sub_Data_Hydrophone_Curve(t_clp, A_clp, params.hydrophone_calibration);    
%[pk3, tpk3] = findpeaks(HP_calcs.pressure,t_clp,'MinPeakDistance',0.8/params.Transducer_Fc, 'MinPeakHeight',0.3 .* max(HP_calcs.pressure));

params.Results.PNP0 = mean(HP_calcs.pressure);
%params.Results.PII0 = trapz(HP_calcs.time, (HP_calcs.pressure.^2)./params.Acoustic.Z);


steps_performed = 0;
steps_total = f_tot * v_tot;

h_tic = tic;

for f_i = 1:f_tot;
    for v_i = 1:v_tot;
        steps_performed = steps_performed + 1;
        if params.Results.PNP(f_i,v_i) == 0;
        

        
        f = params.Freq_Vol.frequencies(f_i); % Frequency to evaluate
        v = params.Freq_Vol.voltages(v_i); % Frequency to evaluate
        
        disp(['Frequency - ' num2str(f) ', Voltage - ' num2str(v)]);
        disp(['Step - ' num2str(steps_performed) ' out of ' num2str(steps_total)]);
        
        params.SG.Waveform.frequency=f;
        params.SG.Waveform.voltage=v;
        cycles = params.SG.Waveform.frequency * 0.0001;
        params.SG.Waveform.period = cycles / params.SG.Waveform.frequency * 10;
        params.SG.Waveform.cycles = cycles;
        
        % Start SG
        params = sub_SG_ApplySettings(params);
        sub_SG_Start(params);
        pause(2); % Pause to ensure signal updates
        
        % Read out value from Oscilloscope
        params.Scope.channels = [2 4]; 
        params = sub_Scope_Readout_All(params);
        sub_SG_Stop(params);
        
        % Save all readings into full data structure
        fulldata.f(f_i, v_i) = f;
        fulldata.v(f_i, v_i) = v;
        fulldata.c2(f_i,v_i,:) = params.Scope.Ch(2).YData;
        fulldata.c4(f_i,v_i,:) = params.Scope.Ch(4).YData;
        fulldata.t(f_i,v_i,:) = params.Scope.Ch(4).XData;
        
        
        
        
            
        fs = 1/(params.Scope.Ch(4).XData(2)-params.Scope.Ch(4).XData(1)); %Sampling frequency
        fft_pts = length(params.Scope.Ch(4).XData); % Nb points
        w = (0:fft_pts-1)./fft_pts.*fs;
        A2w = fft(params.Scope.Ch(2).YData);
        A3w = fft(params.Scope.Ch(4).YData);  
         
        t_clp = params.Scope.Ch(4).XData;
        A_clp = params.Scope.Ch(4).YData; 
        A_clp = A_clp - mean(A_clp); % Read and remove DC offset

        
        HP_calcs = sub_Data_Hydrophone_Curve(t_clp, A_clp, params.hydrophone_calibration);
        
        set(params.GUI.scopegraph, 'XData', t_clp);
        set(params.GUI.scopegraph, 'YData', HP_calcs.pressure);
                               
        set(params.GUI.fftgraph, 'XData', w(1:floor(numel(w)/2)));
        set(params.GUI.fftgraph, 'YData', abs(A3w(1:floor(numel(w)/2))));
        [~, i_fpk] = max(abs(A3w(1:floor(numel(w)/2))));
        
        set(params.GUI.ffttext, 'String', sprintf('   %1.1f kHz', w(i_fpk)/1000))
        set(params.GUI.ffttext, 'Position', [w(i_fpk), abs(A3w(i_fpk))])        
                
        %[pk3, tpk3] = findpeaks(HP_calcs.pressure,t_clp,'MinPeakDistance',0.8/f, 'MinPeakHeight',0.3 .* max(HP_calcs.pressure));
                
        params.Results.PNP(f_i,v_i) = max(HP_calcs.pressure);
        %params.Results.PII(f_i,v_i) = trapz(HP_calcs.time, (HP_calcs.pressure.^2)./params.Acoustic.Z);
        
        if numel(params.Freq_Vol.frequencies) > 1
            for b = 1:numel(params.Freq_Vol.voltages)
                set(params.GUI.BWfig_plt(b), 'YData',  params.Results.PNP(:,b));
            end
        else
            set(params.GUI.Vplt, 'YData', [params.Results.PNP0 params.Results.PNP(1,:)]);
        end
               
        time_per_step = toc(h_tic) / steps_performed;
        trem = (steps_total - steps_performed) * time_per_step;
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
        
        end
    end
end

sub_SG_Stop(params);

resume = 0;

%% Close All Connections
sub_Close_All_Connections;
params = rmfield(params, 'GUI');

%% Data Management
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
save([fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.mat'], 'params', 'fulldata')


%% Graphs
if numel(params.Freq_Vol.frequencies) > 1
   
else

    v = [0 params.Freq_Vol.voltages] * 10^(params.Amplifier.GainDB/20);
    p = [params.Results.PNP0 params.Results.PNP(1,:)] / 1e6;
    
    figure(1); clf;
    plot(v,p,'k.')
    xlabel('Voltage (Vpp)')
    ylabel(sprintf('%s PNP (MPa)', params.hydrophone_name), 'Interpreter', 'none')
    
    reg = polyfit(v,p,3);
    xfit = 0:0.01:120;
    yfit = polyval(reg, xfit);
    
    hold on;
    plot(xfit, yfit, 'b-')
    
    legend(...
        sprintf('f = %1.0f kHz',params.Freq_Vol.frequencies(1)/1000), ...
        sprintf('PNP = %1.3e Vpp^2 + %1.3e Vpp + %1.3e', reg(1), reg(2), reg(3)), ...
        'Location', 'SouthOutside');
    
    yl = ylim;
    ylim([0, yl(2)])
    
    title([params.Name ' ' params.Time], 'Interpreter', 'None');
    
    fsize = [4 4];
    set(1,'PaperUnits','inches');
    set(1,'PaperSize',fsize);
    set(1,'PaperPositionMode','manual');
    set(1,'PaperPosition', [0 0 fsize(1) fsize(2)]);
    fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
    mkdir(fld);
    print(1, '-dpng', [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.png']);
    
end


% Program is complete, so next time we run this script, will clear data
% from memory