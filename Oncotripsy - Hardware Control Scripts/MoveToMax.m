sub_Close_All_Connections;
params = sub_Stage_Initialize(params);

[~,I] = max(params.Scan.Objective);
loc = params.Scan.Location(:,I);

params = sub_Stage_Move_To(params, loc);