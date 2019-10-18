%Non-rigid Motion Correction, Batch using 2 Channel image set.

% Original@Github
% https://github.com/simonsfoundation/NoRMCorre
%
% Original Paper @bioRxiv
% http://biorxiv.org/content/early/2017/02/14/108514
% "NoRMCorre: An online algorithm for piecewise rigid motion correction of
% calcium imaging data"
% Eftychois A Pnevmatikakis, Andrea Giovannucci

%%
% Place two folders, named Ch1 and Ch2, for GECI and tg-fp.
%

%%
clear;
gcp;

% use NoRMCorre functions
addpath(genpath('/Users/lattice/Dropbox/TwoPhoton_Analysis/NoRMCorre/'));

% file info
if exist('dirname', 'var')
    [dirname, fname, ext, fsuf, psuf] = Get_File_Name(dirname);
else
    [dirname, fname, ext, fsuf, psuf] = Get_File_Name([]);
end

files = subdir(fullfile(dirname,['SC*', ext]));


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
        options_nonrigid1 = NoRMCorreSetParms...
            ('d1',size(F,1),'d2',size(F,2),...
            'grid_size', [60, 60],...  % size of non-overlapping regions (default: [d1,d2,d3])
            'overlap_pre', 20,... % size of overlapping region (default: [32,32,16])
            'us_fac', 20,... % upsampling factor for subpixel registration (default: 20)
            'mot_uf' , 4,... % degree of patches upsampling (default: [4,4,1])
            'max_dev', 3,... % maximum deviation of patch shift from rigid shift (default: [3,3,1])
            'max_shift', 30,... % maximum rigid shift in each direction (default: [15,15,5])
            'bin_width', 100,... % width of each bin (default: 10)  use 40
            'iter', 1);... % number of data passes (default: 1)
            
        
        %Regist static marker imgs
        disp('Calculating motion correction for static images...')
        [M1, shifts, template] = normcorre_batch(F, options_nonrigid1);
        
        options_nonrigid2 = NoRMCorreSetParms...
            ('d1',size(F,1),'d2',size(F,2),...
            'grid_size', [60, 60],...  % size of non-overlapping regions (default: [d1,d2,d3])
            'overlap_pre', 20,... % size of overlapping region (default: [32,32,16])
            'us_fac', 20,... % upsampling factor for subpixel registration (default: 20)
            'mot_uf' , 4,... % degree of patches upsampling (default: [4,4,1])
            'max_dev', 3,... % maximum deviation of patch shift from rigid shift (default: [3,3,1])
            'max_shift', 50,... % maximum rigid shift in each direction (default: [15,15,5])
            'bin_width', 100,... % width of each bin (default: 10)  use 40
            'iter', 1);... % number of data passes (default: 1)
            
        [M2, shifts, template] = normcorre_batch(M1, options_nonrigid1);
            
        %%%%%% Save the result of marger fp images as a multi-Tif %%%%%%
        
        out_name1 = [dirname, fsuf, fn, psuf, '_NoRMC.tif'];
        options.append = true;
        saveastiff(uint16(M1), out_name1, options);
        disp('Saved registerred satati images.')
        
    end
end