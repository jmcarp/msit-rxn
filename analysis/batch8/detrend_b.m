function detrend_b

global CCN;

% Get data
data = expandpath(CCN.ffiles);

CCN.curr_pattern = CCN.file_pattern.realign_b;
rpdata = expandpath(CCN.ffiles);

for rpidx = 1 : length(rpdata)
    
    rpfile = rpdata{rpidx};
    rpfile = fileprep(rpfile, 'rp_');
    rpfile = chext(rpfile, '.txt');
    rpdata{rpidx} = rpfile;
    
end

for runidx = 1 : length(data)
    
    % Get run file
    runfile = data{runidx};
    rpfile = rpdata{runidx};
    
    cmd = sprintf('3dDetrend -vector %s %s', ...
        rpfile, runfile);
    
    % Run AFNI command
    fprintf('Running command %s...\n', cmd);
    system(cmd);
    
    % 
    drunfile = fileprep(runfile, 'd');
    delimg(drunfile);
    
    % 
    cmd = '3dAFNItoNIFTI detrend+orig.HEAD';
    
    % 
    fprintf('Running command %s...\n', cmd);
    system(cmd);
    
    % Rename NII file
    movefile('detrend.nii', drunfile);
    
    % Delete AFNI files
    delete('detrend+orig.HEAD');
    delete('detrend+orig.BRIK');
    
end