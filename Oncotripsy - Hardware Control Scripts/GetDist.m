sub_Close_All_Connections;

params = sub_AllSettings('GetDist');
params.Scope.averaging = 4096*2;
try
    params = sub_Scope_Initialize(params);
catch
    params = sub_Scope_Initialize(struct);
end



params.GUI.pkfig = figure(5); clf; hold on;
params.GUI.pkfig_SG = plot(0,0,'b'); 
params.GUI.pkfig_HP = plot(0,0,'r');
params.GUI.pkfig_SG_pk = plot(0,0,'bv');
params.GUI.pkfig_HP_pk = plot(0,0,'rv');

params.Scope.channels = [2 4];

params = sub_Scope_Readout_All(params);
            
A2 = params.Scope.Ch(2).YData; A2 = A2 - mean(A2); A2 = A2 ./ max(A2); A2(A2<-1) = -1;
A3 = -params.Scope.Ch(4).YData; A3 = A3 - mean(A3); A3 = A3 ./ max(A3); A3(A3<-1) = -1;
t = params.Scope.Ch(2).XData;
fs = 1/(t(2)-t(1)); %Sampling frequency

[pk2, tpk2] = findpeaks(A2,t,'MinPeakDistance',0.5/params.Transducer_Fc, 'MinPeakHeight',0.3);
[pk3, tpk3] = findpeaks(A3,t,'MinPeakDistance',0.5/params.Transducer_Fc, 'MinPeakHeight',0.3);

set(params.GUI.pkfig_SG, 'XData',t,'YData', A2); 
set(params.GUI.pkfig_HP, 'XData',t,'YData', A3);
set(params.GUI.pkfig_SG_pk, 'XData',tpk2,'YData',pk2);
set(params.GUI.pkfig_HP_pk, 'XData',tpk3,'YData',pk3);

xlim([min(t), tpk3(1) + 0.0001])

t_dist = tpk3(1) - tpk2(1);
s_dist = t_dist * params.Acoustic.MediumAcousticSpeed;
disp(sprintf('Distance (m): %1.3e',s_dist))
