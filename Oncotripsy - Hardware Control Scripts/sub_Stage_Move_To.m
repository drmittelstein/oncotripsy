function params = sub_Stage_Move_To(params, desired_location)

try
    if params.Debug == 1
        params.Stages.Position = desired_location;
        return
    end
catch
end

if params.Stages.Speed > 6000
    disp('Cannot set motor speed above 6000 steps/second.  Using 6000 steps/second')
    params.Stages.Speed = 6000;
elseif params.Stages.Speed < 1
    disp('Cannot set motor speed below 1 step/second.  Using 1 step/second')
    params.Stages.Speed = 1;
end

if sum(size(desired_location) ~= size(params.Stages.Position));
    desired_location = desired_location'; % Rotate array if necessary
end

params = sub_Stage_Update_Positions(params);
dPos = desired_location - params.Stages.Position;

while sum(floor(abs(dPos))) >= 1

    s = params.Stages.Serial_Object;
    
    for i = 1:3 
        if round(dPos(i)) ~= 0
                sub_Stage_Move(params, i, dPos(i));
        end
    end

    params = sub_Stage_Update_Positions(params);
    dPos = desired_location - params.Stages.Position;

end

end