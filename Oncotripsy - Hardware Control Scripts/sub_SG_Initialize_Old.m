function params = sub_SG_Initialize(params)

try
    if params.Debug == 1
        return
    end
catch
end

try; fclose(params.SG.visaObj); end; % Try to close visaObj if open
params.SG.Initialized = 0;

visa_types = {...
    'agilent';
    'ni'};
    
tabor_addresses = {...
    'USB0::0x168C::0x128C::0000215554::0::INSTR';
    'USB0::0x168C::0x128C::0000215554::0'};

for i = 1:numel(tabor_addresses);
try
if ~params.SG.Initialized
address = tabor_addresses{i};

% First try connecting to the Tabor
delete(instrfind('RsrcName', address));
params.SG.address = address;

% Initialize the Tabor
params.SG.visaObj = visa('ni',params.SG.address);
params.SG.visaObj.InputBufferSize = 100000;
params.SG.visaObj.OutputBufferSize = 100000;
params.SG.visaObj.Timeout = 10;
params.SG.visaObj.ByteOrder = 'littleEndian';

% Open the connection
fopen(params.SG.visaObj); 
params.SG.Initialized = 1;
params.SG.Instrument = 'TABOR';
disp('- Connected to TABOR Signal Generator')
end
catch ex
    disp(ex.message)
end
end

bkp_addresses = {...
    'USB0::0xF4EC::0xEE38::515F18109::0::INSTR';
    'USB0::0xF4EC::0xEE38::515F18109::INSTR';
    'USB0::0xF4ED::0xEE3A::388G16168::0::INSTR';
    'USB0::0xF4ED::0xEE3A::388G16168::INSTR'};
   
for j = 1:numel(visa_types)
visatype = visa_types(j);

for i = 1:numel(bkp_addresses)
address = bkp_addresses{i};

try
    if ~params.SG.Initialized

    % Then try connecting to the BK
    delete(instrfind('RsrcName', address));
    params.SG.address = address;

    % Initialize the BK
    disp(visatype)
    disp(address)
    params.SG.visaObj = visa(visatype, address);
    params.SG.visaObj.InputBufferSize = 100000;
    params.SG.visaObj.OutputBufferSize = 100000;
    params.SG.visaObj.Timeout = 10;
    params.SG.visaObj.ByteOrder = 'littleEndian';

    % Open the connection
    fopen(params.SG.visaObj); 
    params.SG.Initialized = 1;
    params.SG.Instrument = 'BKP';
    disp('- Connected to BKP Signal Generator')

    end
    
catch

end

end
end

if params.SG.Initialized == 0;
    error('Could not connect to Signal Generator');
end
end