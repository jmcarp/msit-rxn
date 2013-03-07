function checkmot_b

global CCN;

nsubjs = length(CCN.subjs);
CCN.subject = CCN.subjs{1};
rpfiles = expandpath(CCN.rppat);
nruns = length(rpfiles);

maxpos = nan(nsubjs, nruns, 7);
maxdif = nan(nsubjs, nruns, 7);

for subjidx = 1 : nsubjs
    
    subj = CCN.subjs{subjidx};
    ssubj = sprintf('s%s', subj);
    CCN.subject = subj;
    
    [mptmp mdtmp] = checksubj;
    mptmp(:, 7); mdtmp(:, 7);
    
    incruns = ...
        mptmp(:, 7) <= CCN.motthresh.maxpos & ...
        mdtmp(:, 7) <= CCN.motthresh.maxdif;
    CCN.motthresh.incruns.(ssubj) = incruns;
    
    maxpos(subjidx, :, :) = mptmp;
    maxdif(subjidx, :, :) = mdtmp;
    
end

function [maxpos maxdif] = checksubj

global CCN;

rpfiles = expandpath(CCN.rppat);
nruns = length(rpfiles);

maxpos = nan(nruns, 7);
maxdif = nan(nruns, 7);

for runidx = 1 : nruns
    
    % Load realignment parameters
    rpdata = load(rpfiles{runidx});
    
    % Compute translation
    rpdata(:, 7) = sqrt(sum(rpdata(:, 1 : 3) .^ 2, 2));
    
    % Compute first derivative
    drpdata = diff(rpdata);
    
    % Compute motion stats
    maxpos(runidx, :) = abs( ...
        max(rpdata) - min(rpdata) ...
        );
    maxdif(runidx, :) = max(abs(drpdata));
    
end