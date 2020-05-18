function answer = sub_process_hydrophone_curve(time,voltage,calibration)

% Function to process a waveform from a hydrophone based on the provided
% calibration.
% 
% Syntax: answer = process_hydrophone_curve(waveform,calibration)
% 
% waveform - the obtained waveform (2-column structure - first - time (s), second - voltage (V)).
% calibration - hydrophone calibration array (2-column - first - frequencies (Hz), second - V/Pa)
% 
% Output:
% answer - structure variable with:
% answer.waveform - the true waveform (same structure as input)
% answer.f_spectrum - the true frequency spectrum amplitude (1st column - frequencies, 2nd - signal amplitude, Pa/Hz)
% answer.p_pos_pres.max - maximum peak positive pressure
% answer.p_pos_pres.avg - average peak positive pressutempre (from the average of the peaks)
% answer.p_neg_pres.max, answer.p_neg_pres.max - same as the two above, just for peak negative pressure.


if numel(time) > 1
    
    %% Get the true waveform
    % Convert the waveform into frequency spectrum (FFT)
    fs = 1./(time(2)-time(1));
    fft_pts = length(voltage);

    f_a = fft(voltage)./fft_pts*2;
    f_fa = (0:fft_pts-1)./fft_pts.*fs;

    %% Interpolate the calibration curve. 
    % Extrapolation method - nearest neighbor.
    min_f_calib = calibration(1,1);
    max_f_calib = calibration(end,1);
    % Interpolated calibration
    calibration_interp = interp1(calibration(:,1),calibration(:,2),f_fa,'linear');
    % The extrapolation part
    for j = 1:length(f_fa)
        if f_fa(j) < min_f_calib
            calibration_interp(j) = calibration(1,2);
        end

        if f_fa(j) > max_f_calib
            calibration_interp(j) = calibration(end,2);
        end 
    end

    %% Process the Waveform

    % Get the true spectrum, using the interpolated calibration data
    f_a_true = f_a./calibration_interp';
    answer.freq = f_fa;
    answer.fft = abs(f_a_true);

    % Get the true time domain signal (IFFT)
    answer.time = time;
    answer.pressure = real(ifft(f_a_true.*fft_pts/2));

else
    
    %% There is no waveform, just output zeros
    answer.freq = 0;
    answer.fft = 0;

    answer.time = 0;
    answer.pressure = 0;
    
end

%% Measure Waveform Values

% The cutoff value for finding the average peak height. Only peaks that are
% at least that value of the maximum will be considered (to eliminate any
% peaks found in noise or ramp up)
%cutoff_val = 0.75;

% Pk Positive Pressures
% Looks for peaks in the waveform, which are at least higher than the cutoff value (defined at the top) of the maximum
% value (as in - the actual peaks in the sinusoid signal), and averages
% those.
%peaks = findpeaks(answer.pressure);
%answer.p_pos_pres.max = max(peaks);
%answer.p_pos_pres.avg = mean(peaks(peaks > peaks*cutoff_val));

% Pk Negative Pressures
% Same idea as for positive pressures, just invert the waveform.
%peaks = findpeaks(-answer.pressure);
%answer.p_neg_pres.max = -max(peaks);
%answer.p_neg_pres.avg = -mean(peaks(peaks > peaks*cutoff_val));

