clc;
disp('This command moves the stage to the negative most point on all axes')
disp('Confirm that everything is disconnected from the motor stage')
disp(' ');
if strcmp(lower(input('Type CONFIRM to begin: ','s')),'confirm')

    sub_Close_All_Connections;
    params = sub_AllSettings('MoveToHome');
    params = sub_Stage_Initialize(params);

    s = params.Stages.Serial_Object;
    
    disp('-> Homing x motor')
    fprintf(s,['F,C,I' num2str(params.Stages.x_motor) 'M-0,R']);
    params = sub_Stage_Wait_Until_Ready(params);
    disp('---> Complete')

    disp('-> Homing y motor')
    fprintf(s,['F,C,I' num2str(params.Stages.y_motor) 'M-0,R']);
    params = sub_Stage_Wait_Until_Ready(params);
    disp('---> Complete')
    
    disp('-> Homing z motor')
    fprintf(s,['F,C,I' num2str(params.Stages.z_motor) 'M-0,R']);
    params = sub_Stage_Wait_Until_Ready(params);
    disp('---> Complete')
    
    disp('-> Zeroing Position Registers')
    fprintf(s,'F,C,N,R');
    params = sub_Stage_Wait_Until_Ready(params);
    disp('---> Complete')
    
else
    disp('CANCELLED')
    disp(' ')
end


