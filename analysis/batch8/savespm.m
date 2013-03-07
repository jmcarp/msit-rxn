function outname = savespm(spmmat, conidx, u, k, mctype)

% Load SPM
load(spmmat);
spmpath = fileparts(spmmat);

xSPM = struct();

% SPM directory
xSPM.swd = spmpath;

% Choose t-map
xSPM.STAT = 'T';

% Misc
xSPM.Im = [];
xSPM.pm = [];

% Uncorrected threshold
xSPM.thresDesc = 'none';

% Height threshold
df = [SPM.xCon(conidx).eidf SPM.xX.erdf];
if strcmp(mctype, 'none')
    xSPM.u = spm_u(u, df, 'T');
    xSPM.thresDesc = 'none';
elseif strcmp(mctype, 'fdr')
    xSPM.u = u;%spm_uc_FDR(u, df, 'T', 1, SPM.xCon(conidx).Vspm);
    xSPM.thresDesc = 'FDR';
end

% Extent threshold
xSPM.k = k;

% Contrast index
xSPM.Ic = conidx;
xSPM.title = SPM.xCon(conidx).name;

% Get thresholded SPM
[SPM xSPM] = spm_getSPM(xSPM);

% Write thresholded SPM
outname = sprintf('%s/%s.img', spmpath, regexprep(xSPM.title, '[\s]', ''));
spm_write_filtered(xSPM.Z, xSPM.XYZ, xSPM.DIM, xSPM.M, ...
    xSPM.title, outname);