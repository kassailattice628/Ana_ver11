function Batch_Mat2Tif
% file info
[dirname, ~, ext, fsuf, psuf] = Get_File_Name;

files = dir(fullfile(dirname, '**.mat'));

for i =  1:size(files)
    if files(i).bytes > 0
        i1 = regexp(files(i).name,'\d*');
        i2 = regexp(files(i).name,'_');
        fn = files(i).name(i1(1):i2(1)-1);
        
        mat = load([dirname, fsuf, num2str(fn), psuf, ext]);
        disp('Loading Mat File > > > > >');
        img = mat.dFF;
        
        out_name  = [dirname, fsuf, num2str(fn), '_dFF.tif'];
        disp(['Saving Tiff File as ', out_name]);
        
        %save as tif
        options.append = true;
        saveastiff(img, out_name, options);
        
    end
end
end