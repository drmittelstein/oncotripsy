% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Initialize a connection to the signal generator

function params = sub_SG_Initialize(params)

try
    if params.Debug == 1
        params.SG.Initialized = 1;
        params.SG.Instrument = 'BKP';
        return
    end
catch
end

try; fclose(params.SG.visaObj); end; % Try to close visaObj if open

%% Setup the Initial Tabor Parameters

disp('- Connecting to Signal Generator')
 
try       
addresses = {...
   'USB0::0xF4ED::0xEE3A::388G16168::0::INSTR'; ...
   'USB0::0xF4ED::0xEE3A::388G16168::INSTR'; ...
   'USB0::0xF4EC::0xEE38::515F18109::0::INSTR'
   };
% Then try connecting to the BK

params.SG.Initialized = 0;

for i = 1:numel(addresses)
    if ~params.SG.Initialized
        try
        delete(instrfind('RsrcName', addresses{i}));
        params.SG.address = addresses{i};

        % Initialize the BK
        params.SG.visaObj = visa('agilent',params.SG.address);
        params.SG.visaObj.InputBufferSize = 100000;
        params.SG.visaObj.OutputBufferSize = 100000;
        params.SG.visaObj.Timeout = 10;
        params.SG.visaObj.ByteOrder = 'littleEndian';

        % Open the connection
        fopen(params.SG.visaObj); 
        params.SG.Initialized = 1;
        params.SG.Instrument = 'BKP';
        disp(sprintf('   > Connected to %s', strtrim(query(params.SG.visaObj, '*IDN?'))))
        disp(sprintf('   > on %s', params.SG.address))
        catch
        end
    end
end


catch
error('Could not connect to Signal Generator');
end
   

if ~params.SG.Initialized
    error('Could not connect to Signal Generator.  This is a VISA based connection, not solved by adjusting the COM Port.  Check to make sure the signal generator is powered on and plugged in to the USB')
end

end