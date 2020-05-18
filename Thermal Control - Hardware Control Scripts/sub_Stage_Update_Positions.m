function params = sub_Stage_Update_Positions(params)

try; if params.Debug; return; end; end;

try

s = params.Stages.Serial_Object;

x = NaN; y = NaN; z = NaN;

params = sub_Stage_Wait_Until_Ready(params);

while isnan(x)
fprintf(s,'X'); 
while s.BytesAvailable < 8
    pause(0.005)
end
temp = fscanf(s,'%s',s.BytesAvailable);
ln_temp = numel(temp);
x = str2double(temp(max(1,ln_temp-7):ln_temp));
params = sub_Stage_Wait_Until_Ready(params);
end

while isnan(y)
fprintf(s,'Y'); 
while s.BytesAvailable < 8
    pause(0.005)
end
temp = fscanf(s,'%s',s.BytesAvailable);
ln_temp = numel(temp);
y = str2double(temp(max(1,ln_temp-7):ln_temp));
params = sub_Stage_Wait_Until_Ready(params);
end

while isnan(z)
fprintf(s,'Z'); 
while s.BytesAvailable < 8
    pause(0.005)
end
temp = fscanf(s,'%s',s.BytesAvailable);
ln_temp = numel(temp);
z = str2double(temp(max(1,ln_temp-7):ln_temp));
params = sub_Stage_Wait_Until_Ready(params);
end

params.Stages.Position = [x,y,z];

% Note that the x, y, and z are not corresponding 
% to the x, y, and z dimensions of our ultrasound stage

% Use these indices to get the x, y, and z positions
% params.Stages.x_motor = 2;
% params.Stages.y_motor = 3;
% params.Stages.z_motor = 1;

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
                    error('Cancelled attempts to reconnect to signal generator')
                end
                waitbar(toc/2,h)
            end
        end
        
    end
    
    try; delete(h); end;
    params = sub_Stage_Update_Positions(params);
end

end