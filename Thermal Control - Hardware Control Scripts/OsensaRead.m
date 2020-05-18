%OsensaRead
%Author: Hunter Davis Ozawa
%Date: 5/17/2018
%Program for reading and storing temperature from OSENSA fiber thermometer.
%Data is brought in through buffering with timing between data points
%handled by hardware. This provides flexibility to adjust data live without
%worrying about missing data from the stream. Data buffering happens in
%three stages. A max of 100 raw serial data is buffered through the 
%serial COM input buffer. Unless something goes wrong, this should never
%come close to filling up. Every time readTemp is called, the full
%available buffer is read into program memory under DirectBuffer. Next,
%unfilled entries are clipped out of DirectBuffer and the resulting array
%is concatenated onto the StreamBuffer, the main program buffer.
%StreamBuffer should be used for any PID calculations, control operations,
%etc. Because the Arduino is handling sample timing, there is a
%hardware-defined 10ms sample time. This can be adjusted as needed, but it
%should be plenty fast for your application. In order to stop the
%acquisition, click the STOP Buttion on the figure that automatically gets
%opened when acquisition commences. (Note that the program will take ~4
%seconds to initialize.

%Clear all Serial Devices to make sure the COM port is open
list=instrfind;
for i = 1:numel(list)
    fclose(list(i));
end
delete(list);
clearvars;
 
%Initialize the COM connection
Therm=setupSerial('COM5');
pause(2);

%Initialize Data Buffers
Buffer_Length=2000;
index=1:Buffer_Length;
ArduinoBufferSize=1000;
StreamBuffer=zeros(size(index));
DirectBuffer=zeros(size(1,ArduinoBufferSize));

if (~exist('h','var') || ~ishandle(h))
    h = figure(1);
    set(h,'UserData',1);
end

if (~exist('button','var'))
    button = uicontrol('Style','togglebutton','String','Stop',...
        'Position',[0 0 50 25], 'parent',h);
end

fprintf(Therm,'%i',1); %Trigger Arduino Acquisition

%The mechanics of the following loop should be integrated into the main control loop
%of your final application. In order to make the US respond to changes in
%temperature, you will likely want to run a PID feedback loop. I am happy
%to help with this if needed. As far as logging data goes, let me know what
%kind of data you want saved. If you want the entire acquisition saved to a
%date-time stamped text file, that is pretty easy.

while (get(button,'Value') == 0 )
    DirectBuffer = readTemp(Therm,ArduinoBufferSize);
    ClippedBuffer=DirectBuffer(DirectBuffer>-.5);
    StreamBuffer = [StreamBuffer(size(ClippedBuffer,2):end),ClippedBuffer];
    plot(StreamBuffer)
    drawnow;
    pause(.05);
end
fprintf(Therm,'%i',0); %Terminate Arduino Acquisition
fclose(Therm);
