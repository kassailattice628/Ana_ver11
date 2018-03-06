function Select_Open_MAT(~, ~)
% select a new file and opne plot window

%%
clearvars -global DataSave ParamsSave recobj imgobj
global hfig
global n
global mainvar
global imgobj
global recobj
global DataSave
global ParamsSave
global sobj

%%
delete(hfig.fig1);

%%
imgobj.dFF =[];
imgobj.nROI = 0;
imgobj.selectROI = 1;
imgobj.maxROIs =  1;

if ~isfield(imgobj, 'FVsampt')
    imgobj.FVsampt = 0.574616;
end
%{
%%
imgobj.nROI = 0;
imgobj.selectROI = 1;
imgobj.maxROIs =  1;

if ~isfield(imgobj, 'FVsampt')
    imgobj.FVsampt = 0.574616;
end

if isfield(imgobj, 'dFF_s_ave')
   fields = {'dFF_s_ave', 'dFF_s_ave_os', 'dFF_raw', 'FVt'};
   imgobj = rmfield(imgobj, fields);
end

if isfield(imgobj, 'L_ori')
    fields = {'L_ori', 'L_dir', 'Ang_ori', 'Ang_dir',};
    imgobj = rmfield(imgobj, fields);
end

if isfield(imgobj, 'Mask_rois')
    fields = {'Mask_rois', 'centroid'};
    imgobj = rmfield(imgobj, fields);
end

if isfield(imgobj, 'dir_sel_rois')
    imgobj = rmfield(imgobj, 'dir_sel_rois');
end
%}

%% Load Data %%
[fname, dirname] = uigetfile([mainvar.dirname, '*.mat']);
load([dirname, fname]);
mainvar.dirname = dirname;


%loaded file contains DataSave
if isempty(DataSave)
    errordlg('DataSave is missing')
    [fname, dirname] = uigetfile([mainvar.dirname, '*.mat']);
    load([dirname, fname]) ;
    mainvar.dirname = dirname;
end

%% %%%%%%%%
if exist('DataSave', 'var')
    % check file name
    if isfield(mainvar, 'fname') && length(regexp(fname, '_')) > 1
        i = regexp(fname, '_');
        mainvar.fname = [fname(1:i(end)-1), '.mat'];
        disp(fname)
    else
        mainvar.fname = fname;
    end
    
    % check DataSave
    if isempty(imgobj.dFF)
        DataSave(:,3,:) =  DataSave(:,3,:)* 1000;
    end
    
    % Open GUI
    hfig = GUI_NBA_Analysis(DataSave, ParamsSave, recobj, sobj, mainvar.fname); 
    n = 0;
    Plot_next([], [], DataSave, 0, ParamsSave, recobj)
else
    errordlg('DataSave is missing!!')
%}
end

disp(mainvar)