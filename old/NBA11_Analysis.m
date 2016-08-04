%function NBA11_Analysis
% open iRecData

%% select file 

if exist('DataSave', 'var') == 0
    %select file
    [fname, dirname] = uigetfile('*.mat');
    if fname == 0 || dirname == 0
        errordlg('File not selected!');
    else
        load([dirname, fname])
    end
    while isempty(DataSave)
        errordlg('DataSave is missing!')
        % select another file
        [fname, dirname] = uigetfile([dirame, '*.mat']);
        load([dirname, fname]);
    end  
else 
    % DataSave is already in the base workspace.
    if isempty(DataSave)
        while isempty(DataSave)
            errordlg('DataSave is missing!')
            % select another file
            [fname, dirname] = uigetfile([dirname, '*.mat']);
            load([dirname, fname]);
        end
    end
end
