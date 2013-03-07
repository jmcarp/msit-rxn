% function ccnjob(matname)
function ccnjob

matname = '/data/1/jmc/data/fbirn/site0009/tmpmat/none_none_realign_def_def_anat_fwhm4_none_none_none_none_none.mat';

global CCN;
clear CCN;

load(matname);

batch8;

exit;