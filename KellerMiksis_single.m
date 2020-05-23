% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Keller-Miksis simulations of bubble cavitaiton in response to ultrasound stimulation (single)

clc
clearvars

R0 = 3 * 10^-6;

S = .072; % Surface Tension (N/m)
vL = 1e-6; % Kinemaitc Viscocity of Water (m^2/s)
rho_L = 998; % Density of Water (kg/m3)
c = 1500; % Speed of Sound in Water

Patm = 101325; % Pressure (Pa)
Pvapor = 5.6267e3; % Vapor pressure of water at 35 deg C (Pa)
Ppartial = Patm-Pvapor;

f = 0.698e6;
Pus = 1.31 * 10^6; % US Peak Negative Pressure (Pa)

gamma = 1.4;

opts = odeset('MaxStep', 1e-12);

yInit = [R0, 0];
interval = [0 20e-6];

ySol = ode15s(@(t,x) KM_ode_symb(t,x,c,rho_L,Pvapor,Ppartial,R0,gamma,f,Pus,Patm,S,vL), interval, yInit, opts);

figure(1)
clf
plot(ySol.x * 1e6, ySol.y(1,:) * 1e6, 'k')
title(sprintf('R0 = %1.3f micrometer', 1e6*R0))
xlim([4 20])
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
print(f, '-dpng', sprintf('test.png', i))