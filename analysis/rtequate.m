function eqact = rtequate(act)

global CCN;
behav;

eqpairs{1} = struct( ...
    'slope', 'con', 'from', 'con', 'to', 'inc' ...
    );
eqpairs{2} = struct( ...
    'slope', 'simp', 'from', 'con', 'to', 'inc' ...
    );
eqpairs{3} = struct( ...
    'slope', 'simp', 'from', 'simp', 'to', 'inc' ...
    );

roinames = fieldnames(act);
eqact = act;

for subjidx = 1 : length(CCN.subjs)
    
    subj = CCN.subjs{subjidx};
    ssubj = sprintf('s%s', subj);
    
    for pairidx = 1 : length(eqpairs)
        
        eqpair = eqpairs{pairidx};
        
        tocond = eqpair.to;
        
        slopecond = eqpair.slope;
        slopecondrt = sprintf('%sRT', slopecond);
        
        fromcond = eqpair.from;
        fromcondeq = sprintf('%s_%seq', fromcond, slopecond);
        
        rtdiff = rt.(tocond).(ssubj) - ...
            rt.(fromcond).(ssubj);
        
        for roiidx = 1 : length(roinames)
            
            roiname = roinames{roiidx};
            
            actvec = act.(roiname).(fromcond)(subjidx);
            slopevec = act.(roiname).(slopecondrt)(subjidx);
            eqvec = actvec + slopevec .* rtdiff;
            eqact.(roiname).(fromcondeq)(subjidx) = eqvec;
            
        end
        
    end
    
end