sub_Close_All_Connections;
params = sub_Stage_Initialize(struct);
params = sub_Stage_Update_Positions(params);

save('origin.mat','params')