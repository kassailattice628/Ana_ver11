%Read Tif and Convert to Mat binary files

%use "read_file" for reading tif"
addpath('/Users/lattice/Dropbox/NoRMCorre/');

%%%%%%%%%% file info %%%%%%%%%%
[fname, dirname] = uigetfile({'*.tif;*.tiff', 'Tif files'});
[~, fname, ext] = fileparts(fname);
[i1, i2] = regexp(fname, '\d*');
fsuf = fname(1:i1(1)-1);
psuf = fname(i2(1)+1:end);

%%%%%%%%%% Moify Here %%%%%%%%%
n_img = 1:11; % a vector of file number to be processed
%fsuf = 'SC';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = n_img
    clear F;
    
    fn = num2str(n);
    name = [dirname, fsuf, fn, psuf, '.tif'];
    disp(['Reading File:: ', name])
    % check file
    if ~exist(name, 'file')
        disp([name, 'NOT FOUND!!'])
        errordlg([name, 'is NOT FOUND!!'])
        continue
    end
    
    F = read_file(name);
    F = double(F);
    
    % save as mat binary
    if ~exist([dirname, '1_mat'], 'dir')
        mkdir([dirname, '1_mat']);
    end
    
    out_name = [dirname, '1_mat/', fsuf, fn, psuf, '.mat'];
    save(out_name, 'F');
    
    % delete Tif file
    delete(name)
end

disp('Batch Finished...');
