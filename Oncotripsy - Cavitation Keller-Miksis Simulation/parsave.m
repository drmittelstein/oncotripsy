function parsave(fn, tvec, Rvec, dRvec)
    save(sprintf('vars/tvec_i=%d.mat',fn), 'tvec')
    save(sprintf('vars/Rvec_i=%d.mat',fn), 'Rvec')
    save(sprintf('vars/dRvec_i=%d.mat',fn), 'dRvec')
end

