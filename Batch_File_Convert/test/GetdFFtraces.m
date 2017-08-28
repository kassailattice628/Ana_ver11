function dFF_mat = GetdFFtraces

%import ROI information, make MASK for each ROI, extract mean dFF response
%within each ROI (=neurons)

addpath(genpath('~/Dropbox/None_But_Air/Ana_ver11/'));

[dFFname, dir] = uigetfile('*.mat', 'Select dFF data (.mat)');
disp('loading MAT data as dFF >>>')
y = load([dir,dFFname]);
dFF = y.dFF;
nFRMs = size(dFF,3);

disp('>>> finish loading') 

[roiname] = uigetfile([dir,'*.zip'], 'Select ImageJ ROI data');
disp('load ROI.zip')
ROIs = ReadImageJROI([dir,roiname]);

nROIs = size(ROIs,2); % the number of total ROIs

c = cell(nROIs, 1);
r = cell(nROIs, 2);

%Mask
M = false(size(dFF, 1), size(dFF, 2), nROIs);
for i =  1:nROIs
    c{i} = [ROIs{1, i}.mnCoordinates(:,1); ROIs{1,i}.mnCoordinates(1,1)];
    r{i} = [ROIs{1, i}.mnCoordinates(:,2); ROIs{1,i}.mnCoordinates(1,2)];    
    %complete masks for each roi
    M(:,:,i) = poly2mask(c{i}, r{i}, size(dFF, 1), size(dFF, 2));
end

%Transform 3Dmat into 2Dmat
dFF = reshape(dFF, [], nFRMs);
M = reshape(M, [], nROIs);

%set empty ROI traces
dFF_mat = zeros(nFRMs, nROIs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
for i = 1:nROIs
    dFF_mat(:,i) = mean(dFF(M(:,i)>0, :));
end
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save as mat




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
imagesc(dFF_mat')
end