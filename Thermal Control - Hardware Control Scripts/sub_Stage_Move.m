function params = sub_Stage_Move(params,motor_num,num_steps)

try
    if params.Debug == 1
        params.Stages.Position(motor_num) = params.Stages.Position(motor_num) + num_steps;
        return
    end
catch
end

try 
    
if params.Stages.Speed > 6000
    disp('Cannot set motor speed above 6000 steps/second.  Using 6000 steps/second')
    params.Stages.Speed = 6000;
elseif params.Stages.Speed < 1
    disp('Cannot set motor speed below 1 step/second.  Using 1 step/second')
    params.Stages.Speed = 1;
end

s = params.Stages.Serial_Object;
num_steps = round(num_steps);

if num_steps ~= 0
    
    string = sprintf('F,C,S%1.0fM%1.0f,I%1.0fM%1.0f,R', ...
        motor_num, params.Stages.Speed, motor_num, num_steps);
    
    fprintf(s,string);
    params = sub_Stage_Wait_Until_Ready(params);

    % Swtich off the off-line mode (to enable joystick control)
    % fprintf(s,'Q');
end

% Note, if your motor is not responding to commands, check to make sure
% that one of the physical axis limit buttons is being pressed

catch
      
    connected = 0;
    while ~connected
        try
        
        params = sub_Stage_Initialize(params);
        connected = 1;
        catch ex
            disp(['ERROR: ' ex.message])
            h = waitbar(0, sprintf('Stage is not responding.  Attempting to reset connection\nERROR: %s', ex.message), 'CrateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
            tic
            while toc<2
                if getappdata(h,'canceling')
                    error('Cancelled attempts to reconnect to ')
                end
                waitbar(toc/2,h)
            end
        end
        
    end
    
    try; delete(h); end;
    params = sub_Stage_Move(params,motor_num,num_steps);
end

end

