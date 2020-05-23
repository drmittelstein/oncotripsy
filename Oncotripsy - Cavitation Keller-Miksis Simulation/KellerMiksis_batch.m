clc
clearvars
R0_array = logspace(-8, -4, 100);

parfor i = 1:numel(R0_array)
R0 = R0_array(i);

disp(sprintf('START: R = %1.2e m - %s', R0, datestr(now)))

S = 72.86 * 1e-3; % Surface Tension (N/m)
vL = 1.004 * 1e-6; % Kinemaitc Viscocity of Water (m^2/s)
rho_L = 997; % Density of Water (kg/m3)
c = 1500; % Speed of Sound in Water

Patm = 101325; % Pressure (Pa)
Pvapor = 5.6267e3; % Vapor pressure of water at 35 deg C (Pa)
Ppartial = Patm-Pvapor;

f = 0.5e6;
Pus = 1.4 * 10^6; % US Peak Negative Pressure (Pa)

gamma = 1.4;

opts = odeset('MaxStep', 1e-12);

yInit = [R0, 0];
interval = [0 20e-6];

ySol = ode15s(@(t,x) KM_ode_symb(t,x,c,rho_L,Pvapor,Ppartial,R0,gamma,f,Pus,Patm,S,vL), interval, yInit, opts);

parsave(i, ySol.x, ySol.y(1,:), ySol.y(2,:))

disp(sprintf('STOP : R = %1.2e m - %s', R0, datestr(now)))
end

save('vars/out.mat')