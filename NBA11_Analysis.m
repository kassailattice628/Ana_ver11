%function NBA11_Analysis
% open iRecHS2Data
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
global hfig
global n
hfig = GUI_NBA(DataSave, ParamsSave, recobj, sobj, fname); 
n = 0;
Plot_next([], [], DataSave, 0, ParamsSave)