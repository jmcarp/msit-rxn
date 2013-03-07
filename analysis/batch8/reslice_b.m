function reslice_b

global CCN;

% Reslice to target image
data = expandpath(CCN.ffiles);
spm_reslice([{CCN.reslice.resimg} data]);

% Delete original files
if isfield(CCN.reslice, 'delorig') && ...
        CCN.reslice.delorig
    for imgidx = 1 : length(data)
        delimg(data{imgidx});
    end
end