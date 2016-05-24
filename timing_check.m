% timing test 

[fname, dirname] = uigetfile('*.mat');
load([dirname, fname]);
%get trage data
[~, fname2] = fileparts([dirname, fname]);
fid = fopen([dirname, fname2, '_Data.mat'], 'r');
DataSave = fread(fid, inf, 'single');
fclose(fid);

DataSave = reshape(DataSave, [recobj.recp+1, 6, length(DataSave)/(recobj.recp+1)/6]);

%%
AIstart = DataSave(1,1,:);
AIstart = reshape(AIstart, [1,size(AIstart,3)]);

for n = 1:size(AIstart,2)
    RecStart(n) = ParamsSave{1,n}.RecStartTime;
end

start_diff = AIstart - RecStart;

%%
PSOnOFF = zeros(2,size(AIstart,2));
VBLOn = zeros(1,size(AIstart,2));
VBLOff = zeros(1,size(AIstart,2));

for n = 1:size(AIstart,2)
    AIt = DataSave(:,1,n);
    PSOnOFF(1,n) = AIt(find(DataSave(:,4,n) > 0.05, 1));
    PSOnOFF(2,n) = AIt(find(DataSave(:,4,n) > 0.05, 1, 'last'));
    
    VBLOn(n) = DataSave(1, 1, n) + ParamsSave{1,n}.stim1.On_time;
    VBLOff(n) = DataSave(1, 1, n) + ParamsSave{1,n}.stim1.Off_time;
end



%%
