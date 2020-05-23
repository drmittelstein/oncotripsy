% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Send a command to the Velmex to enable manual control of the stage using buttons

sub_Close_All_Connections;
try
    params = sub_Stage_Initialize(params);  
catch
    params = sub_Stage_Initialize(struct);
end

s = params.Stages.Serial_Object;
fprintf(s,'Q');
