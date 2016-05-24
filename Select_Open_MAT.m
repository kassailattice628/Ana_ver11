% select a new file and opne plot window
global hfig
global n

clear DataSave
clear ParamsSave
clear recobj
clear sobj

[fname, dirname] = uigetfile([dirname, '*.mat']);
load([dirname, fname]);



if exist('DataSave', 'var')
    % open GUI
    close(hfig.fig1)
    clear hfig

    hfig = GUI_NBA(DataSave, ParamsSave, recobj, sobj, fname);
    n = 0;
    Plot_next([], [], DataSave, 0, ParamsSave)
else
    errordlg('DataSave is missing!!')
end