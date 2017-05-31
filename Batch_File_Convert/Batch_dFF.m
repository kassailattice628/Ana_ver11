%Calc dFF, Batch

% Read a motion-corrected tif file
% Make F0 image
% Calc (F-F0)/F0
% Save multi-tif image

%use "read_file" for reading tif"
addpath('/Users/lattice/Dropbox/NoRMCorre/');

%%%%%%%%%% file info %%%%%%%%%%
[fname, dirname] = uigetfile({'*.tif;*.tiff;*.mat', 'img or mat files'});
[~, ~, ext] = fileparts(fname);

% modify info
n_img = 1:18; % a vector of file number to be processed

f0_frames = [13, 13, 51, 51, 16, 16, 51, 76, 58, 51, 16, 51, 51, 48, 104, 51, 62, 51];
fsuf = 'SC';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nn = 0;
%% Batch for multiple files %%
for n = n_img
    nn = nn + 1; %counter
    
    fn = num2str(n);
    name = [dirname, fsuf, fn, '.tif'];
    disp(['Reading File:: ', name])
    % check file
    if ~exist(name, 'file')
        errordlg([name, 'is NOT FOUND!!'])
        continue
    end
    % check file type
    switch ext
        case {'.tif', '.tiff'}
            F = read_file(name);
            F = double(F);
            
        case {'.mat'}
            load(name);
    end
    
    F0 = mean(F(:,:, 1:f0_frames(nn)), 3);
    dFF = F;
    for n3 = 1:size(F,3)
        dFF(:,:,n3) = (F(:,:, n3) - F0)./F0;
    end
    
    % Save as tif %
    if ~exist([dirname, 'dFF'], 'dir')
        mkdir([dirname,'dFF'])
    end
    
    out_name = [dirname,'dFF/', fsuf, fn, '.tif'];
    disp(['Saving Tiff File as ', out_name]);
    options.append = true;
    saveastiff(single(dFF), out_name, options);
    disp('Save Finished!!');
end
