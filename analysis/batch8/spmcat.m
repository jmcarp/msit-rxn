function outname = spmcat(spmmat, posidx, negidx)

global CCN;

posfile = savespm(spmmat, posidx, CCN.rfx.hthresh, ...
    CCN.rfx.ethresh, CCN.rfx.mctype);
negfile = savespm(spmmat, negidx, CCN.rfx.hthresh, ...
    CCN.rfx.ethresh, CCN.rfx.mctype);

[pospath posname] = fileparts(posfile);
[negpath negname] = fileparts(negfile);

posvol = spm_vol(posfile);
posimg = spm_read_vols(posvol);
negvol = spm_vol(negfile);
negimg = spm_read_vols(negvol);

outname = sprintf('%s/cat_%s_%s.img', pospath, posname, negname);
posvol.fname = outname;
posvol.dt = [8 0];
posvol = rmfield(posvol, 'pinfo');
spm_write_vol(posvol, posimg - negimg);