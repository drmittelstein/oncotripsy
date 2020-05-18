function [output] = readTemp(s,BufferSize)
% Serial send read request to Arduino
nn=2;
RAWADC=ones(1,BufferSize).*-1;
Temp_Low=0;
Temp_High=60;
Resistor=220;
% Read value returned via Serial communication 
readout = fscanf(s);
RAWADC = str2double(readout );
 while s.BytesAvailable>0
    readout = fscanf(s);
    RAWADC(nn) = str2double(readout);
    nn=nn+1;
 end
V=RAWADC/1023*5;
output=((V/Resistor)-4e-3)*((Temp_High-Temp_Low)/16e-3)+Temp_Low;
end