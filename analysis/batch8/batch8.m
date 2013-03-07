function batch8(varargin)

global CCN;

if nargin > 0
    tmp = varargin{1};
    if isstruct(tmp)
        CCN = tmp;
    elseif exist(tmp, 'file')
        mat = load(tmp);
        CCN = mat.CCN;
    end
end

if nargin > 1
    
    % Get starting directory
    startdir = pwd;
    
    % Change to script directory
    cd(CCN.scriptdir);
    
    ncores = varargin{2};
    nsubjs = length(CCN.subjs);
    
    CCN0 = CCN;
    
    % 
    if ~isfield(CCN, 'graphics') || CCN.graphics
        dispstr = '';
    else
        dispstr = '-nodisplay';
    end
    
    for coreidx = 1 : ncores
        
        CCN = CCN0;
        CCN.subjs = CCN.subjs(coreidx : ncores : nsubjs);
        matfile = sprintf('%s/ccnmat%02d.mat', CCN.logdir, coreidx);
        logfile = sprintf('%s/ccnlog%02d.txt', CCN.logdir, coreidx);
        save(matfile, 'CCN');
        cmd = sprintf('matlab %s -r "batch8(''%s''); exit;" > %s &', ...
            dispstr, matfile, logfile);
        fprintf('Working on subjects %s...\n', ...
            joindelim(CCN.subjs, ', '));
        disp(cmd);
        system(cmd);
        
    end
    
    % Return to starting directory
    cd(startdir);
    
    return
    
end

% Launch SPM if not open
if isempty(findobj('-regexp', 'name', 'SPM8.*?Graphics'))
    spm fmri;
end

% Auto-fill CCN.ntry
if ~isfield(CCN, 'ntry')
    CCN.ntry = 1;
end

CCN.groupsteps = { 'roixtract_b' 'rfx_b' };

for stepidx = 1 : length(CCN.steps)
    
    % Update step
    CCN.step = CCN.steps{stepidx};
    
    % Update file pattern
    if isfield(CCN.file_pattern, CCN.step)
        CCN.curr_pattern = CCN.file_pattern.(CCN.step);
    else
        CCN.curr_pattern = CCN.file_pattern.default;
    end
    
    if ismember(CCN.step, CCN.groupsteps)
        
        % Run step
        feval(CCN.step);
        
    else
        
        for subjidx = 1 : length(CCN.subjs)

            % Update subject
            CCN.subject = CCN.subjs{subjidx};
            CCN.csubject = regexprep(CCN.subject, '[\/]', '');

            % Run step
            feval(CCN.step);
%             for tryidx = 1 : CCN.ntry
%                 try
%                     feval(CCN.step);
%                     fprintf(logh, 'Completed step %s on subject %s\n', ...
%                         CCN.step, CCN.subject);
%                     break
%                 catch error
%                     fprintf(logh, 'Error on step %s of subject %s: %s\n', ...
%                         CCN.step, CCN.subject, error);
%                 end
%             end

        end
        
    end
    
end