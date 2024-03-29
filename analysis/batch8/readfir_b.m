function readfir_b

global CCN;

global act;
act = struct();

conds = CCN.contr.condnames;
nconds = length(conds);

roinames = fieldnames(CCN.roix.coord);
maroi = struct();
for roiidx = 1 : length(roinames)
    roiname = roinames{roiidx};
    if strcmp(CCN.roix.shape, 'sphere')
        maroi.(roiname) = maroi_sphere(struct( ...
            'centre', CCN.roix.coord.(roiname), ...
            'radius', CCN.roix.radius));
    elseif strcmp(CCN.roi.shape, 'box')
        maroi.(roiname) = maroi_box(struct( ...
            'centre', CCN.roix.coord.(roiname), ...
            'widths', CCN.roix.radius));
    end
end

for subjidx = 1 : length(CCN.subjs)
    
    subj = CCN.subjs{subjidx};
    fprintf('Working on subject %s...', subj);
    CCN.subject = subj;
    
    spmname = sprintf('%s/SPM.mat', ...
        expandpath(CCN.model.model_dir, false, 1));
    load(spmname);
    
    names = {};
    for i = SPM.xX.name
        n = char(i);
        dg = regexp(n, '\((\d+)\)', 'tokens');
        rn = dg{1};
        try
            pt = dg{2};
        catch
            pt = '-1';
        end
        n = regexprep(n, 'Sn\(\d\) ', '');
        n = regexprep(n, '\*.*', '');
        names = [names ; [n rn pt]];
    end
    
    npoints = SPM.xBF.order;
    
    for condidx = 1 : nconds
        
        cond = conds{condidx};
        cleancond = regexprep(cond, '[\-\^]', '');
        
        for point = 1 : npoints
            
            volnames = {};

            regs = intersect( ...
                find(ismember(names(:, 1), cond)), ...
                find(ismember(names(:, 3), num2str(point))));
            for regidx = 1 : length(regs)
                volnames{regidx} = sprintf('%s/beta_%04d.img', ...
                    expandpath(CCN.model.model_dir, false, 1), ...
                    regs(regidx));
            end
            vols = spm_vol(char(volnames));
            
            for roiidx = 1 : length(roinames)
                roiname = roinames{roiidx};
                act.(roiname).(cleancond)(subjidx, point) = ...
                    mean(summary_data(get_marsy(maroi.(roiname), ...
                    repmat(vols, 1, 2), 'mean')));
            end

        end

    end
    
end