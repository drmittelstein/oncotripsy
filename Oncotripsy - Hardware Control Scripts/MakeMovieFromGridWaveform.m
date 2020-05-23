% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Scan Grid data files collect pressure signal over time for various different data points
% Stepping through time points at all positions can allow the generation of 
% videos where pixel intensity correlates to pressure over time, allowing visualization
% of standing wave or traveling wave patterns

clc

files = {...
    '2019-11-01\results_Scan_Grid_2019-11-01_17-52.mat'};


%%
for files_i = 1:numel(files)
    load(['S:\Ultrasound Data\Mittelstein\results\' files{files_i}])
    t = params.Scan.CenterWaveform.ChHydrophone.XData;
    y = params.Scan.CenterWaveform.ChHydrophone.YData; y = y - mean(y);
    
    plot(t*1e6, y * 1e3);
    xlabel('Time (us)')
    ylabel('SG Signal (mV')
    xlim([min(t) max(t)] * 1e6)
    fsize = [3 1];
    set(1,'PaperUnits','inches');
    set(1,'PaperSize',fsize);
    set(1,'PaperPositionMode','manual');
    set(1,'PaperPosition', [0 0 fsize(1) fsize(2)]);
    fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
    mkdir(fld);
    print(1, '-dpng', [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '_SG.png']);
    
end

%%
maxval = 0;
for files_i = 1:numel(files)
    load(['S:\Ultrasound Data\Mittelstein\results\' files{files_i}])
    N = numel(params.Scan.Waveforms);


    for j=1:N
        y = params.Scan.Waveforms(j).YData(:);
        y = detrend(y);
        maxval = max(maxval,max(abs(y)));
    end
end

for files_i = 1:numel(files)
load(['S:\Ultrasound Data\Mittelstein\results\' files{files_i}])

params.Scripts.PlotImage = [...
    'figure(1); clf; ' ...
    'ax1 = (-(params.Scan.dim1_total - 1)/2:1:(params.Scan.dim1_total-1)/2)' ...
    '.* params.Scan.dim1_step .* params.Stages.step_distance * 1000;' ...
    'ax2 = (-(params.Scan.dim2_total - 1)/2:1:(params.Scan.dim2_total-1)/2)' ...
    '.* params.Scan.dim2_step .* params.Stages.step_distance * 1000;' ...
    'imagesc(ax1, ax2, reshape(params.Scan.Pkpk,' ...
    'params.Scan.dim2_total, params.Scan.dim1_total), [0 2*maxval]);' ...
    'xlabel(''Distance (mm)'');' ...
    'ylabel(''Distance (mm)'');' ...
    'axis image; ' ...
    'colorbar;' ...
    'title([params.Name '' '' params.Time], ''Interpreter'', ''None''); ' ...
    'clear ax1 ax2;'];

params.Scripts.PlotImageAndSave = [params.Scripts.PlotImage ...
    'fsize = [4 4];' ...
    'set(1,''PaperUnits'',''inches'');' ...
    'set(1,''PaperSize'',fsize);' ...
    'set(1,''PaperPositionMode'',''manual'');' ...
    'set(1,''PaperPosition'', [0 0 fsize(1) fsize(2)]);' ...
    'fld = [''results\'' datestr(params.Time, ''yyyy-mm-dd'')];' ...
    'mkdir(fld);' ...
    'print(1, ''-dpng'', [fld ''\results_'' params.Name ''_'' datestr(params.Time, ''yyyy-mm-dd_HH-MM'') ''.png'']);' ...
    'clear fsize fld;'];


eval(params.Scripts.PlotImageAndSave);


%%

wv = sub_Data_DecompressWaveform(params.Scan.Waveforms(1));
t = wv.XData;

N = numel(params.Scan.Waveforms);

fld = ['results\' datestr(params.Time, 'yyyy-mm-dd')];
mkdir(fld);
v = VideoWriter([fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.avi'], 'Grayscale AVI');
v.FrameRate = 20;
open(v)

gif_fn = [fld '\results_' params.Name '_' datestr(params.Time, 'yyyy-mm-dd_HH-MM') '.gif'];

o = zeros(N,1);

wv = [];

for j = 1:N;
    wv(j).YData = detrend(params.Scan.Waveforms(j).YData);
end

vid_scale_factor = 2;
V = zeros(vid_scale_factor*params.Scan.dim2_total, vid_scale_factor*params.Scan.dim1_total);

firstframe = 1;
for i = find(t>20e-6,1,'first'):40:find(t>100e-6,1,'first');
    for j = 1:N
        o(j) = wv(j).YData(i);
    end
    M = reshape(o, params.Scan.dim2_total, params.Scan.dim1_total);
    M = 0.5 + M / (2*maxval);
    
    for x = 1:params.Scan.dim2_total
        for y = 1:params.Scan.dim1_total
            xi = (x-1)*vid_scale_factor+1:(x)*vid_scale_factor;
            yi = (y-1)*vid_scale_factor+1:(y)*vid_scale_factor;
            V(xi,yi) = M(x,y);
        end
    end
    
    V = insertText(V,[0,0], sprintf('%1.0f us', 1e6*t(i)), 'FontSize', 12, 'BoxOpacity',0,'TextColor','white');
    writeVideo(v,V(:,:,1))
    
    [imind,cm] = rgb2ind(V,256, 'nodither'); 
    if firstframe
        imwrite(imind, cm, gif_fn, 'gif', 'Loopcount', Inf, 'DelayTime', 1/20); 
        firstframe = 0;
    else
        imwrite(imind, cm, gif_fn, 'gif', 'WriteMode', 'append', 'DelayTime', 1/20); 
    end
    
end
close(v)

end