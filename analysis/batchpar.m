function batchpar

global CCN;
CCN = struct();

% CCN.steps = { 'slice_b' 'realign_b' };
% CCN.steps = { 'slice_b' 'realign_b' 'coregister_b' 'segment_b' ...
%     'normalise_b' 'smooth_b' };
% CCN.steps = { 'model_b' 'contrast_b' };
% CCN.steps = { 'model_b' };
% CCN.steps = { 'contrast_b' };
% CCN.steps = { 'rfx_b' };
CCN.steps = { 'roixtract_b' };
% CCN.steps = { 'readfir_b' };
% CCN.steps = { 'contrast_b' };

CCN.root_dir   = '/data/2/jmc/data/msit';
CCN.psdir      = sprintf('%s/ps', CCN.root_dir);
CCN.logdir     = sprintf('%s/log', CCN.root_dir);
CCN.behavdir   = sprintf('%s/behav', CCN.root_dir);
CCN.specdir    = sprintf('%s/spec', CCN.root_dir);

CCN.run_pattern = 'run_\\d{2}';

CCN.fdirs    = '[root_dir]/subjs/[subject]/[run_pattern]$';
CCN.hrpat    = '[root_dir]/subjs/[subject]/\/t1spgr.nii';
CCN.ovpat    = '[root_dir]/subjs/[subject]/\/t1overlay.nii';
CCN.ffiles   = '[root_dir]/subjs/[subject]/[run_pattern]/[curr_pattern]';
CCN.meanpat  = '[root_dir]/subjs/[subject]/[run_pattern]/meanaprun_\d{2}\.nii';
CCN.pspat    = '[psdir]/[subject]_[step]';
CCN.subjpat  = '[root_dir]/subjs/\d{6}\w{2}$';
CCN.rppat    = '[root_dir]/subjs/[subject]/[run_pattern]/rp_aprun_\d{2}\.txt';

% Get subjects
% Bad subjects:
% 110427vm: head motion
% 110528tt: fell asleep
badsubjs = { '110427vm' '110528tt' };
CCN.subjs = expandpath(CCN.subjpat, true);
CCN.subjs = setdiff(CCN.subjs, badsubjs);

% CCN.subjs = CCN.subjs(1);
% CCN.subjs = { '110703rb' };

CCN.file_pattern = struct( ...
    'default',           'prun_\\d{2}\\.nii', ... 
    'despike_b',         'prun_\\d{2}\\.nii', ...
    'slice_b',           'prun_\\d{2}\\.nii', ...
    'realign_b',         'aprun_\\d{2}\\.nii', ...
    'coregister_b',      'meanaprun_\\d{2}\\.nii', ...
    'normalise_b',       'aprun_\\d{2}\\.nii', ...
    'smooth_b',          'waprun_\\d{2}\\.nii', ... 
    'model_b',           'swaprun_\\d{2}\\.nii');
CCN.curr_pattern = CCN.file_pattern.default;

CCN.TR = 1.25;

CCN.despike.opts = '';

% Slice order = [ 'asc' 'dsc' 'int' ]
CCN.slice.seq = 'asc';

CCN.realign = struct();

CCN.realign.reslice = true;

CCN.coreg.reslice = true;

CCN.coreg.twostage = true;

CCN.bet.opts = '-R';

CCN.seg.method = 'vbm';

% CCN.norm.hrtemp = fullfile(spm('Dir'), 'templates', 'T1.nii');
% CCN.norm.hrtemp = fullfile(spm('Dir'), 'templates', 'T2.nii');
CCN.norm.hrtemp = '/data/4/jmc/tools/templates/MNI152_T1_1mm_brain.nii';

% CCN.norm.normtype = 'func';
CCN.norm.normtype = 'anat';
% CCN.norm.normtype = 'seg';

% CCN.norm.bet = false;
CCN.norm.prefix = 's';

CCN.norm.writenorm = true;
% CCN.norm.writenorm = false;

CCN.norm.fwopts = struct( ...
    'vox', [3.4375 3.4375 4.5] ...
    );

CCN.smooth.opts = struct(...
    'fwhm', [8 8 8] ...
    );

% Time units [ 'secs' | 'scans' ]
CCN.model.units = 'secs';

CCN.model.orth = true;

% Basis function [ 'hrf' | 'fir' ]
CCN.model.basis = 'hrf';
% CCN.model.basis = 'fir';

CCN.model.length = 24;
% CCN.model.length = 8 * 1.25;

CCN.model.catruns = false;

CCN.model.thresh = -inf;
CCN.model.mask = fullfile(spm('dir'), 'apriori', 'brainmask_th125.nii');

% Global normalisation [ 'None' | 'Scaling' ]
CCN.model.global = 'None';
% CCN.model.global = 'Scaling';

% High-pass filter
CCN.model.hpf = 128;

% Serial correlations [ 'AR(1)' | 'none' ]
CCN.model.cvi = 'AR(1)';
% CCN.model.cvi = 'none';

CCN.model.spec_file = '[specdir]/model_[subject].m';
% CCN.model.spec_file = '[specdir]/model_poly_[subject].m';
% CCN.model.spec_file = '[specdir]/model_fir_[subject].m';

% Motion regressors [ true | false ]
CCN.model.rpreg = true;

% Motion regressor power expansion [ 1 ]
CCN.model.rppow = 2;
% Motion regressor spin history [ 0 ]
CCN.model.rpspin = 1;

% CCN.model.model_dir = '[root_dir]/subjs/[subject]/analysis/model';
CCN.model.model_dir = '[root_dir]/subjs/[subject]/analysis/model_paper';
% CCN.model.model_dir = '[root_dir]/subjs/[subject]/analysis/model_poly';
% CCN.model.model_dir = '[root_dir]/subjs/[subject]/analysis/model_fir';

CCN.model.overwrite = true;

% Estimate model [ true | false ]
CCN.model.est = true;
% CCN.model.est = false;

CCN.contr.splitsess = false;
CCN.contr.expandfir = false;

CCN.contr.condnames = { ...
    'msit-con' 'msit-conxrt^1' ...
    'msit-inc' 'msit-incxrt^1' ...
    'simple'   'simplexrt^1' ...
};
% CCN.contr.condnames = { ...
%     'msit-con' 'msit-conxrt^1' 'msit-conxrt^2' 'msit-conxrt^3' 'msit-conxrt^4' ...
%     'msit-inc' 'msit-incxrt^1' 'msit-incxrt^2' 'msit-incxrt^3' 'msit-incxrt^4' ...
%     'simple'   'simplexrt^1'   'simplexrt^2'   'simplexrt^3'   'simplexrt^4' ...
% };

CCN.contr.contrs = struct();

CCN.contr.contrs.all     = [ 1 0 1 0 1 0 ];
CCN.contr.contrs.msit    = [ 1 0 1 0 0 0 ];
CCN.contr.contrs.con     = [ 1 0 0 0 0 0 ];
CCN.contr.contrs.inc     = [ 0 0 1 0 0 0 ];
CCN.contr.contrs.simp    = [ 0 0 0 0 1 0 ];

CCN.contr.contrs.ivc     = [ -1 0 1 0 0 0 ];
CCN.contr.contrs.cvi     = [ 1 0 -1 0 0 0 ];
CCN.contr.contrs.mvs     = [ 1 0 1 0 -2 0 ];
CCN.contr.contrs.svm     = [ -1 0 -1 0 2 0 ];
CCN.contr.contrs.cvs     = [ 1 0 0 0 -1 0 ];
CCN.contr.contrs.svc     = [ -1 0 0 0 1 0 ];
CCN.contr.contrs.ivs     = [ 0 0 1 0 -1 0 ];
CCN.contr.contrs.svi     = [ 0 0 -1 0 1 0 ];

CCN.contr.contrs.allRT   = [ 0 1 0 1 0 1 ] ./ 3;
CCN.contr.contrs.msitRT  = [ 0 1 0 1 0 0 ] ./ 2;
CCN.contr.contrs.conRT   = [ 0 1 0 0 0 0 ];
CCN.contr.contrs.incRT   = [ 0 0 0 1 0 0 ];
CCN.contr.contrs.simpRT  = [ 0 0 0 0 0 1 ];
CCN.contr.contrs.all     = [ 1 0 1 0 1 0 ] ./ 3;
CCN.contr.contrs.msit    = [ 1 0 1 0 0 0 ] ./ 2;
CCN.contr.contrs.con     = [ 1 0 0 0 0 0 ];
CCN.contr.contrs.inc     = [ 0 0 1 0 0 0 ];
CCN.contr.contrs.simp    = [ 0 0 0 0 1 0 ];

% CCN.contr.contrs.ivc     = [ -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.cvi     = [ 1 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.mvs     = [ 1 0 0 0 0 1 0 0 0 0 -2 0 0 0 0 ];
% CCN.contr.contrs.svm     = [ -1 0 0 0 0 -1 0 0 0 0 2 0 0 0 0 ];
% CCN.contr.contrs.cvs     = [ 1 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 ];
% CCN.contr.contrs.svc     = [ -1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 ];
% CCN.contr.contrs.ivs     = [ 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 ];
% CCN.contr.contrs.svi     = [ 0 0 0 0 0 -1 0 0 0 0 1 0 0 0 0 ];
% 
% CCN.contr.contrs.allRT   = [ 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 ] ./ 3;
% CCN.contr.contrs.msitRT  = [ 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 ] ./ 2;
% CCN.contr.contrs.conRT   = [ 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.incRT   = [ 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.simpRT  = [ 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 ];
% 
% CCN.contr.contrs.allRT2  = [ 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 ] ./ 3;
% CCN.contr.contrs.msitRT2 = [ 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 ] ./ 2;
% CCN.contr.contrs.conRT2  = [ 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.incRT2  = [ 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.simpRT2 = [ 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 ];

% CCN.contr.contrs.allRT3  = [ 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 ] ./ 3;
% CCN.contr.contrs.msitRT3 = [ 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 ] ./ 2;
% CCN.contr.contrs.conRT3  = [ 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.incRT3  = [ 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 ];
% CCN.contr.contrs.simpRT3 = [ 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 ];

% CCN.contr.contrs.allRT4  = [ 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 ] ./ 3;
% CCN.contr.contrs.msitRT4 = [ 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 ] ./ 2;
% CCN.contr.contrs.conRT4  = [ 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.incRT4  = [ 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 ];
% CCN.contr.contrs.simpRT4 = [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ];

% CCN.contr.contrs.ivcRT   = [ 0 -1 0 0 0 0 1 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.cviRT   = [ 0 1 0 0 0 0 -1 0 0 0 0 0 0 0 0 ];
% CCN.contr.contrs.mvsRT   = [ 0 1 0 0 0 0 1 0 0 0 0 -2 0 0 0 ];
% CCN.contr.contrs.svmRT   = [ 0 -1 0 0 0 0 -1 0 0 0 0 2 0 0 0 ];
% CCN.contr.contrs.cvsRT   = [ 0 1 0 0 0 0 0 0 0 0 0 -1 0 0 0 ];
% CCN.contr.contrs.svcRT   = [ 0 -1 0 0 0 0 0 0 0 0 0 1 0 0 0 ];
% CCN.contr.contrs.ivsRT   = [ 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 ];
% CCN.contr.contrs.sviRT   = [ 0 0 0 0 0 0 -1 0 0 0 0 1 0 0 0 ];

% 
% CCN.roix.method = 'est';
CCN.roix.method = 'avg';
CCN.roix.radius = 6;
CCN.roix.shape = 'sphere';

% Define ROIs
CCN.roix.coord = struct();

% Nee meta-analysis
% CCN.roix.coord.msitmax      = [-6 1 44];
CCN.roix.coord.mfcmeta      = [2 16 46];
CCN.roix.coord.ldlpfcmeta   = [-40 26 30];
CCN.roix.coord.rdlpfcmeta   = [42 24 28];
CCN.roix.coord.lifgmeta     = [-36 16 4];
CCN.roix.coord.rifgmeta     = [44 14 8];
CCN.roix.coord.liplmeta     = [-36 -56 44];
CCN.roix.coord.riplmeta     = [40 -52 42];
CCN.roix.coord.bias         = [-5.81 11.75 49.00];

CCN.rfx.des = '1stt';
CCN.rfx.dir = '[root_dir]/rfx/model_paper';
% CCN.rfx.dir = '[root_dir]/rfx/model_poly';
% CCN.rfx.des = 'condXtime';
% CCN.rfx.dir = '[root_dir]/rfx/model_fir_aov_act8';
% CCN.rfx.conds = { 'con' 'inc' 'simp' };
% CCN.rfx.dir = '[root_dir]/rfx/model_fir_aov_rt';
% CCN.rfx.conds = { 'conRT' 'incRT' 'simpRT' };
CCN.rfx.mtype = 'model';

CCN.rfx.mctype = 'fdr';
CCN.rfx.ethresh = 20;
CCN.rfx.hthresh = 0.05;
% CCN.rfx.mctype = 'fdr';
% CCN.rfx.ethresh = 35;
% CCN.rfx.hthresh = 0.005;

% CCN.rfx.des = 'rmaov1';
% CCN.rfx.dir = '[root_dir]/rfx/model_ffact';
% CCN.rfx.rmcontrs = { 'fin' 'tst' 'shs' 'lrn' 'fnt' };