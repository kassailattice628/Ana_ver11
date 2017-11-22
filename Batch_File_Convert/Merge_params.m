function Merge_params
%Merge multiple parameters file

global DataSave
global ParamsSave
global recobj
global sobj

% file info, select .mat file
if exist('dirname', 'var')
    [dirname, ~, ext, fsuf, ~] = Get_File_Name(dirname);
else
    [dirname, ~, ext, fsuf, ~] = Get_File_Name([]);
end

%%
files = subdir(fullfile(dirname,['SC_*', ext]));

for i = 1:size(files,1);
    disp(files(i).name)
    
    load(files(i).name); 

%%%% Read parametes:::>>> %%%%
%DataSave
%ParamsSave
%recobj
%sobj

%merge parameters for "DataSave", "ParamsSave"
    if i == 1
        d = DataSave;
        p = ParamsSave;
        r = recobj;
        s = sobj;
        cycleCount = 0;
    else
        
        d = cat(3, d, DataSave);
        if i ~= 1
            for ii = 1:size(ParamsSave,2)
                ParamsSave{1,ii}.AIStartTime = ParamsSave{1,ii}.AIStartTime...
                    + p{1,end}.AIEndTime + p{1,end}.AIstep;
                
                ParamsSave{1,ii}.AIEndTime = ParamsSave{1,ii}.AIEndTime...
                    + p{1,end}.AIEndTime + p{1,end}.AIstep;
                
                ParamsSave{1,ii}.cycleNum = p{1,end}.cycleNum + ii;
            end
        end
        p = [p, ParamsSave];
    end
    
        
        cycleCount = recobj.cycleCount + cycleCount;
    %clear DataSave ParamsSave
end

DataSave = d;
ParamsSave = p;
recobj = r; recobj.cycleCount = cycleCount;
sobj = s;

save([dirname,fsuf,'merge',ext],'DataSave','ParamsSave','recobj','sobj')

disp('... saved.');

