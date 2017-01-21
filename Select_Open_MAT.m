function Select_Open_MAT(~,~)
% select a new file and opne plot window
global hfig
global n
global mainvar
global DataSave

%%
delete(hfig.fig1);
clearvars -global recobj sobj DataSave ParamsSave

%%

[mainvar.fname, mainvar.dirname] = uigetfile([mainvar.dirname, '*.mat']);
load([mainvar.dirname, mainvar.fname]);

if exist('DataSave', 'var')
    DataSave(:,3,:) =  DataSave(:,3,:)* 1000;
    hfig = GUI_NBA_Analysis(DataSave, ParamsSave, recobj, sobj, mainvar.fname); 
    n = 0;
    Plot_next([], [], DataSave, 0, ParamsSave)
else
    errordlg('DataSave is missing!!')
end
