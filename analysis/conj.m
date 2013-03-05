function mriconj(name1, name2, map1, map2)

vol1 = spm_vol(map1);
img1 = spm_read_vols(vol1);
sig1 = img1 > 0;

vol2 = spm_vol(map2);
img2 = spm_read_vols(vol2);
sig2 = img2 > 0;

outvol = vol1;
outvol.fname = sprintf('conj_%s_%s', name1, name2);

outimg = nan(size(img1));
outimg(sig1) = 1;
outimg(sig2) = 2;
outimg(sig1 & sig2) = 3;

spm_write_vols(outvol, outimg);