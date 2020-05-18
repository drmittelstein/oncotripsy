function out = KM_ode(t, x, c, rho_L, p_vap, p_partial, R0, gamma, f, Pus, Patm, surf_ten, nu)
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
    
    % Assume no viscocity!
    
    R = x(1);  % Radius of bubble (m)
    dR = x(2); % d/dt Radius of bubble (m/s)
    out = zeros(2,1);
    
    % Wall pressure
    P0 = p_vap + p_partial;
    
    Pw = (P0 + 2*surf_ten/R0) * ((R0/R) ^ (3*gamma)) + ...
        -2 * surf_ten/R + ...
        ... %-4*nu*dR/R + ...
        -P0 - Pus*sin(2*pi*f*t);
    
    dPw = (P0 + 2*surf_ten/R0)*(3*gamma)* ((R0/R) ^ (3*gamma-1))*(-R0/(R^2))*dR + ...
        +2 * surf_ten*dR/(R^2) + ...
        ... %-4*nu*(R*ddR-dR^2)/(R^2) + ...
        -Pus*2*pi*f*cos(2*pi*f*t);
    
%     % Bubble pressure
%     Pb = p_vap + p_partial * (R0/R) ^ (3*gamma);
%     dPb = p_partial * (3*gamma) * ((R0/R) ^ (3*gamma-1)) * (-R0/(R^2)) * dR;
%     Pinf = Patm + Pus * sin(2*pi*f*t);
    
    out(1) = dR; % d/dt Radius of bubble (m/s) OUT
    
    term1 = (1/rho_L) * (1+dR/c) * Pw;
    term2 = R/(rho_L*c) * dPw;
    term3 = (3/2 - dR/(2*c))*dR^2;
    term4 = (1-dR/c)*R;

    out(2) = (term1+term2-term3)/term4; % d2/dt2 Radius of bubble(m/s2)