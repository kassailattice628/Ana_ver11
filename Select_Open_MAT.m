% select a new file and opne plot window
%%
global hfig
global n
%%
delete(hfig.fig1)
clear DataSave
clear ParamsSave
clear n
clear recobj
clear sobj

%%

[fname, dirname] = uigetfile([dirname, '*.mat']);
load([dirname, fname]);

if exist('DataSave', 'var')
    % open GUI
    %{
    set(hfig.fig1, 'Name', ['NBA ver:', num2str(recobj.NBAver)]);
    set(hfig.set_n, 'string', 1)
    set(hfig.file_name, 'string', fname)
    %}
    % update plot
    hfig = GUI_NBA(DataSave, ParamsSave, recobj, sobj, fname); 
    n = 0;
    Plot_next([], [], DataSave, 0, ParamsSave)
else
    errordlg('DataSave is missing!!')
end
