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
n_img = 14:19;
f0_frames = [76,76,76,76,76,86];
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
