function params = sub_Stage_Move_Vec(params, vector)

if params.Stages.Speed > 6000
    disp('Cannot set motor speed above 6000 steps/second.  Using 6000 steps/second')
    params.Stages.Speed = 6000;
elseif params.Stages.Speed < 1
    disp('Cannot set motor speed below 1 step/second.  Using 1 step/second')
    params.Stages.Speed = 1;
end

if sum(size(vector) ~= size(params.Stages.Position));
    vector = vector'; % Rotate array if necessary
end

params = sub_Stage_Update_Positions(params);

desired_location = params.Stages.Position + vector;
dPos = vector;

while sum(floor(abs(dPos))) >= 1

    
    
    for i = 1:3 
        if abs(dPos(i)) >= 1
            params = sub_Stage_Move(params, i, dPos(i));
        end
    end

    params = sub_Stage_Update_Positions(params);
    dPos = desired_location - params.Stages.Position;

end
    
end


