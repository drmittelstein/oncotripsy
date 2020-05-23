% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Send command to Velmex stage to move back to the origin
% This command must be run with a valid params file defined
% General use is after another command has been run that moves the stage

org = params.Stages.Origin;

try;
    sub_Stage_Move_To(params, org);
catch 
    params_old = params;
    
    sub_Close_All_Connections;

    params = sub_AllSettings('BackToOrigin');
    params = sub_Stage_Initialize(params);
    sub_Stage_Move_To(params, org);
end



