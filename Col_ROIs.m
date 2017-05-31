
%Col_ROIs(~,~)

%引数に回す
roi_path = '/Users/lattice/Dropbox/PCA_demo/SC7_RoiSet.zip';

ROIs = ReadImageJROI(roi_path);
nROIs = size(ROIs,2);


img_sz = 320;
%ROIの位置情報格納用
c = cell(nROI,1);
r = cell(nROI,1);
%mask
M = flase(img_sz, img_sz, nROIs);

for i = 1:nROIs
    c{i} = [ROIs{1,i}.mnCoordinates(:,1); ROIs{1,i}.mnCoordinates(1,1)];
    r{i} = [ROIs{1,i}.mnCoordinates(:,2); ROIs{1,i}.mnCoordinates(1,2)];
    
    %ROI位置のmask
     M(:,:,i) = poly2mask(c{i}, r{i}, img_sz, img_sz); %ROI 1個ずつ
end

