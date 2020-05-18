function[obj] = setupSerial(comPort)
% It accept as the entry value, the index of the serial port
% Arduino is connected to, and as output values it returns the serial 
% element obj and a flag value used to check if when the script is compiled
% the serial element exists yet.
% Initialize Serial object
obj = serial(comPort);
set(obj,'DataBits',8);
set(obj,'StopBits',1);
set(obj,'BaudRate',9600);
set(obj,'Parity','none');
set(obj,'Terminator','LF');
obj.ReadAsyncMode = 'continuous';
fopen(obj);
end