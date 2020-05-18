function params = sub_Stage_Cancel(params)

try
    if params.Debug == 1
        return
    end
catch
end

s = params.Stages.Serial_Object;

try
    fprintf(s,'V')
    status = fscanf(s,'%s',s.BytesAvailable);
    
    if numel(status) > 1
       status = status(end-1:end);
    end
    
    if status == 'B';
        fprintf(s,'K'); 
        fscanf(s,'%s',1);
    end
catch
end


end