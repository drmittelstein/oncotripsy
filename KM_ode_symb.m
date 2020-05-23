% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Keller-Miksis simulations of bubble cavitaiton in response to ultrasound stimulation (batch)

function out = KM_ode(t, x, c, rho, p_vap, p_partial, R0, k, f, Pa, Patm, sig, eta)
    % KM_ode(t, x, c, rho_L, p_vap, p_partial, R0, gamma, f, Pus, Patm)
    % t: Time (s)
    % x: [Radius of bubble (m), d/dt Radius of bubble (m/s)]
    % c: Speed of sound in water (m/s)
    % rho_L: Density of water (kg/m3)
    % p_vap: Vapor pressure of liquid (Pa)
    % p_partial: Partial pressure of gas (Pa)
    % R0: Initial bubble radius (m)
    % gamma
    % f: Frequency of US stimulation (Hz)
    % Pus: Pressure (amplitude) of US signal (Pa)
    % Patm: Pressure of atmosphere (Pa)
    % surf_ten: Surface Tension (Pa/m)
    % nu: Viscocity (Pa-s)
    
    R = x(1);  % Radius of bubble (m)
    dR = x(2); % d/dt Radius of bubble (m/s)
    out = zeros(2,1);
    
    w = 2*pi*f;
    P0 = p_vap + p_partial;
    
    out(1) = dR; % d/dt Radius of bubble (m/s) OUT

    out(2) = -(dR^2*(dR/(2*c) - 3/2) - ((dR/c + 1)*(P0 + Pa*sin(t*w) - (P0 + (2*sig)/R0)*(R0/R)^(3*k) + (2*sig)/R + (4*dR*eta)/R))/rho + (R*((2*dR*sig)/R^2 + (4*dR^2*eta)/R^2 - Pa*w*cos(t*w) - (3*R0*dR*k*(P0 + (2*sig)/R0)*(R0/R)^(3*k - 1))/R^2))/(c*rho))/(R*(dR/c - 1) - (4*eta)/(c*rho)); % d2/dt2 Radius of bubble(m/s2)
end

% Do calculus for in Matlab
%
% Keller Miksis Equation
% As described in https://ieeexplore-ieee-org.clsproxy.library.caltech.edu/document/8091852
% 
% syms R(t) Pw
% syms c rho sig k eta P0 Pa w R0
% dRtmp = diff(R,t);
% ddRtmp = diff(R,t,t);
% 
% pw = (P0+2*sig/R0)*(R0/R)^(3*k) - 2*sig/R - 4*eta*dRtmp/R - P0 - Pa*sin(w*t);
% dpw = diff(pw, t);
% 
% KM = (...
%     (1-dRtmp/c)*R*ddRtmp + (3/2-dRtmp/(2*c))*dRtmp^2 == ...
%     (1/rho)*(1+dRtmp/c)*pw + R/(rho*c)*dpw);
% 
% syms dR ddR
% KM = subs(KM, diff(R,t,t), ddR);
% KM = subs(KM, diff(R,t), dR);
% 
% KMsolved = solve(KM, ddR);
% disp(KMsolved)
% 
% Took the output string of above, and pasted it identically into the code
% for out(2) above