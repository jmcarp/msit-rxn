function smooth_b

global CCN;
clear matlabbatch;

% Options
opts = spm_get_defaults('smooth');
if isfield(CCN.smooth, 'opts')
    opts = catstruct(opts, CCN.smooth.opts);
end

data = expandpath(CCN.ffiles);

matlabbatch{1}.spm.spatial.smooth = opts;

matlabbatch{1}.spm.spatial.smooth.data = volseq(data, true);

spm_jobman('run', matlabbatch);