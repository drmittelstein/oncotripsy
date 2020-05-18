clearvars
load('vars/out.mat')

colorsteps = 200;
cmap = zeros(colorsteps-1 ,3);
for i = 1:colorsteps/2-1
    cmap(i,:) = [1-i/colorsteps, (1-i/colorsteps)/2, (1-i/colorsteps)/2];
end
for i = colorsteps/2+1:colorsteps-1
    cmap(i,:) = [(0.5+(i-100)/colorsteps)/2, (0.5+(i-100)/colorsteps)/2, 0.5+(i-100)/colorsteps];
end
cmap(cmap<0) = 0;
cmap = flipud(cmap);


Rff_all = logspace(-6,-2,200);
M = zeros(numel(R0_array), numel(Rff_all));

for i = 1:numel(R0_array)
    disp(sprintf('%d out of %d', i, numel(R0_array)))
    
    load(sprintf('vars/Rvec_i=%d.mat', i));
    load(sprintf('vars/dRvec_i=%d.mat', i));
    load(sprintf('vars/tvec_i=%d.mat', i));
    
    tvec = tvec(tvec > 9e-5);
    Rvec = Rvec(tvec > 9e-5);
    dRvec = dRvec(tvec > 9e-5);
    
    t_ip = min(tvec):1e-10:max(tvec);
    Ra_ip = interp1(tvec, Rvec, t_ip, 'pchip');
    dRa_ip = interp1(tvec, dRvec, t_ip, 'pchip');
    ddRa_ip = [0 diff(dRa_ip) ./ diff(t_ip)];
    
    disp(min(Ra_ip))
    
    figure(1)
    clf
    plot(t_ip * 1e6, Ra_ip * 1e6)
    title(sprintf('R0 = %1.2f micrometer', 1e6*R0_array(i)))
    xlabel('Time (microsecond)')
    ylabel('Radius (micrometer)')
    
    f=1;
    set(findall(gcf,'-property','FontSize'),'FontSize',9)
    set(findall(gcf,'-property','FontName'),'FontName','Arial')

    f_sz = [4,2];
    set(f, 'PaperUnits', 'inches')
    set(f, 'PaperSize', f_sz)
    set(f, 'PaperPositionMode', 'manual')
    set(f, 'PaperPosition', [0 0 f_sz(1) f_sz(2)])
    print(f, '-dpng', sprintf('plots/%d.png', i))
    
    P_far_mult_Rff = Pff_mult_Rff(Ra_ip, dRa_ip, ddRa_ip);
    
    for Rff_i = 1:numel(Rff_all)
        Rff = Rff_all(Rff_i);
        P_far = P_far_mult_Rff / Rff;
        
        fft_pts = length(P_far); % Nb points
        fs = 1 / (t_ip(2)-t_ip(1));
        w = (0:fft_pts-1)./fft_pts.*fs;
        P_farw = abs(fft(P_far));
        w_i = find(w>0.5e6, 1, 'first');
        
        M(i, Rff_i) = P_farw(w_i);
        
    end
end

y = 1.4e6*sin(2*pi*0.5e6*t_ip);
fft_pts = length(t_ip); % Nb points
fs = 1 / (t_ip(2)-t_ip(1));
w = (0:fft_pts-1)./fft_pts.*fs;
fusw = abs(fft(y));
w_i = find(w>0.5e6, 1, 'first');

ref_fft = fusw(w_i);

figure(1)
clf

M_norm = M / ref_fft;
M_db = 20*log10(M_norm);

imagesc(log10((Rff_all)), log10(R0_array), M_db)
colormap(cmap)
%set(gca, 'XScale', 'log', 'YScale', 'log')
ylabel('log10[ Bubble R0 (m) ]')
xlabel('log10[ Distance from Bubble (m) ]')
set(gca, 'CLim', [-100, 100])
c = colorbar();
c.Label.String = '20*log10 [ FFT bubble(f=0.5 MHz) / FFT US(f=0.5 MHz)]';
title('Pressure Scattered from Cavitating Bubble')

f=1;
set(findall(gcf,'-property','FontSize'),'FontSize',9)
set(findall(gcf,'-property','FontName'),'FontName','Arial')

f_sz = [4,4];
set(f, 'PaperUnits', 'inches')
set(f, 'PaperSize', f_sz)
set(f, 'PaperPositionMode', 'manual')
set(f, 'PaperPosition', [0 0 f_sz(1) f_sz(2)])
print(f, '-dpng', sprintf('FarField_FFT.png'))

function out = Pff_mult_Rff(Ra, dRa, ddRa)
    rho_L = 1000; % kg/m3
    out = (rho_L).*(Ra.^2 .* ddRa + 2 .* Ra .* dRa.^2);
end