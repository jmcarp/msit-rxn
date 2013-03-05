function eqact = rtequate_vox

global CCN;
behav;

eqpairs{1} = struct( ...
    'slope', 'con', 'from', 'con', 'to', 'inc' ...
    );
eqpairs{2} = struct( ...
    'slope', 'simp', 'from', 'con', 'to', 'inc' ...
    );

for subjidx = 1 : length(CCN.subjs)
    
    subj = CCN.subjs{subjidx};
    ssubj = sprintf('s%s', subj);
    
    disp(sprintf('Working on subject %s...', subj));
    
    CCN.subject = subj;
    spmdir = expandpath(CCN.model.model_dir, false, 1);
    spmmat = sprintf('%s/SPM.mat', spmdir);
    load(spmmat);
    
    xCon = SPM.xCon;
    xnames = {xCon.name};
        
    for pairidx = 1 : length(eqpairs)
        
        eqpair = eqpairs{pairidx};
        
        tocond = eqpair.to;
        fromcond = eqpair.from;
        
        slopecond = eqpair.slope;
        slopertcond = sprintf('%sRT', slopecond);
        
        fromeqcond = sprintf('%s_%seq', fromcond, slopecond);
        fromdifcond = sprintf('%s_%sdif', fromcond, slopecond);
        
        rtdiff = rt.(tocond).(ssubj) - ...
            rt.(fromcond).(ssubj);
        
        toidx = ismember(xnames, tocond);
        toname = sprintf('%s/%s', spmdir, ...
            xCon(toidx).Vcon.fname);
        tovol = spm_vol(toname);
        toimg = spm_read_vols(tovol);
        
        fromidx = ismember(xnames, fromcond);
        fromname = sprintf('%s/%s', spmdir, ...
            xCon(fromidx).Vcon.fname);
        fromvol = spm_vol(fromname);
        fromimg = spm_read_vols(fromvol);
        
        slopeidx = ismember(xnames, slopertcond);
        slopename = sprintf('%s/%s', spmdir, ...
            xCon(slopeidx).Vcon.fname);
        slopevol = spm_vol(slopename);
        slopeimg = spm_read_vols(slopevol);
        
        % 
        fromeqvol = fromvol;
        fromeqvol.fname = sprintf('%s/con_%s.img', ...
            spmdir, fromeqcond);
        fromeqimg = fromimg + slopeimg .* rtdiff;
        spm_write_vol(fromeqvol, fromeqimg);
        rfxfiles{pairidx}.fromeq{subjidx} = ...
            fromeqvol.fname;
        
        % 
        fromdifvol = fromvol;
        fromdifvol.fname = sprintf('%s/con_%s.img', ...
            spmdir, fromdifcond);
        fromdifimg = toimg - fromeqimg;
        spm_write_vol(fromdifvol, fromdifimg);
        rfxfiles{pairidx}.fromdif{subjidx} = ...
            fromdifvol.fname;
        
    end
    
end

for pairidx = 1 : length(eqpairs)
    
    eqpair = eqpairs{pairidx};
    
    fromcond = eqpair.from;
    slopecond = eqpair.slope;
    
    fromeqcond = sprintf('%s_%seq', fromcond, slopecond);
    fromdifcond = sprintf('%s_%sdif', fromcond, slopecond);
    
    clear matlabbatch;
    
    % Get model directory
    rfxdir = sprintf('%s/%s', ...
        expandpath(CCN.rfx.dir, false, 1), fromeqcond);
    if ~exist(rfxdir, 'dir')
        mkdir(rfxdir);
    end
    matlabbatch{1}.spm.stats.factorial_design.dir = ...
        {rfxdir};
    
    % Get scans
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = ...
        rfxfiles{pairidx}.fromeq;
    
    % Set up estimation
    spmmat = sprintf('%s/SPM.mat', rfxdir);
    matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
        {spmmat};

    % Set up contrasts
    matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
    matlabbatch{3}.spm.stats.con.delete = 1;

    % +ve
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ...
        sprintf('+ %s', fromeqcond);
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = ...
        [1];

    % -ve
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ...
        sprintf('- %s', fromeqcond);
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = ...
        [-1];

    % Run job
    spm_jobman('run', matlabbatch);
    
    catname = spmcat(spmmat, 1, 2);
    tempname = CCN.norm.hrtemp;
    spm_reslice({tempname catname}, ...
        struct('mean', 0, 'which', 1));
    
    %
    
    clear matlabbatch;
    
    % Get model directory
    rfxdir = sprintf('%s/%s', ...
        expandpath(CCN.rfx.dir, false, 1), fromdifcond);
    if ~exist(rfxdir, 'dir')
        mkdir(rfxdir);
    end
    matlabbatch{1}.spm.stats.factorial_design.dir = ...
        {rfxdir};
    
    % Get scans
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = ...
        rfxfiles{pairidx}.fromdif;
    
    % Set up estimation
    spmmat = sprintf('%s/SPM.mat', rfxdir);
    matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
        {spmmat};

    % Set up contrasts
    matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
    matlabbatch{3}.spm.stats.con.delete = 1;

    % +ve
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ...
        sprintf('+ %s', fromdifcond);
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = ...
        [1];

    % -ve
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ...
        sprintf('- %s', fromdifcond);
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = ...
        [-1];

    % Run job
    spm_jobman('run', matlabbatch);
    
    catname = spmcat(spmmat, 1, 2);
    tempname = CCN.norm.hrtemp;
    spm_reslice({tempname catname}, ...
        struct('mean', 0, 'which', 1));
    
end