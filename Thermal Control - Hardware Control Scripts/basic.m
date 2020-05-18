list=instrfind;
fclose(list);
clear all
clc
baud = 9600;
arduino=serial('COM5','BaudRate',baud);
fopen(arduino);
x=linspace(1,100);
y=zeros(1,100);   
for i=1:length(x)
y(i) = str2double(fscanf(arduino));
end
	
fclose(arduino);
disp('making plot..')
plot(x,y);