% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% This subroutine is called in the beginning of each script to generate the params structure
% This includes experiment specific values that should be adjusted before each experiment including:
% * Safety paramters - that prevent the signal generator from sending a signal that could damage equipment or samples
% * Hardware default parameters
% * Reference parameters

function params = sub_AllSettings(name)

params = struct; params.Name = name; params.Time = datestr(now);

% Debug Model - if activated, all commands to and reads from hardware will be simulated
params.Debug = 0; % Default 0

% Transducer Parameters
params.Transducer_Fc = 3e5; % Center frequency of the transducer
params.Transducer_Name = 'Benthowave'; % Used for reference 

% Amplifier Settings
params.Amplifier.MaxInstVppIn = 0.3; %Blue Amplifier (1Vrms) % Sangjin's transducer         % (0.632551054 for 670 kHz); % (0.155 from Hunters amp);
params.Amplifier.MaxInstVppOut = 125; % 0.4 * 10^(50/20) Sangjin's transducer
params.Amplifier.MaxVrmsOut = 50;
params.Amplifier.MaxDutyCycle = 0.1; % Maximum fraction of time that signal can be on
params.Amplifier.MaxPulseDuration = 0.1; % Maximum time in seconds that pulse duration can be

params.Amplifier.Name = 'AR100A250B'; % Used for Reference
params.Amplifier.ReadMe = 'Gain from Vpp on signal generator GUI to Vpp output of amplifier measured by oscilloscope (C2 1 Mohm, C4 50 ohm)';
params.Amplifier.SetupNotes = 'Using AR 100A250B at 100% gain and set BKP to have 50 ohm output load';
params.Amplifier.GainDB =  51.0412;
params.Amplifier.Tested =  '23-Jan-2020 11:28:02';

%% General Settings
params.Scope.ArmTrigger = 0;
params.Scope.MaintainSettings = 0;
params.Scope.averaging = 1024;
params.Scope.readout.channel = 3; % Specify the channel to readout
params.Scope.command_delay = 0.1; % Seconds to pause in between issuing commands to Scope

%% Prepare User Interface
s = [params.Name '_' datestr(now, 'yyyy-mm-dd_HH-MM-SS')];
t = s; t(t ~= '=') = '='; clc; disp(s); disp(t); 
params.NameFull = s; clear s t;

%% Stage Parameters

% Default speed
params.Stages.Speed = 2000;

% Translation Distance Per Motor Step (6.35 microns / motor step)
params.Stages.step_distance = 0.0254/10/400; 

% Assignment of Motor numbers to axes (as per the definition image)
params.Stages.x_motor = 2;
params.Stages.y_motor = 3;
params.Stages.z_motor = 1;



%% SG Parameters

% Define some basic introductory waveform parameters
params.SG.Waveform.ch = 4;
params.SG.Waveform.cycles = 30;
params.SG.Waveform.period = 1e-3;
params.SG.Waveform.frequency = params.Transducer_Fc;
params.SG.Waveform.voltage = 0.05;
params.SG.Waveform.repeats = -1;

%% Plate Parameters (for reference)
params.Plate.welldistance = 19.5 / 1000; % Meters
params.Plate.welldiameter = 15.56 / 1000; % Meters

%% Acoustic Values
params.Acoustic.MediumDensity = 1e3; % kg/m3
params.Acoustic.MediumAcousticSpeed = 1.481e3; % m/s
params.Acoustic.Z = params.Acoustic.MediumAcousticSpeed * params.Acoustic.MediumDensity; 

%% Turn off warnings
warning('off','all');

end