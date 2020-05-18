% Motor Stage - must be set near the focal point
%
% Function Generator must be manually set at center frequency
% - Run on repeat with timer at 1 ms, for 10 cycles

sub_Close_All_Connections;
params = sub_AllSettings('MoveAtAngle');

%% Setup the Initial Motor Stages Parameters
params = sub_Stage_Initialize(params);

%% Search

goal = 0.0325; 

% For 670 kHz transudcer 0.072 m, 48 us;
% For 500 khz transducer 0.0325, 21.6 us;
% For 100 kHz transducer 0.05268;

dist = -(0.0433 - goal); % in meters
steps = dist / params.Stages.step_distance;

i = 0;

angle = 20;

dim1 = params.Stages.z_motor;
dim1_factor = -sind(angle);
dim2 = params.Stages.y_motor;
dim2_factor = cosd(angle);

sub_Stage_Move(params, dim1, steps*dim1_factor);
sub_Stage_Move(params, dim2, steps*dim2_factor);
        