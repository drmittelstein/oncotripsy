% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Send command to Velmex stage to move to the point with the highest params.Scan.Objective value
% This command must be run with a valid params file defined
% General use is after another command has been run that moves the stage

sub_Close_All_Connections;
params = sub_Stage_Initialize(params);

[~,I] = max(params.Scan.Objective);
loc = params.Scan.Location(:,I);

params = sub_Stage_Move_To(params, loc);