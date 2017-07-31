function Select_Open_MAT(~, ~)
% select a new file and opne plot window

%%
clearvars -global DataSave ParamsSave recobj
global hfig
global n
global mainvar
global imgobj
global recobj
global DataSave
global ParamsSave
global sobj

delete(hfig.fig1);
if isfield(imgobj,'dFF')
    imgobj = rmfield(imgobj, 'dFF');
end

%%
[mainvar.fname, mainvar.dirname] = uigetfile([mainvar.dirname, '*.mat']);
load([mainvar.dirname, mainvar.fname]);

%loaded file contains DataSave
if isempty(DataSave)
    errordlg('DataSave is missing')
    [mainvar.fname, mainvar.dirname] = uigetfile([mainvar.dirname, '*.mat']);
    load([mainvar.dirname, mainvar.fname]);
end

%%
imgobj.nROI = 0;
imgobj.selectROI = 1;
%imgobj.maxROIs =  1;

if ~isfield(imgobj, 'dFF')
    imgobj.dFF =[];
end

if ~isfield(imgobj, 'FVsampt')
    imgobj.FVsampt = 0.574616;
end

%%%%%%%%%%
if exist('DataSave', 'var')
    if isempty(imgobj.dFF)
        DataSave(:,3,:) =  DataSave(:,3,:)* 1000;
    end
    hfig = GUI_NBA_Analysis(DataSave, ParamsSave, recobj, sobj, mainvar.fname); 
    n = 0;
    Plot_next([], [], DataSave, 0, ParamsSave, recobj)
else
    errordlg('DataSave is missing!!')
%}
end
