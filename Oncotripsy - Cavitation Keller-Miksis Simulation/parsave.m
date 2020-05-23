% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Subroutine: Saves output variables (required for parfor operation)

function parsave(fn, tvec, Rvec, dRvec)
    save(sprintf('vars/tvec_i=%d.mat',fn), 'tvec')
    save(sprintf('vars/Rvec_i=%d.mat',fn), 'Rvec')
    save(sprintf('vars/dRvec_i=%d.mat',fn), 'dRvec')
end

