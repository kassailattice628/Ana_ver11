% select new file and opne eye_plot

[fname, dirname] = uigetfile([dirname, '*.mat']);
load([dirname, fname]);
[~, fname2] = fileparts([dirname, fname]);
fid = fopen([dirname, fname2, '_Data.mat'], 'r');
DataSave = fread(fid, inf, 'single');
fclose(fid);

if exist('DataSave', 'var')
    % open GUI
    close(hfig.fig1)
    clear hfig
    DataSave = reshape(DataSave, [recobj.recp+1, 6, length(DataSave)/(recobj.recp+1)/6]);
    hfig = GUI_NBA2(DataSave, ParamsSave, recobj, sobj, fname);
else
    errordlg('DataSave is missing!!')
end