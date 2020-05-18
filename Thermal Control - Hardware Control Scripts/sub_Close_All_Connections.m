function sub_Close_All_Connections

try
    allinstruments = instrfind;
    for i = 1:numel(allinstruments);
        fclose(allinstruments(i));
    end
    clear allinstruments
catch
end

try
    disconnect(params.Scope.QCScope);
    clear params.Scope.QCScope;
catch
end

try % Delete instrfind
     delete(instrfind)
catch
end

try % Close Stages Connection
    fclose(params.Stages.Serial_Object);
    params.Stages.Motors_Connected = 0;
catch
end

try % Close Scope Connection
    delete(params.Scope.visaObj);
    params.Scope = rmfield(params.Scope,'visaObj');
catch
end

try % Close SG Connection
    delete(params.SG.visaObj);
    params.SG = rmfield(params.SG,'visaObj');
catch
end

end