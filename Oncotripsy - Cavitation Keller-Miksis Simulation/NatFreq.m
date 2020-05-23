Re = logspace(-8,-4,1000);

gamma = 1.4;

pinf = 1.4 * 10^6; % US Peak Negative Pressure (Pa)% amplitude
pv = 5.6267e3;% Vapor pressure of water at 35 deg C (Pa)
rho = 997; % Density of Water (kg/m3)
S = 72.86 * 1e-3; % Surface Tension (N/m)
eta = 1.004 * 1e-6; % Kinemaitc Viscocity of Water (m^2/s)
k = 1.4;
f = 0.5e6;

w = sqrt((3.*k.*(pinf-pv))./(rho.*Re.^2) + ...
    2*(3*k-1)*S./(rho.*Re.^3) - ...
    8*eta^2./(Re.^4));

w_search = w;
w_search(Re < 10^-7) = 4*pi*f;
i = find(w_search<2*pi*f, 1, 'first');

loglog(Re, w/(2*pi), 'r-', Re, Re.*0 + f, 'k:', Re(i), f, 'ko')
yticks([10^5 10^6 10^7 10^8 10^9 10^10])
xlabel('Radius (m)')
ylabel('Frequency (Hz)')
legend('Bubble', '0.5 MHz', sprintf('R0 = %1.2e m', Re(i)), 'Location','SouthWest')
title('Bubble Resonant Frequency')

f=1;
set(findall(gcf,'-property','FontSize'),'FontSize',9)
set(findall(gcf,'-property','FontName'),'FontName','Arial')

f_sz = [4,2];
set(f, 'PaperUnits', 'inches')
set(f, 'PaperSize', f_sz)
set(f, 'PaperPositionMode', 'manual')
set(f, 'PaperPosition', [0 0 f_sz(1) f_sz(2)])
print(f, '-dpng', 'NatFreq.png')