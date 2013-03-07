function coreg(tovol, fromvol)

global CCN;

% Estimation options
eopts = spm_get_defaults('coreg.estimate');
if isfield(CCN.coreg, 'eopts')
    eopts = catstruct(eopts, CCN.coreg.eopts);
end

% Write options
wopts = spm_get_defaults('coreg.write');
if isfield(CCN.coreg, 'wopts')
    wopts = catstruct(wopts, CCN.coreg.wopts);
end

if ~CCN.coreg.reslice
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {tovol.fname};
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {fromvol.fname};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions = eopts;
else
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {tovol.fname};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {fromvol.fname};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions = eopts;
    matlabbatch{1}.spm.spatial.coreg.estwrite.woptions = wopts;
end

% Run
spm_jobman('run', matlabbatch);