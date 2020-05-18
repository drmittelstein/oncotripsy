function params = sub_Stage_Wait_Until_Ready(params)

% Loop checking status until it's ready
ready_flag = 0;

try

h_tic_stage = tic;
    
while ready_flag == 0 || toc(h_tic_stage) > 60
    fprintf(params.Stages.Serial_Object,'V'); 
    status = fscanf(params.Stages.Serial_Object,'%s',1);
    params.Stages.Status = status;
    if strcmp(status,'R') || strcmp(status,'J') %|| strcmp(status,'E')
        ready_flag = 1;
    else
        pause(10/1000); % Pause for 10 ms before next check
    end
    
end

if toc(h_tic_stage) >= 60
    warning('Stage did not respond, ended operation');
    fprintf(params.Stages.Serial_Object,'K'); 
    fscanf(params.Stages.Serial_Object,'%s',1);
end


% Clear the output buffer
if params.Stages.Serial_Object.BytesAvailable ~= 0 
    fscanf(params.Stages.Serial_Object,'%s',params.Stages.Serial_Object.BytesAvailable);
end

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
                    error('Cancelled attempts to reconnect to stage')
                end
                waitbar(toc/2,h)
            end
        end
        
    end
    
    try; delete(h); end;
    params = sub_Stage_Wait_Until_Ready(params);
end


end