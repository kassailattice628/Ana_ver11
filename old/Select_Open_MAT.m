% select new file and opne eye_plot

[fname, dirname] = uigetfile([dirname, '*.mat']);
load([dirname, fname]);

if exist('DataSave', 'var')
    % open GUI
    close(hfig.fig1)
    clear hfig
    hfig = GUI_NBA(DataSave, ParamsSave, recobj, sobj, fname);
else
    errordlg('DataSave is missing!!')
end