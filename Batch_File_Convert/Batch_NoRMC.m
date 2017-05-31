%Non-rigid Motion Correction, Batch

% Original@Github 
% https://github.com/simonsfoundation/NoRMCorre
% 
% Original Paper @bioRxiv
% http://biorxiv.org/content/early/2017/02/14/108514
% "NoRMCorre: An online algorithm for piecewise rigid motion correction of
% calcium imaging data"
% Eftychois A Pnevmatikakis, Andrea Giovannucci
clear;
gcp;

addpath('/Users/lattice/Dropbox/NoRMCorre/');

%%%%%%% define file name %%%%%%%%%%%% Modify This Part %%%%%%%%%%%%%%%%%%%%
f_nums = 8:13; %vector of file nuber
dirname = '/Volumes/pSSD_T1/170517/GAD36/tif_original/'; 
suffix = 'SC';
ext = '.tif';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Batch for multiple files %%
for n = f_nums
    
    fn = num2str(n);
    name = [dirname, suffix, fn, ext];
    
    disp(['Reading Tif File:: ', name]);
    if ~exist(name, 'file')
        errordlg([name , 'is NOT FOUND !! Skip this file...'])
        continue
    end
    
    % Read Tif File
    Y = read_file(name); 
    Y = double(Y);
    T = size(Y, ndims(Y));
    
    %%%%%% Try non-rigid motion correction (in paralle) %%%%%%
    % Set params
    options_nonrigid = NoRMCorreSetParms...
        ('d1',size(Y,1),'d2',size(Y,2),...
        'grid_size',[38,38],...  % size of non-overlapping regions (default: [d1,d2,d3])
        'overlap_pre', 5,... % size of overlapping region (default: [32,32,16])
        'us_fac',20,... % upsampling factor for subpixel registration (default: 20)
        'mot_uf',4,... % degree of patches upsampling (default: [4,4,1])
        'max_dev',3,... % maximum deviation of patch shift from rigid shift (default: [3,3,1])
        'max_shift',40,... % maximum rigid shift in each direction (default: [15,15,5])
        'bin_width',40,... % width of each bin (default: 10) 
        'iter', 1);... % number of data passes (default: 1)
        %'output_type', 'tiff',...
        %'tiff_filename', [dirname, suffix, fn, '_NoRMC', ext]);
    
    % Get non-rigid motion correction
    tic;
    disp('Calculating motion correction...')
    [M2, shifts, template2] = normcorre_batch(Y, options_nonrigid);
    toc;
    
    %
    %%%%%% Save the result as a multi-Tif %%%%%%
    out_name = [dirname, suffix, fn, '_NoRMC', ext];
    options.append = true;
    saveastiff(uint16(M2), out_name, options);
    disp([suffix, fn, 'NoRMC.tif', ' is saved!']);
    %}
end