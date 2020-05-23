% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Outputs a countdown in Matlab command window

function sub_Data_Countdown(trem, progress)
trem_str = '';

if trem > 60*60*24 % Day(s) remaining
    trem_str = [trem_str sprintf('%1.0f days, ', floor(trem/(24*60*60)))];
    trem = mod(trem, 24*60*60);
    trem_str = [trem_str sprintf('%02.0f hr, ', floor(trem/(60*60)))];
    trem = mod(trem, 60*60);
    trem_str = [trem_str sprintf('%02.0f min, ', floor(trem/(60)))];
    trem = mod(trem, 60);
    trem_str = [trem_str sprintf('%02.0f sec', floor(trem))];
    
elseif trem > 60*60 % Hours remaining
    trem_str = [trem_str sprintf('%02.0f hr, ', floor(trem/(60*60)))];
    trem = mod(trem, 60*60);
    trem_str = [trem_str sprintf('%02.0f min, ', floor(trem/(60)))];
    trem = mod(trem, 60);
    trem_str = [trem_str sprintf('%02.0f sec', floor(trem))];
    
elseif trem > 60 % Minutes remaining
    trem_str = [trem_str sprintf('%02.0f min, ', floor(trem/(60)))];
    trem = mod(trem, 60);
    trem_str = [trem_str sprintf('%02.0f sec', floor(trem))];
    
else % Seconds remaining
    trem_str = [trem_str sprintf('%02.0f sec', floor(trem))];
end

disp(sprintf('Progress %02.2f%% - Time Remaining: %s', ...
    100*progress, ...
    trem_str));

end