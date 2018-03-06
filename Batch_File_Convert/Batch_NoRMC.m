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

% use "read_file" for reading tif"
addpath(genpath('/Users/lattice/Dropbox/TwoPhoton_Analysis/NoRMCorre/'));

% file info
if exist('dirname', 'var')
    [dirname, fname, ext, fsuf, psuf] = Get_File_Name(dirname);
else
    [dirname, fname, ext, fsuf, psuf] = Get_File_Name([]);
end

files = subdir(fullfile(dirname,['SC*', ext]));
%%%%%%% define f ile name %%%%%%%%%%%% Modify This Part %%%%%%%%%%%%%%%%%%%%
%f_nums = 1:15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Batch for multiple files %%
%for n = f_nums
for n = 1:size(files,1)
    if files(n).bytes > 0
    
        i1 = regexp(files(n).name, '\d*');
        i2 = regexp(files(n).name, '\.');
        fn = files(n).name(i1(end):i2(1)-1);
    %fn = num2str(n);
    name = files(n).name;
    %name = [dirname, fsuf, fn, psuf, ext];
    
    disp(['Reading Tif File:: ', name]);
    if ~exist(name, 'file')
        errordlg([name , 'is NOT FOUND !! Skip this file...'])
        continue
    end
    
    %%%%% File loading %%%%%
    switch ext
        case {'.tif', 'tiff'}
            % Read Tif File
            F = read_file(name);
            F = double(F);
            T = size(F, ndims(F));
        case {'.mat'}
            load(name);
            if exist('stack_F', 'var')
                 F = stack_F;
                 clear stack_F
            end
    end
    
    %%%%%% Try non-rigid motion correction (in paralle) %%%%%%
    % Set params
    %
    options_nonrigid = NoRMCorreSetParms...
        ('d1',size(F,1),'d2',size(F,2),...
        'grid_size', [60, 60],...  % size of non-overlapping regions (default: [d1,d2,d3])
        'overlap_pre', 20,... % size of overlapping region (default: [32,32,16])
        'us_fac', 20,... % upsampling factor for subpixel registration (default: 20)
        'mot_uf' , 4,... % degree of patches upsampling (default: [4,4,1])
        'max_dev', 3,... % maximum deviation of patch shift from rigid shift (default: [3,3,1])
        'max_shift', 30,... % maximum rigid shift in each direction (default: [15,15,5])
        'bin_width', 100,... % width of each bin (default: 10)  use 40
        'iter', 1);... % number of data passes (default: 1)
    
    
    disp('1st Calculating motion correction...')
    [M2, shifts, template] = normcorre_batch(F, options_nonrigid);
    %}
    %{
    % Set params
    options_nonrigid = NoRMCorreSetParms...
        ('d1',size(F,1),'d2',size(F,2),...
        'grid_size', [27, 27],...  % size of non-overlapping regions (default: [d1,d2,d3])
        'overlap_pre', 5,... % size of overlapping region (default: [32,32,16])
        'us_fac', 20,... % upsampling factor for subpixel registration (default: 20)
        'mot_uf' , 4,... % degree of patches upsampling (default: [4,4,1])
        'max_dev', 3,... % maximum deviation of patch shift from rigid shift (default: [3,3,1])
        'max_shift', 80,... % maximum rigid shift in each direction (default: [15,15,5])
        'bin_width', 100,... % width of each bin (default: 10)  use 40
        'iter', 1);... % number of data passes (default: 1)
        %'output_type', 'tiff',...
        %'tiff_filename', [dirname, suffix, fn, '_NoRMC', ext]);
    
    % Get non-rigid motion correction
    tic;
    disp('Calculating motion correction...')
    [M2, shifts, template2] = normcorre_batch(F, options_nonrigid); %F -> M1)
    toc;
    %}
    
    %%%%%% Save the result as a multi-Tif %%%%%%
    out_name = [dirname, fsuf, fn, psuf, '_NoRMC.tif'];
    options.append = true;
    saveastiff(uint16(M2), out_name, options);
    disp([fsuf, fn, psuf, '_NoRMC.tif', ' is saved!']);
    %}
    end
end