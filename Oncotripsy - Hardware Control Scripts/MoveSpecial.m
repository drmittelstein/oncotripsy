sub_Close_All_Connections;

%% Setup the Initial Motor Stages Parameters
params = sub_AllSettings('MoveSpecial');
params = sub_Stage_Initialize(params);

%% Search

sub_Stage_Move(params, params.Stages.z_motor, 0 .* params.Plate.welldistance / params.Stages.step_distance);
sub_Stage_Move(params, params.Stages.y_motor, 0 .* params.Plate.welldistance / params.Stages.step_distance);
sub_Stage_Move(params, params.Stages.x_motor, -1 .* params.Plate.welldistance / params.Stages.step_distance);
        

% sub_Stage_Move(params, params.Stages.y_motor, 0.006 / params.Stages.step_distance);