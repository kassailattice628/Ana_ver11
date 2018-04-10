%Calc dFF, Batch

% Read a motion-corrected tif file
% Make F0 image
% Calc (F-F0)/F0
% Save multi-tif image

% use "read_file" for reading tif"
addpath('/Users/lattice/Dropbox/TwoPhoton_Analysis/NoRMCorre/');
% file info
[dirname, fname, ext, fsuf, psuf] = Get_File_Name;

%%%%%%%%%% modify info %%%%%%%%%%
% a vector of file number to be processed, and thouse f0 frame numbers.


%180111, VT33
%n_img = 1:6;
%f0_frames = [72,72,72,72,72,72];

%180116, VT33
%n_img = 1:16;
%f0_frames = [76, 13, 76, 76, 76, 13, 37, 17, 76, 76, 76, 16, 76, 76, 76, 76];

%180117, 488
%n_img = 1:5;
%f0_frames = [76, 76, 13, 76, 76];

%180118, VT2
%n_img = 1:10;
%f0_frames = [13, 76, 76, 51, 76, 13, 76, 76, 76, 76];

%180118, VT3
%n_img = 1:3;
%f0_frames = [76, 13, 76];

%180118, VT7
%n_img = 1:4;
%f0_frames = [76, 13, 76, 76];


%180119, 484
%n_img = 1:5;
%f0_frames = [76, 76, 76, 77, 13];

%180119, 486
%n_img = 1:4;
%f0_frames = [76, 13, 76, 76];

%180123, VT2
%n_img = 1:5;
%f0_frames = [76, 13, 76, 76, 76];


%180125 484
%n_img = 1:9;
%f0_frames = [1000, 76, 76, 34, 76, 76, 34, 76, 76];

%
%180126, VT33
%n_img = 1:5;
%f0_frames = [76, 76, 76, 34, 76];

%180129, VT2
%n_img = 1:8;
%f0_frames = [76, 34, 76, 76, 76, 76, 76, 76];


%180129, VT3
%n_img = 1:4;
%f0_frames = [76, 34, 76, 76];

%180130, VT33
%n_img = 1:18;
%f0_frames = [76, 34, 34, 76, 76, 41, 76, 76, 34, 76, 76, 76, 76, 76, 76, 76, 76, 76];

%180131, VT2
%n_img = 2:6;
%f0_frames = [76, 58, 76, 30, 76];

%
%180131, VT7
%n_img = 1:4;
%f0_frames = [76, 76, 34, 191];

%180201, VT33
%n_img = [1:8, 10:13];
%f0_frames = [76, 55, 76, 76, 76, 76, 76, 76, 41, 76, 76, 76];
%n_img =  10:13;
%f0_frames =  [41, 76, 76, 76];

%180209, VT3
%n_img =  1:14;
%f0_frames = [34, 76, 76, 41, 76, 76, 76, 76, 78, 76, 76, 76, 76, 76];

%180227, VT33
%n_img = 1:18;
%f0_frames = [41, 76, 76, 76, 76, 27, 76, 76, 76, 76, 76, 76, 76, 34, 76, 76, 76, 76];

n_img = 3;
f0_frames = 30;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dFF are save as MAT or TIFF
i_save = input('Save dFF as Tiff? [Y/N] or both Tiff & Mat [W] >> ', 's');


%% Batch for multiple files %%
nn = 0;
for n = n_img
    clear F
    clear F0
    clear dFF
    
    nn = nn + 1; %counter
    
    fn = num2str(n);
    name = [dirname, fsuf, fn, psuf, ext];
    disp(['Reading File:: ', name])
    % check file
    if ~exist(name, 'file')
        errordlg([name, ' is NOT FOUND!!'])
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
    dFF = single(dFF);
    
    
    F = dFF;
    
    
    % Create new directry
    if ~exist([dirname, 'dFF'], 'dir')
        mkdir([dirname,'dFF'])
    end
    
    % File Save
    switch i_save
        case {'Y', 'y', 'Yes', 'YES'}
            % Save as tif %
            out_name = [dirname, 'dFF/', fsuf, fn, psuf, '_dFF.tif'];
            disp(['Saving Tiff File as ', out_name]);
            options.append = true;
            saveastiff(F, out_name, options);
        case {'N', 'n', 'No', 'NO'}
            % Save as mat
            out_name = [dirname, 'dFF/', fsuf, fn, psuf, '_dFF.mat'];
            disp(['Saving MAT File as ', out_name]);
            save(out_name, 'F', '-v7.3');
            
        case {'W', 'w'}
            % Save as tif %
            out_name = [dirname, 'dFF/', fsuf, fn, psuf, '_dFF.tif'];
            disp(['Saving Tiff File as ', out_name]);
            options.append = true;
            saveastiff(F, out_name, options);
             % Save as mat %
            out_name = [dirname, 'dFF/', fsuf, fn, psuf, '_dFF.mat'];
            disp(['Saving MAT File as ', out_name]);
            save(out_name, 'F', '-v7.3');
            
    end
    
    disp('Save Finished!!');
end
