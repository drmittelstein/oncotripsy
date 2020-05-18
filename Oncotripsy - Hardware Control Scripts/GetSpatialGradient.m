sub_AllSettings('');

clc

files = {...
    '2019-03-08\results_Scan_Grid_2019-03-08_23-12.mat', ...
    '2019-03-08\results_Scan_Grid_2019-03-08_21-39.mat', ...
    '2019-03-09\results_Scan_Grid_2019-03-09_00-32.mat'};

%%
maxval = 0;
for files_i = 1:numel(files)
    load(['X:\Ultrasound Data\Mittelstein\results\' files{files_i}])
    N = numel(params.Scan.Waveforms);

    maxval = max(maxval,max(abs(params.Scan.Pkpk)));
    
end

x = -1;
y = -1;
close all

for files_i = 1:numel(files)
load(['X:\Ultrasound Data\Mittelstein\results\' files{files_i}])

wv = sub_Data_DecompressWaveform(params.Scan.Waveforms(1));
t = wv.XData;

N = numel(params.Scan.Waveforms);


ax1 = (-(params.Scan.dim1_total - 1)/2:1:(params.Scan.dim1_total-1)/2) ...
.* params.Scan.dim1_step .* params.Stages.step_distance * 1000;

ax2 = (-(params.Scan.dim2_total - 1)/2:1:(params.Scan.dim2_total-1)/2) ...
    .* params.Scan.dim2_step .* params.Stages.step_distance * 1000;
ax2 = 5+ax2;

clf
M = reshape(1000 * params.Scan.Pkpk, ...
    params.Scan.dim2_total, params.Scan.dim1_total);
imagesc(ax1, ax2, M, [0 maxval*1000]);

xlabel('Distance (mm)');
ylabel('Distance (mm)');
axis image;
c = colorbar;
c.Label.String = 'Hydrophone (mVpp)';
title([params.Name ' ' params.Time], 'Interpreter', 'None');
fsize = [4 4];
set(1,'PaperUnits','inches');
set(1,'PaperSize',fsize);
set(1,'PaperPositionMode','manual');
set(1,'PaperPosition', [0 0 fsize(1) fsize(2)]);
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
print(1, '-dpng', [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM-SS') '.png']);


if x==-1    
    [x,y] = ginput(1);
    xi = find(ax1>x, 1, 'first');
    yi = find(ax2>y, 1, 'first');
end

ds_mm = params.Scan.dim2_step .* params.Stages.step_distance * 1000;
[Gx, Gy] = gradient(M, ds_mm);
disp([params.Name ' ' params.Time]);
disp(sprintf('%1.2f mVpp/mm', sqrt(Gx(xi, yi)^2 + Gy(xi, yi)^2)));
disp(' ');
o = zeros(N,1);

t_sub = find(t>3e-5,1,'first'):1:find(t>16e-5,1,'first');
G = zeros(numel(t),1);

for ti = t_sub
    
    for j = 1:N
        o(j) = params.Scan.Waveforms(j).YData(ti);
    end
    M = reshape(o * 1000, params.Scan.dim2_total, params.Scan.dim1_total);

    
    [Gx, Gy] = gradient(M, ds_mm);
    
    G(ti) = sqrt(Gx(xi, yi)^2 + Gy(xi, yi)^2);
end

wv_grid = reshape(params.Scan.Waveforms, params.Scan.dim2_total, params.Scan.dim1_total);
wv = wv_grid(xi, yi);

clf
plot(t*1e6, wv.YData * 1000); 
xlabel('Time (us)')
ylabel('Hydrophone Signal (mV)')
xlim([min(t) max(t)] * 1e6)
ylim([-75 75])
title([params.Name ' ' params.Time], 'Interpreter', 'None');
fsize = [3 2];
set(1,'PaperUnits','inches');
set(1,'PaperSize',fsize);
set(1,'PaperPositionMode','manual');
set(1,'PaperPosition', [0 0 fsize(1) fsize(2)]);
fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
print(1, '-dpng', [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '_pressure.png']);

% clf
% plot(t_p * 1e6, G_p); hold on;
% plot(xlim, max(G_p) * [1, 1], 'r-')
% text(min(xlim), max(G), sprintf('%1.2f', max(G)))
% xlabel('Time (us)')
% ylabel('Hydrophone Gradient (mV/mm)')
% xlim([min(t) max(t)] * 1e6)
% ylim([0 40])
% title([params.Name ' ' params.Time], 'Interpreter', 'None');
% fsize = [3 2];
% set(1,'PaperUnits','inches');
% set(1,'PaperSize',fsize);
% set(1,'PaperPositionMode','manual');
% set(1,'PaperPosition', [0 0 fsize(1) fsize(2)]);
% fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
% mkdir(fld);
% print(1, '-dpng', [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '_gradient.png']);

end
% close(v)
