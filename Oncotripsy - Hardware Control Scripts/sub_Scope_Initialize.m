% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Form a connection to the oscilloscope

function params = sub_Scope_Initialize(params)

if params.Debug == 1; return; end

try; clrdevice(params.Scope.visaObj); end
try; fclose(params.Scope.visaObj); end

params.Scope.visaObj = [];
params.Scope.readout.sampling_rate = 200*10^6;

addresses = {...
    'USB0::2391::6042::MY55461039::INSTR', ...
    'USB0::2391::6042::MY55461039::0::INSTR', ...
    'USB0::2391::6042::MY55461040::INSTR', ...
    'USB0::2391::6042::MY55461040::0::INSTR', ...
    'USB0::2391::6056::MY53480443::INSTR', ...
    'USB0::0x0957::0x175D::MY50340397::INSTR', ...
    'USB0::0x0957::0x17A8::MY53480443::0::INSTR', ...
    'USB0::0x0957::0x17A8::MY53480443::0', ...
    'USB0::0x0957::0x17A8::MY53480443::INSTR', ...
    'USB0::0x0957::0x17A8::MY53480443::0::INSTR', ...
    };

for i = 1:numel(addresses)  
   try
       address = addresses{i};
       delete(instrfind('RsrcName', address));
       visaObj = visa('agilent', address); 
       visaObj.InputBufferSize = 10000000; 
       visaObj.Timeout = 30; 
       visaObj.ByteOrder = 'littleEndian';
       visaObj.EOSMode = 'read&write';
       fopen(visaObj);
       
       pause(1);
       if query(visaObj, '*OPC?')
           params.Scope.visaObj = visaObj;
           disp(sprintf('- Connected to Scope through VISA %s', address))
           break % If a connection was successful, then break the 
           
       else
           disp(sprintf('- Frozen VISA connection to %s', address))
           pause(1);
           clrdevice(visaObj)
           pause(1);
            if query(visaObj, '*OPC?')
                params.Scope.visaObj = visaObj;
                disp(sprintf('- Connected to Scope through VISA %s', address))
                break % If a connection was successful, then break the 
            end
       end
   catch
   end
end

delete(instrfind('status', 'closed'))

if isempty(params.Scope.visaObj)
    error('Could not connect to oscilloscope')
end

% Set Oscilloscope Settings
if ~params.Scope.MaintainSettings 
params = sub_Scope_ApplySettings(params);
end


end