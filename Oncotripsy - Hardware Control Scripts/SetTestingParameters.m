% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Send command to Signal Generator to define testing parameters
% Recommended to use this as it follows safety parameters set in sub_AllSettings
% Note: after parameters are set, this script activates the signal generator

params = sub_AllSettings('SetTestingParameters');

sub_Close_All_Connections;
params = sub_SG_Initialize(params);
params.Scope.averaging = 1024;

% params.SG.Waveform
% .ch
% .cycles
% .period
% .frequency
% .voltage


params.SG.Waveform.ch = 1;

% Equation to set pulse duration

params.SG.Waveform.frequency = 3e5; % Hz
params.SG.Waveform.voltage = 70 * 10^(-params.Amplifier.GainDB/20); %                                                          

% For 500 (494) kHz Transducer, use 30 V for testing, 49.97 V for 0.7 MPa
% For 670 kHz Transducer, use 30 V for testing, 32.171 V for 0.7 MPa

cycles = params.SG.Waveform.frequency * 0.001;

params.SG.Waveform.period = cycles / params.SG.Waveform.frequency * 10;
params.SG.Waveform.cycles = cycles;


params = sub_SG_ApplySettings(params);

disp(' ');
disp(sprintf('Frequency          = %1.0f kHz', params.SG.Waveform.frequency/1000))
disp(sprintf('Transducer Voltage = %1.2f V', params.SG.Waveform.voltage * 10^(params.Amplifier.GainDB/20)))
disp(sprintf('Pulse Duration     = %1.2f ms', 1000*params.SG.Waveform.cycles / params.SG.Waveform.frequency));
disp(sprintf('Duty Cycle         = %1.2f%%', 100*params.SG.Waveform.cycles / params.SG.Waveform.frequency / params.SG.Waveform.period));


try
    params = sub_Scope_Initialize(params);
    
    params.Scope.Settings.TimeRange =  0.9 * params.SG.Waveform.period;
    params.Scope.Settings.Position = 0.4 * params.SG.Waveform.period;
    params = sub_Scope_ApplySettings(params);
    
    
    fprintf(params.Scope.visaObj, ':MEAS:CLE');
    fprintf(params.Scope.visaObj, ':MEAS:PWID CHAN1');
    fprintf(params.Scope.visaObj, ':MEAS:VPP CHAN2');
    fprintf(params.Scope.visaObj, ':MEAS:VPP CHAN4');
    fprintf(params.Scope.visaObj, ':MEAS:FREQ CHAN2');
    
catch ex
    disp(ex);
end

sub_SG_Start(params);