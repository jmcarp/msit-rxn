function mriconj(name1, name2, map1, map2)

vol1 = spm_vol(map1);
img1 = spm_read_vols(vol1);
sig1 = img1 > 0;
thr1 = zeros(size(img1));
thr1(sig1) = img1(sig1);

vol2 = spm_vol(map2);
img2 = spm_read_vols(vol2);
sig2 = img2 > 0;
thr2 = zeros(size(img2));
thr2(sig2) = img2(sig2);

outvol = vol1;
outvol.fname = sprintf('conj_%s_%s.img', name1, name2);

outimg = nan(size(img1));
outimg(sig1) = 1;
outimg(sig2) = 2;
outimg(sig1 & sig2) = 3;

spm_write_vol(outvol, outimg);

outvol.fname = sprintf('min_%s_%s.img', name1, name2);
outimg = nanmin(cat(4, thr1, thr2), [], 4);

spm_write_vol(outvol, outimg);
