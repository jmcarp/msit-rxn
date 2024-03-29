function rfx_b

global CCN;

switch CCN.rfx.des
    
    % One-sample t-test
    case '1stt'
        
        if strcmp(CCN.rfx.mtype, 'model')
            contrnames = fieldnames(CCN.contr.contrs);
        elseif strcmp(CCN.rfx.mtype, 'ppi')
            contrnames = fieldnames(CCN.ppicontr.contrs);
        end
        
        
        CCN.subject = CCN.subjs{1};
        spmdir = expandpath(CCN.model.model_dir, false, 1);
        spmmat = sprintf('%s/SPM.mat', spmdir);
        load(spmmat);
        contrnames = { SPM.xCon.name };
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            end
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
           
            % Set masking
            if isfield(CCN.rfx, 'mask')
                matlabbatch{1}.spm.stats.factorial_design.masking.em = ...
                    {CCN.rfx.mask};
            end
 
            % Get scans
            for subjidx = 1 : length(CCN.subjs)
                CCN.subject = CCN.subjs{subjidx};
                spmdir = expandpath(CCN.model.model_dir, false, 1);
                if strcmp(CCN.rfx.mtype, 'model')
                    mdir = spmdir;
                elseif strcmp(CCN.rfx.mtype, 'ppi')
                    mdir = sprintf('%s/%s', spmdir, CCN.ppi.name);
                end
%                 matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{subjidx} = ...
%                     sprintf('%s/con_%04d.img', mdir, contridx + 1);
                matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{subjidx} = ...
                    sprintf('%s/%s', mdir, SPM.xCon(contridx).Vcon.fname);
            end
            
            % Set up estimation
            spmmat = sprintf('%s/SPM.mat', rfxdir);
            matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
                {spmmat};
            
            % Set up contrasts
            matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
            matlabbatch{3}.spm.stats.con.delete = 1;
            
            % +ve
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ...
                sprintf('+ %s', contrname);
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = ...
                [1];
            
            % -ve
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ...
                sprintf('- %s', contrname);
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = ...
                [-1];
            
            % Run job
            spm_jobman('run', matlabbatch);
            
            catname = spmcat(spmmat, 1, 2);
            tempname = CCN.norm.hrtemp;
            spm_reslice({tempname catname}, ...
                struct('mean', 0, 'which', 1));
        
        end
        
    case '2stt'
        
        contrnames = fieldnames(CCN.contr.contrs);
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            end
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
            
            % Set masking
            if isfield(CCN.rfx, 'mask')
                matlabbatch{1}.spm.stats.factorial_design.masking.em = ...
                    {CCN.rfx.mask};
            end
 
            % Get scans
            group1 = CCN.rfx.groupnames{1};
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = ...
                cell(length(CCN.rfx.groups.(group1)), 1);
            for subjidx = 1 : length(CCN.rfx.groups.(group1))
                CCN.subject = CCN.rfx.groups.(group1){subjidx};
                matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1{subjidx} = ...
                    sprintf('%s/con_%04d.img', ...
                    expandpath(CCN.model.model_dir, false, 1), contridx + 1);
            end
            
            group2 = CCN.rfx.groupnames{2};
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = ...
                cell(length(CCN.rfx.groups.(group2)), 1);
            for subjidx = 1 : length(CCN.rfx.groups.(group2))
                CCN.subject = CCN.rfx.groups.(group2){subjidx};
                matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2{subjidx} = ...
                    sprintf('%s/con_%04d.img', ...
                    expandpath(CCN.model.model_dir, false, 1), contridx + 1);
            end
            
            % Set up estimation
            spmmat = sprintf('%s/SPM.mat', rfxdir);
            matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
                {spmmat};
            
            % Set up contrasts
            matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
            matlabbatch{3}.spm.stats.con.delete = 1;
            
            % + all
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ...
                sprintf('+ %s %s', group1, group2);
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = ...
                [1 1];
            
            % - all
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ...
                sprintf('- %s %s', group1, group2);
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = ...
                [-1 -1];
            
            % + group1
            matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = ...
                sprintf('+ %s', group1);
            matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = ...
                [1 0];
            
            % - group1
            matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = ...
                sprintf('- %s', group1);
            matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = ...
                [-1 0];
            
            % + group2
            matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = ...
                sprintf('+ %s', group2);
            matlabbatch{3}.spm.stats.con.consess{5}.tcon.convec = ...
                [0 1];
            
            % - group2
            matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = ...
                sprintf('- %s', group2);
            matlabbatch{3}.spm.stats.con.consess{6}.tcon.convec = ...
                [0 -1];
            
            % group1 - group2
            matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = ...
                sprintf('%s - %s', group1, group2);
            matlabbatch{3}.spm.stats.con.consess{7}.tcon.convec = ...
                [1 -1];
            
            % group2 - group1
            matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = ...
                sprintf('%s - %s', group2, group1);
            matlabbatch{3}.spm.stats.con.consess{8}.tcon.convec = ...
                [-1 1];
            
            % Run job
            spm_jobman('run', matlabbatch);
            
        end
        
    case 'aov1'
        
        contrnames = fieldnames(CCN.contr.contrs);
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            end
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
            
            for cellidx = 1 : length(CCN.rfx.groupnames)
                
                % Get scans
                groupname = CCN.rfx.groupnames{cellidx};
                for subjidx = 1 : length(CCN.rfx.groups.(groupname))
                    CCN.subject = CCN.rfx.groups.(groupname){subjidx};
                    matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(cellidx).scans{subjidx} = ...
                        sprintf('%s/con_%04d.img', ...
                        expandpath(CCN.model.model_dir, false, 1), contridx);
                end
                
            end
            
            spm_jobman('run', matlabbatch);
            
        end
        
    case 'mreg'
        
        if strcmp(CCN.rfx.mtype, 'model')
            contrnames = fieldnames(CCN.contr.contrs);
        elseif strcmp(CCN.rfx.mtype, 'ppi')
            contrnames = fieldnames(CCN.ppicontr.contrs);
        end
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            end
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
            
            % Get scans
            for subjidx = 1 : length(CCN.subjs)
                CCN.subject = CCN.subjs{subjidx};
                spmdir = expandpath(CCN.model.model_dir, false, 1);
                if strcmp(CCN.rfx.mtype, 'model')
                    mdir = spmdir;
                elseif strcmp(CCN.rfx.mtype, 'ppi')
                    mdir = sprintf('%s/%s', spmdir, CCN.ppi.name);
                end
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans{subjidx} = ...
                    sprintf('%s/con_%04d.img', mdir, contridx + 1);
            end
            
            % Get regressors
            regnames = fieldnames(CCN.rfx.mreg);
            for regidx = 1 : length(regnames)
                regname = regnames{regidx};
                regval = CCN.rfx.mreg.(regname);
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(regidx).cname = ...
                    regname;
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(regidx).c = ...
                    regval;
            end
            
            % Set up estimation
            spmmat = sprintf('%s/SPM.mat', rfxdir);
            matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
                {spmmat};
            
            % Set up contrasts
            matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
            matlabbatch{3}.spm.stats.con.delete = 1;
            
            conct = 1;
            regnamesx = [regnames' 'intercept'];
            basecon = zeros(length(regnamesx), 1);
            for regidx = 1 : length(regnamesx)
                
                regname = regnamesx{regidx};
                
                % +ve
                convec = basecon;
                convec(regidx) = 1;
                matlabbatch{3}.spm.stats.con.consess{conct}.tcon.name = ...
                    sprintf('+ %s', regname);
                matlabbatch{3}.spm.stats.con.consess{conct}.tcon.convec = ...
                    convec;
                conct = conct + 1;
                
                % -ve
                convec = basecon;
                convec(regidx) = -1;
                matlabbatch{3}.spm.stats.con.consess{conct}.tcon.name = ...
                    sprintf('- %s', regname);
                matlabbatch{3}.spm.stats.con.consess{conct}.tcon.convec = ...
                    convec;
                conct = conct + 1;
                
            end
            
            spm_jobman('run', matlabbatch);
            
        end
        
    case 'rmaov1'
        
        clear matlabbatch;
        
        % Get model directory
        rfxdir = sprintf('%s', expandpath(CCN.rfx.dir, false, 1));
        if ~exist(rfxdir, 'dir')
            mkdir(rfxdir);
        end
        matlabbatch{1}.spm.stats.factorial_design.dir = ...
            {rfxdir};
        
        contrnames = fieldnames(CCN.contr.contrs);
        
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'factor1';
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = ...
            length(CCN.rfx.rmcontrs);
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
        
        for rmcontridx = 1 : length(CCN.rfx.rmcontrs)
            
            matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(rmcontridx).levels = ...
                rmcontridx;
            rmcontr = CCN.rfx.rmcontrs{rmcontridx};
            conidx = find(ismember(contrnames, rmcontr));
            
            for subjidx = 1 : length(CCN.subjs)
                
                subj = CCN.subjs{subjidx};
                CCN.subject = subj;
                
                spmdir = expandpath(CCN.model.model_dir, false, 1);
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(rmcontridx).scans{subjidx} = ...
                    sprintf('%s/con_%04d.img', spmdir, conidx);
                
            end
            
        end
        
        % Set up estimation
        spmmat = sprintf('%s/SPM.mat', rfxdir);
        matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
            {spmmat};
        
        spm_jobman('run', matlabbatch);
        
    case 'condXtime'
        
        clear matlabbatch;
        
        % Get model directory
        rfxdir = sprintf('%s', expandpath(CCN.rfx.dir, false, 1));
        if ~exist(rfxdir, 'dir')
            mkdir(rfxdir);
        end
        matlabbatch{1}.spm.stats.factorial_design.dir = ...
            {rfxdir};
        
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'cond';
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = ...
            length(CCN.rfx.conds);
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
        
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'time';
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = ...
            CCN.model.length / CCN.TR;
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
        
        subj = CCN.subjs{1};
        CCN.subject = subj;

        spmdir = expandpath(CCN.model.model_dir, false, 1);
        spmmat = sprintf('%s/SPM.mat', spmdir);
        load(spmmat);
        connames = {SPM.xCon.name};
        
        cellidx = 1;
        for condidx = 1 : length(CCN.rfx.conds)
            
            for ptidx = 1 : CCN.model.length / CCN.TR
            
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(cellidx).levels = ...
                    [condidx ; ptidx];
                conname = sprintf('%s_pt%d', CCN.rfx.conds{condidx}, ptidx);

                for subjidx = 1 : length(CCN.subjs)

                    subj = CCN.subjs{subjidx};
                    CCN.subject = subj;

                    spmdir = expandpath(CCN.model.model_dir, false, 1);
                    conidx = find(ismember(connames, conname));
                    
                    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(cellidx).scans{subjidx} = ...
                        sprintf('%s/con_%04d.img', spmdir, conidx);

                end
                
                cellidx = cellidx + 1;

            end
            
        end
        
        % Set up estimation
        spmmat = sprintf('%s/SPM.mat', rfxdir);
        matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
            {spmmat};
        
        spm_jobman('run', matlabbatch);
        
    otherwise
        
        error('rfx design %s not implemented', CCN.rfx.des);
        
end
