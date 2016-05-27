% select a new file and opne plot window
global hfig

clear DataSave
clear ParamsSave
clear recobj
clear sobj

[fname, dirname] = uigetfile([dirname, '*.mat']);
load([dirname, fname]);

if exist('DataSave', 'var')
    % open GUI
    set(hfig.fig1, 'Name', ['NBA ver:', num2str(recobj.NBAver)]);
    set(hfig.set_n, 'string', 1)
    set(hfig.file_name, 'string', fname)
    
    % update plot
    Plot_next([], [], DataSave, 0, ParamsSave)
else
    errordlg('DataSave is missing!!')
end