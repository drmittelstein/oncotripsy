function params = sub_SG_ApplySettings_DCOnly(params)

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

if params.SG.Waveform.voltage > (params.Amplifier.MaxInstVppIn)
    sub_SG_Stop(params);
    error('Safety Stop!  Attempted to set voltage greater than maximum amplifier input')
end

if params.SG.Waveform.voltage * 10^(params.Amplifier.GainDB/20) > (params.Amplifier.MaxInstVppOut)
    sub_SG_Stop(params);
    error('Safety Stop!  Attempted to set voltage greater than maximum transducer voltage')
end

if params.SG.Waveform.voltage * 10^(params.Amplifier.GainDB/20) * 0.5 / sqrt(2) > params.Amplifier.MaxVrmsOut
    sub_SG_Stop(params);
    error('Safety Stop!  Attempted to set voltage greater than maximum transducer voltage')
end 



if isinf(params.SG.Waveform.cycles)
    if isinf(params.Amplifier.MaxDutyCycle)
        % Safety setting allow CW configuration, no problem
    else
        sub_SG_Stop(params);
        error('Safety Stop!  Attempted to set transducer to transmit CW')
    end
else
    if params.SG.Waveform.cycles / params.SG.Waveform.frequency / params.SG.Waveform.period > params.Amplifier.MaxDutyCycle + 0.01
        sub_SG_Stop(params);
        error('Safety Stop!  Attempted to set duty cycle higher than max duty cycle')
    end
    if params.SG.Waveform.cycles / params.SG.Waveform.frequency > params.Amplifier.MaxPulseDuration
        sub_SG_Stop(params);
        error('Safety Stop!  Attempted to set pulse duration higher than max pulse duration')
    end
end





if params.SG.Initialized
        
        DC = 100*params.SG.Waveform.cycles ./ (params.SG.Waveform.period .* params.SG.Waveform.frequency);
        DC = min(DC,99.9);
    
        s = sprintf('C1: BSWV DUTY,%1.5e; ', DC);

        
        if params.Debug == 1
            disp(s);
            params.SG.WaveformSent = params.SG.Waveform;
            return
        end
        
        try
            fprintf(params.SG.visaObj, s); 
            params.SG.WaveformSent = params.SG.Waveform;

        catch ex
            h = waitbar(0, sprintf('SG is not responding.  Attempting to reset connection\nERROR: %s', ex.message), 'CrateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
            connected = 0;
            while ~connected
                try

                params = sub_SG_Initialize(params);
                fprintf(params.SG.visaObj, s);

                connected = 1;
                catch ex
                    disp(['ERROR: ' ex.message])
                    h = waitbar(0, sprintf('SG is not responding.  Attempting to reset connection\nERROR: %s', ex.message), 'CrateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
                    tic
                    while toc<2
                        if getappdata(h,'canceling')
                            error('Cancelled attempts to reconnect to SG')
                        end
                        waitbar(toc/2,h)
                    end
                end

            end

            delete(h);

        end
          
end