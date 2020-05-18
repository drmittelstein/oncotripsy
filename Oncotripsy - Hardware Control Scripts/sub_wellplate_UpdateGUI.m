function sub_wellplate_UpdateGUI(params)
try
        set(params.GUI.h_Details,'String',params.GUI.Details)
        set(params.GUI.h_Status,'String',params.GUI.Status)
        set(params.GUI.h_ExpFileName,'String',params.GUI.Title)
        
    if params.GUI.TimersEnabled
        t_well_rem = params.GUI.CurrentWellTotalTime - params.GUI.CurrentWellTime;
        t_tot_rem = params.GUI.TotalTime - params.GUI.PriorWellTime - params.GUI.CurrentWellTime;
               
        set(params.GUI.h_WellTime,'String',sprintf('Well Time Left\n%03.0f:%02.0f',floor(t_well_rem/60),floor(mod(t_well_rem,60))))
        set(params.GUI.h_TotalTime,'String',sprintf('Total Time Left\n%03.0f:%02.0f',floor(t_tot_rem/60),floor(mod(t_tot_rem,60))))
        set(params.GUI.h_Progress_Well,'Position',[0 0 max(0.1,40*params.GUI.CurrentWellTime/params.GUI.CurrentWellTotalTime) 2])
        set(params.GUI.h_ProgressTotal,'Position',[0 0 max(0.1,40*(params.GUI.PriorWellTime + params.GUI.CurrentWellTime)/params.GUI.TotalTime) 2])
    else
        set(params.GUI.h_WellTime,'String','Well Time Left')
        set(params.GUI.h_TotalTime,'String','Total Time Left')
        set(params.GUI.h_Progress_Well,'Position',[0 0 0.1 2])
        set(params.GUI.h_ProgressTotal,'Position',[0 0 0.1 2])
    end
    
    drawnow
end 