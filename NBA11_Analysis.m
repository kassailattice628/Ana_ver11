%function NBA11_Analysis
clearvars -global
clearvars
close all

global hfig
global n
global imgobj

addpath('FigOnOFF');
%% 
if exist('DataSave', 'var') == 0
    %select file
    [fname, dirname] = uigetfile('*.mat');
    load([dirname, fname]);
    
    while isempty(DataSave)
        errordlg('DataSave is missing!')
        % select another file
        [fname, dirname] = uigetfile([dirame, '*.mat']);
        load([dirname, fname]);
    end
else
    % DataSave is alread in the base workspace.
    if isempty(DataSave)
        while isempty(DataSave)
            errordlg('DataSave is missing!')
            % select another file
            [fname, dirname] = uigetfile([dirname, '*.mat']);
            load([dirname, fname]);
        end
    end
end
%%
% open GUI
hfig = GUI_NBA_Analysis(DataSave, ParamsSave, recobj, sobj, fname); 
n = 0;
Plot_next([], [], DataSave, 0, ParamsSave)

%%
imgobj.nROI = 0;
imgobj.selectROI = 1;
imgobj.dFF =[];
imgobj.maxROIs =  1;
imgobj.FVsampt = 0.574616;