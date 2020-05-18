% Differential Equation

% F = [R,   d/dt     R]
% dF = [d/dt R,   (d/dt)^2 R]

clc
clearvars

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

syms t
syms R(t) positive

R0_array = logspace(-8, -5);
n = numel(R0_array);
min_R = zeros(n,1);
max_R = zeros(n,1);
min_P = zeros(n,1);
max_P = zeros(n,1);
ss_P = zeros(n,1);
energy = zeros(n,1);

opts = odeset('InitialStep', 0.001/(2*pi*f), 'MaxStep', 0.001/(2*pi*f), 'AbsTol',1e-9, 'RelTol', 1e-15);
parfor i = 1:numel(R0_array)
R0 = R0_array(i);


disp(sprintf('START: R = %1.2e m - %s', R0, datestr(now)))

yInit = [R0, 0];
% interval = [0 5/f];
% ySol = ode15s(@(t,x) KM_ode(t,x,c,rho_L,Pvapor,Ppartial,R0,gamma,f,0,Patm,S,vL), interval, yInit, opts);
% % KM_ode(t, x, c, rho_L, p_vap, p_partial, R0, gamma, f, Pus, Patm)
% 
% tvec = [ySol.x];
% Rvec = [ySol.y(1,:)];
% dRvec = [ySol.y(2,:)];
% 
% yInit = [ySol.y(1,end), ySol.y(2,end)];
% interval = [5/f 100e-6];

interval = [0 100e-6];

ySol = ode15s(@(t,x) KM_ode(t,x,c,rho_L,Pvapor,Ppartial,R0,gamma,f,Pus,Patm,S,vL), interval, yInit, opts);

% tvec = [tvec ySol.x];
% Rvec = [Rvec ySol.y(1,:)];
% dRvec = [dRvec ySol.y(2,:)];

% parsave(i, tvec, Rvec, dRvec)
parsave(i, ySol.x, ySol.y(1,:), ySol.y(2,:))
disp(sprintf('STOP : R = %1.2e m - %s', R0, datestr(now)))

% tt = 0:1e-7:interval(2);
% plot(tvec, Rvec);
% xlim([0 max(interval)])
% ylabel('Bubble Radius (m)')
% 
% min_R(i) = min(Rvec);
% max_R(i) = max(Rvec);
% 
% set(findall(gcf,'-property','FontSize'),'FontSize',11)
% set(findall(gcf,'-property','FontName'),'FontName','Arial')
% 
% fig = gcf;
% f_sz = [4,8];
% set(fig, 'PaperUnits', 'inches')
% set(fig, 'PaperSize', f_sz)
% set(fig, 'PaperPositionMode', 'manual')
% set(fig, 'PaperPosition', [0 0 f_sz(1) f_sz(2)])
% print(fig, '-dpng', sprintf('plots/R=%1.9f.png',R0)) 
% disp('- Success!')



end

close all
subplot(511)
semilogx(R0_array, min_R./R0_array', 'b-o')
xlabel('Initial Bubble Radius')
ylabel('Min/Init Bubble Radius')
subplot(512)
semilogx(R0_array, max_R./R0_array', 'b-o')
xlabel('Initial Bubble Radius')

save('vars/out.mat')

ylabel('Max/Init Bubble Radius')
subplot(513)
semilogx(R0_array, min_P, 'b-o')
xlabel('Initial Bubble Radius')
ylabel('Min Bubble Pressure')
subplot(514)
semilogx(R0_array, max_P, 'b-o')
xlabel('Initial Bubble Radius')
ylabel('Max Bubble Pressure')
subplot(515)
semilogx(R0_array, ss_P, 'b-o')
xlabel('Initial Bubble Radius')
ylabel('Pk-Pk Pressure')
fig = gcf;
f_sz = [4,8];
set(fig, 'PaperUnits', 'inches')
set(fig, 'PaperSize', f_sz)
set(fig, 'PaperPositionMode', 'manual')
set(fig, 'PaperPosition', [0 0 f_sz(1) f_sz(2)])
print(fig, '-dpng', 'plots/Analysis.png') 