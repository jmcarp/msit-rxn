function bandpass_b

global CCN;

% Get data
data = expandpath(CCN.ffiles);

if CCN.bandpass.ort
    
    CCN.curr_pattern = CCN.file_pattern.realign_b;
    rpdata = expandpath(CCN.ffiles);
    
    for rpidx = 1 : length(rpdata)
        
        rpfile = rpdata{rpidx};
        rpfile = fileprep(rpfile, 'rp_');
        rpfile = chext(rpfile, '.txt');
        rpdata{rpidx} = rpfile;
        
    end
    
end

for runidx = 1 : length(data)
    
    % Get run file
    runfile = data{runidx};
    
    % Build AFNI command
    if CCN.bandpass.ort
        rpfile = rpdata{runidx};
        ortcmd = sprintf('-ort %s', rpfile);
    else
        ortcmd = '';
    end
    
    cmd = sprintf('3dBandpass -dt %f %s %f %f %s', ...
        CCN.TR, ortcmd, CCN.bandpass.fbot, CCN.bandpass.ftop, ...
        runfile);
    
    % Run AFNI command
    fprintf('Running command %s...\n', cmd);
    system(cmd);
    
    % 
    brunfile = fileprep(runfile, 'b');
    delimg(brunfile);
    
    % 
    cmd = '3dAFNItoNIFTI bandpass+orig.HEAD';
    
    % 
    fprintf('Running command %s...\n', cmd);
    system(cmd);
    
    % Rename NII file
    movefile('bandpass.nii', brunfile);
    
    % Delete AFNI files
    delete('bandpass+orig.HEAD');
    delete('bandpass+orig.BRIK');
    
end