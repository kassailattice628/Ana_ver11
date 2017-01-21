%function NBA11_Analysis
clearvars -global
clearvars
close all

global hfig
global n
global imgobj
global mainvar

addpath('FigOnOFF');
%% 
if exist('DataSave', 'var') == 0
    %select file
    [mainvar.fname, mainvar.dirname] = uigetfile('*.mat');
    load([mainvar.dirname, mainvar.fname]);
    
    while isempty(DataSave)
        errordlg('DataSave is missing!')
        % select another file
        [mainvar.fname, mainvar.dirname] = uigetfile([dirame, '*.mat']);
        load([mainvar.dirname, mainvar.fname]);
    end
else
    % DataSave is alread in the base workspace.
    if isempty(DataSave)
        while isempty(DataSave)
            errordlg('DataSave is missing!')
            % select another file
            [mainvar.fname, mainvar.dirname] = uigetfile([mainvar.dirname, '*.mat']);
            load([mainvar.dirname, mainvar.fname]);
        end
    end
end
%%
DataSave(:,3,:) =  DataSave(:,3,:)* 1000;
%%
% open GUI
hfig = GUI_NBA_Analysis(DataSave, ParamsSave, recobj, sobj, mainvar.fname); 
n = 0;
Plot_next([], [], DataSave, 0, ParamsSave)

%%
imgobj.nROI = 0;
imgobj.selectROI = 1;
imgobj.dFF =[];
imgobj.maxROIs =  1;
imgobj.FVsampt = 0.574616;