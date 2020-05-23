% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

%// GENERATE CUSTOM WAVEFORMS
%// A = sine wave amplitude
%// fs = sample rate (Hz)
%// f0 = initial frequency (Hz)
%// f1 = final frequency (Hz)
%// T_sweep = duration of sweep (s)
%//

%% Load calibration file here
clearvars
load('S:\Ultrasound Data\Mittelstein\results\2019-02-25\results_Scan_TransducerResponse_2019-02-25_09-05.mat')
clear fulldata

%%
p = params.Results.PNP;
f = params.Freq_Vol.frequencies;

calibration = [f',p];


%%
BWs = [200e3];
T_sweeps = [10/3 * 1e-6];

for BW = BWs
for T_sweep = T_sweeps
output = [];
N = 524288;
fc = 300e3;
f0 = fc - BW/2;
f1 = fc + BW/2;
Fs = N/(T_sweep);

A = 1;

phi = 0;                      %// phase accumulator
f = f0;                       %// initial frequency
delta = 2 * pi * f / Fs;      %// phase increment per sample
f_delta = (f1 - f0) * 2 / (Fs * T_sweep);
                              %// instantaneous frequency increment per sample
for i = 1:262144
    output(i) = A * sin(phi);    %// output sample value for current sample
    phi = phi + delta;             %// increment phase accumulator
    f = f + f_delta;             %// increment instantaneous frequency
    delta = 2 * pi * f / Fs;  %// re-calculate phase increment
end
for i = 262145:524288
    output(i) = A * sin(phi);    %// output sample value for current sample
    phi = phi + delta;             %// increment phase accumulator
    f = f - f_delta;             %// increment instantaneous frequency
    delta = 2 * pi * f / Fs;  %// re-calculate phase increment
end



%% Apply the voltage normalization
% Convert the waveform into frequency spectrum (FFT)
fft_pts = length(output);

f_a = fft(output)./fft_pts*2;
f_fa = (0:fft_pts-1)./fft_pts.*Fs;

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

% Get the true spectrum, using the interpolated calibration data
f_a_true_div = f_a;
f_a_true_mul = f_a;

for i = 1:numel(f_a)
    f_a_true_div(i) = f_a(i)./calibration_interp(i);
    f_a_true_mul(i) = f_a(i).*calibration_interp(i);
end
output_div = real(ifft(f_a_true_div.*fft_pts/2));

%%
csvwrite(sprintf('sweep_%1.2f-%1.2fMHz_%1.0fus.csv', f0/1e6,f1/1e6,T_sweep*1e6), output')
csvwrite(sprintf('sweep_%1.2f-%1.2fMHz_%1.0fus_conv.csv', f0/1e6,f1/1e6,T_sweep*1e6), output_div')
plot((1:N)/Fs, output_div, 'k-')
end
end