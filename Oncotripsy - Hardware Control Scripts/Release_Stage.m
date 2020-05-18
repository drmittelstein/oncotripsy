
sub_Close_All_Connections;
try
    params = sub_Stage_Initialize(params);  
catch
    params = sub_Stage_Initialize(struct);
end

s = params.Stages.Serial_Object;
fprintf(s,'Q');
