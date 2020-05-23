% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Apply settings to the signal generator, and prime for a receiving a trigger command

function params = sub_SG_ApplySettingsForTrigger(params)

try
    if params.Debug == 1
        return
    end
catch
end

% params.SG.Waveform
% .ch
% .cycles
% .period
% .frequency
% .voltage

if params.SG.Waveform.frequency ~= params.Transducer_Fc
    if ~isfield(params.SG, 'FrequencyOveride')
        sub_SG_Stop(params);
        error('Safety Stop!  Attempted to set frequency different from center frequency')
    else
        if ~params.SG.FrequencyOveride;
            sub_SG_Stop(params);
            error('Safety Stop!  Attempted to set frequency different from center frequency')
        else
            % Frequency is different, but because FrequencyOveride flag is
            % specified, don't worry about it.  Be careful not to drive
            % transducer at frequency far from center frequency.
        end
    end
end

if params.SG.Waveform.voltage > (params.Amplifier.MaxInstVppIn) * 1.01
    sub_SG_Stop(params);
    error('Safety Stop!  Attempted to set voltage greater than maximum amplifier input')
end

if params.SG.Waveform.voltage * 10^(params.Amplifier.GainDB/20) > (params.Amplifier.MaxInstVppOut) * 1.01
    sub_SG_Stop(params);
    error('Safety Stop!  Attempted to set voltage greater than maximum transducer voltage')
end

if params.SG.Waveform.cycles / params.SG.Waveform.frequency / params.SG.Waveform.period > params.Amplifier.MaxDutyCycle + 0.01
    sub_SG_Stop(params);
    error('Safety Stop!  Attempted to set duty cycle higher than max duty cycle')
end

if params.SG.Waveform.cycles / params.SG.Waveform.frequency > params.Amplifier.MaxPulseDuration
    sub_SG_Stop(params);
    error('Safety Stop!  Attempted to set pulse duration higher than max pulse duration')
end



if params.SG.Initialized

    if strcmp(params.SG.Instrument, 'TABOR')
        
        % Set Waveform Parameters on Tabor
                
        fprintf(params.SG.visaObj,[':INSTRUMENT CH' num2str(params.SG.Waveform.ch)]); 
        
        fprintf(params.SG.visaObj,':OUT:FUNCTION:MODE FIX'); % Toggle standard waveform mode
        fprintf(params.SG.visaObj,':FUNCTION:SHAPE SIN'); % Define a sinusoid waveform
        
        fprintf(params.SG.visaObj,':INIT:CONT 0');
        fprintf(params.SG.visaObj,':TRIG:SOURCE:BUS');
        fprintf(params.SG.visaObj,[':TRIG:COUNT ' num2str(params.SG.Waveform.cycles)]); % # of cycles in the pulse
        fprintf(params.SG.visaObj,[':TRIGger:DELay 0']);
        fprintf(params.SG.visaObj,[':TRIGger:MODE NORMal']);
                
        fprintf(params.SG.visaObj,[':FREQ ' num2str(params.SG.Waveform.frequency)]); % Waveform frequency
        
        if params.SG.Waveform.voltage > 0.05;
            fprintf(params.SG.visaObj,[':VOLT ' num2str(params.SG.Waveform.voltage)]); % Waveform amplitude
        else
            fprintf(params.SG.visaObj,[':VOLT 0.05']); % Waveform amplitude
        end
        fprintf(params.SG.visaObj,':OUTPut:SYNC:SOURce 1');
        
%         fprintf(params.SG.visaObj,[':INSTRUMENT CH' num2str(params.SG.Waveform.ch)]);
%         fprintf(params.SG.visaObj,'OUTPUT 1');
%         fprintf(params.SG.visaObj,':OUTPUT:SYNC 1');
        
    elseif strcmp(params.SG.Instrument, 'BKP')
        
        % Set Waveform Parameters on BKP      
        
        fprintf(params.SG.visaObj, 'C1:OUTP LOAD,50;');
        fprintf(params.SG.visaObj, 'C2:OUTP LOAD,50;');      
        
        s = ['C1:BSWV WVTP,PULSE,AMP,4,OFST,2,PHSE,0,'];
        s = [s sprintf('FRQ,%1.5e,', 1 / params.SG.Waveform.period)];
        s = [s sprintf('DUTY,%1.5e; ', 100*params.SG.Waveform.cycles ./ (params.SG.Waveform.period .* params.SG.Waveform.frequency))];
        fprintf(params.SG.visaObj, s);
        
        s = ['C2:BSWV WVTP,SINE,OFST,0,PHSE,0,'];
        s = [s sprintf('FRQ,%1.5e,', params.SG.Waveform.frequency)];
        s = [s sprintf('AMP,%1.5e; ', params.SG.Waveform.voltage)];
        fprintf(params.SG.visaObj, s);

        s = 'C2:BTWV STATE,ON,GATE_NCYC,GATE,TRSR,EXT,PLRT,POS;';
        fprintf(params.SG.visaObj, s);               
        
        s = ['C1:BTWV STATE,ON,GATE_NCYC,NCYC,TRSR,MAN,' sprintf('TIME,%1.0f; ',params.SG.Waveform.repeats)];
        fprintf(params.SG.visaObj, s); 
        
    end
end
        
end