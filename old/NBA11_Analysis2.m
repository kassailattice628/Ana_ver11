%function NBA11_Analysis
% open iRecData

%% select file 
if exist('dirname', 'var')
    
else
    %select file
    [fname, dirname] = uigetfile('*.mat');
    load([dirname, fname]);
    %get trage data
    [~, fname2] = fileparts([dirname, fname]);
    fid = fopen([dirname, fname2, '_Data.mat'], 'r');
    DataSave = fread(fid, inf, 'single');
    fclose(fid);
    
    DataSave = reshape(DataSave, [recobj.recp+1, 6, length(DataSave)/(recobj.recp+1)/6]);
    hfig = GUI_NBA2(DataSave, ParamsSave, recobj, sobj, fname); 
end
    
