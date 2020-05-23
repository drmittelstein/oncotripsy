% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Initialize connetion to the Velmex stage

function params = sub_Stage_Initialize(params)

try
    if params.Debug == 1
        params.Stages.Origin = [0 0 0];
        params.Stages.Position = [0 0 0];
        params.Stages.RandomLocation = [0 0 0]; %rand(3,1) * 5000;
        return
    end
catch
end

params.Stages.Motors_Connected = 0;

% Global Stage Parameters
params.Stages.step_distance = 0.0254/10/400; % Translation Distance (m) Per Step For each motor (motors are the same)

% Assignment of Motor numbers to axes (as per the definition image)
params.Stages.x_motor = 2;
params.Stages.y_motor = 3;
params.Stages.z_motor = 1;

params.Stages.Motor_Connected = 0;

% Connect to motors
disp('- Attempting to find Velmex Stage on last successful COM port')
try
    load('lastloaded.mat', 'lastloaded');

    params.Stages.COM_port = lastloaded.COM_Stages;
    port = str2num(lastloaded.COM_Stages(4:end));
    params.Stages.Serial_Object = serial(params.Stages.COM_port);
    fopen(params.Stages.Serial_Object);
    disp(sprintf('   > Established port COM%d', port));
    fprintf(params.Stages.Serial_Object,'V'); 
    status = fscanf(params.Stages.Serial_Object,'%s',1);
    if strcmp(status,'R') || strcmp(status,'J');
        params.Stages.Motor_Connected = 1;  
        params = sub_Stage_Cancel(params);
        params = sub_Stage_Wait_Until_Ready(params);
        params = sub_Stage_Update_Positions(params);
        params.Stages.Origin = params.Stages.Position;
        disp(sprintf('   > Connected to Velmex Stage on COM%1.0f', port));
    else
        disp(sprintf('   > But it is not Velmex'))
        fclose(params.Stages.Serial_Object);
        delete(instrfind('Name', sprintf('Serial-COM%1.0f',port)));
    end
catch
    disp(sprintf('   > But it is not Velmex'))
end

if ~params.Stages.Motor_Connected
disp('- Attempting to find Velmex Stage on COM port');
delete(instrfind('status', 'closed'));
% First try to connect without disconnecting any devices
port = 2;
params.Stages.Motor_Connected = 0;
while port < 100 && ~params.Stages.Motor_Connected
    try
        port = port + 1;
        params.Stages.COM_port = sprintf('COM%1.0f', port);
        params.Stages.Serial_Object = serial(params.Stages.COM_port);
        fopen(params.Stages.Serial_Object);
        disp(sprintf('   > Established port COM%d', port));
        fprintf(params.Stages.Serial_Object,'V'); 
        status = fscanf(params.Stages.Serial_Object,'%s',1);
        if strcmp(status,'R') || strcmp(status,'J');
            params.Stages.Motor_Connected = 1;  
            params = sub_Stage_Cancel(params);
            params = sub_Stage_Wait_Until_Ready(params);
            params = sub_Stage_Update_Positions(params);
            params.Stages.Origin = params.Stages.Position;
            disp(sprintf('   > Connected to Velmex Stage on COM%1.0f', port));
        else
            disp(sprintf('   > But it is not Velmex'))
            fclose(params.Stages.Serial_Object);
            delete(instrfind('Name', sprintf('Serial-COM%1.0f',port)));
        end
    catch
    end
end
end

if ~params.Stages.Motor_Connected
disp('   > Could not find Stage on unused ports, now looking through used ports')
disp('     this may cause other devices to disconnect');
delete(instrfind('status', 'closed'));
% Now try to connect with disconnecting other devices
port = 2;
while port < 100 && ~params.Stages.Motor_Connected
    try
        port = port + 1;
        dvcs = instrfind('Name', sprintf('Serial-COM%1.0f',port));
        
        if numel(dvcs) > 0
            disp(sprintf('   > Disconnected device on COM%1.0f', port));
            delete(dvcs);
        end
        
        params.Stages.COM_port = sprintf('COM%1.0f', port);
        params.Stages.Serial_Object = serial(params.Stages.COM_port);
        fopen(params.Stages.Serial_Object);
        disp(sprintf('   > Established port COM%d', port));
        fprintf(params.Stages.Serial_Object,'V'); 
        status = fscanf(params.Stages.Serial_Object,'%s',1);
        if strcmp(status,'R') || strcmp(status,'J');
            params.Stages.Motor_Connected = 1;  
            params = sub_Stage_Cancel(params);
            params = sub_Stage_Wait_Until_Ready(params);
            params = sub_Stage_Update_Positions(params);
            params.Stages.Origin = params.Stages.Position;
            disp(sprintf('   > Connected to Velmex Stage on COM%1.0f', port));
        else
            disp(sprintf('   > But it is not Velmex'))
            fclose(params.Stages.Serial_Object);
            delete(instrfind('Name', sprintf('Serial-COM%1.0f',port)));
        end
        
    catch
        % Didn't connect :(
    end
end

end

delete(instrfind('status', 'closed'));
if ~params.Stages.Motor_Connected
    error('Could not connect to motor stage');
else
    lastloaded = struct;
    lastloaded.COM_Stages = params.Stages.COM_port;
    save('lastloaded.mat', 'lastloaded');
end

end