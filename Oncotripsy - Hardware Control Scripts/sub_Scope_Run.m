% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% SUBROUTINE
% Press "Run" button on oscilloscope, essential gives real time readout rather than remaining on "Stop" after acquisition

function params = sub_Scope_Run(params)

fprintf(params.Scope.visaObj,':RUN');

end