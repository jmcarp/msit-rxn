function prepconj(infile1, infile2, outfile, varargin)

global CCN;

if nargin >= 4
    sign1 = varargin{4};
else
    sign1 = 1;
end

if nargin >= 5
    sign2 = varargin{5};
else
    sign2 = 1;
end

thresh(infile1, sign1);
thresh(infile2, sign2);

vol1 = spm_vol(fileprep(infile1, 'rt'));
vol2 = spm_vol(fileprep(infile2, 'rt'));
volout = vol1;
volout.fname = outfile;

img1 = spm_read_vols(vol1);
img2 = spm_read_vols(vol2);
imgout = nan(size(img1));
vox1 = img1 > 0.25;
vox2 = img2 > 0.25;
imgout(vox1) = 1;
imgout(vox2) = 2;
imgout(vox1 & vox2) = 3;

spm_write_vol(volout, imgout);

% tempname = CCN.norm.hrtemp;
% spm_reslice({tempname volout.fname}, ...
%     struct('mean', 0, 'which', 1));

function thresh(infile, insign)

global CCN;

invol = spm_vol(infile);
inimg = spm_read_vols(invol);

outvol = invol;
outvol.fname = fileprep(invol.fname, 't');
spm_write_vol(outvol, sign(inimg) == insign);

tempname = CCN.norm.hrtemp;
spm_reslice({tempname outvol.fname}, ...
    struct('mean', 0, 'which', 1));