%Stack_muptiple tif files.

clear

% use "read_file" for reading tif"
addpath(genpath('/Users/lattice/Dropbox/TwoPhoton_Analysis/NoRMCorre/'));

% file info
if exist('dirname', 'var')
    [dirname, fname, ext, fsuf, psuf] = Get_File_Name(dirname);
else
    [dirname, fname, ext, fsuf, psuf] = Get_File_Name([]);
end

files = subdir(fullfile(dirname,['SC*', ext]));

stack_F = [];
for n = 1:size(files,1)
    if files(n).bytes > 0
        i1 = regexp(files(n).name, '\d*');
        i2 = regexp(files(n).name, '\.');
        fn = files(n).name(i1(end):i2(1)-1);
        
        name = files(n).name;
        
        if ~exist(name, 'file')
            errordlg('NOT found!')
            continue
        end
        
        F = read_file(name);
        stack_F = cat(3, F, stack_F);
        %T = size(F, ndims(F));
        %disp(T)
    end
    clear F 
end

stack_F = double(stack_F);
%%
out_name = [dirname, fsuf, '_stack.mat'];
save(out_name, 'stack_F', '-v7.3');
    
    
            

