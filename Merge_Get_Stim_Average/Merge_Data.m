function Merge_Data

addpath('~/Desktop/Merge/')
addpath('/Users/lattice/Dropbox/None_But_Air/Ana_ver11/')

dirname = '/Volumes/Extreme_SSD/Ana_DSOS_Data/WT382/190801/';
f1 = 'SC_3_RemEyeMov.mat';
f2 = 'SC_4_RemEyeMov.mat';

savefname = 'SC_3and4_RemEyeMov.mat';

%% Data Load
d1 = load([dirname, f1], 'imgobj', 'sobj');
sobj = d1.sobj;
d2 = load([dirname, f2], 'imgobj');

%% MergeData (s_each ‚Æ s_ave ‚Ì‚Ý‚Å‚¢‚¢‚©j
%size check
if d1.imgobj.maxROIs ~= d2.imgobj.maxROIs
    nroi = max(d1.imgobj.maxROIs, d2.imgobj.maxROIs);
    
    %each max
    temp = NaN(size(d1.imgobj.dFF_s_each, 1), size(d1.imgobj.dFF_s_each,2), nroi);
    s_each1 = temp;
    s_each2 = temp;
    s_each1(:,:,1:size(d1.imgobj.dFF_s_each, 3)) = d1.imgobj.dFF_s_each;
    s_each2(:,:,1:size(d2.imgobj.dFF_s_each, 3)) = d2.imgobj.dFF_s_each;
    
    temp = NaN(size(d1.imgobj.dFF_s_each_ori, 1), size(d1.imgobj.dFF_s_each_ori,2), nroi);
    s_each1_ori = temp;
    s_each2_ori = temp;
    s_each1_ori(:,:,1:size(d1.imgobj.dFF_s_each_ori, 3)) = d1.imgobj.dFF_s_each_ori;
    s_each2_ori(:,:,1:size(d2.imgobj.dFF_s_each_ori, 3)) = d2.imgobj.dFF_s_each_ori;
    
    %average
    temp = NaN(size(d1.imgobj.dFF_s_ave, 1), size(d1.imgobj.dFF_s_ave,2), nroi);
    s_ave1 = temp;
    s_ave2 = temp;
    s_ave1(:,:,1:size(d1.imgobj.dFF_s_ave, 3)) = d1.imgobj.dFF_s_ave;
    s_ave2(:,:,1:size(d2.imgobj.dFF_s_ave, 3)) = d2.imgobj.dFF_s_ave;
    
    temp = NaN(size(d1.imgobj.dFF_s_ave_ori, 1), size(d1.imgobj.dFF_s_ave_ori,2), nroi);
    s_ave1_ori = temp;
    s_ave2_ori = temp;
    s_ave1_ori(:,:,1:size(d1.imgobj.dFF_s_ave_ori, 3)) = d1.imgobj.dFF_s_ave_ori;
    s_ave2_ori(:,:,1:size(d2.imgobj.dFF_s_ave_ori, 3)) = d2.imgobj.dFF_s_ave_ori;
    
else
    nroi = d1.imgobj.maxROIs;
    s_each1 = d1.imgobj.dFF_s_each;
    s_each2 = d2.imgobj.dFF_s_each;
    
    
    s_each1_ori = d1.imgobj.dFF_s_each_ori;
    s_each2_ori = d2.imgobj.dFF_s_each_ori;
    
    s_ave1_ori = d1.imgobj.dFF_s_ave_ori;
    s_ave2_ori = d2.imgobj.dFF_s_ave_ori;
end
m_each = vertcat(s_each1, s_each2);
m_each_ori = vertcat(s_each1_ori, s_each2_ori);

temp = NaN(size(d1.imgobj.dFF_s_ave, 1), size(d1.imgobj.dFF_s_ave,2), nroi, 2);
temp(:,:,:,1) = s_ave1;
temp(:,:,:,2) = s_ave2;
m_ave = nanmean(temp, 4);

temp = NaN(size(d1.imgobj.dFF_s_ave_ori, 1), size(d1.imgobj.dFF_s_ave_ori,2), nroi, 2);
temp(:,:,:,1) = s_ave1_ori;
temp(:,:,:,2) = s_ave2_ori;
m_ave_ori = nanmean(temp, 4);


%%
imgobj.dFF_s_ave = m_ave;
imgobj.dFF_s_ave_ori = m_ave_ori;
imgobj.dFF_s_each = m_each;
imgobj.dFF_s_each_ori = m_each_ori;

imgobj.directions = d1.imgobj.directions;
imgobj.maxROIs = nroi;

if d1.imgobj.maxROIs > d2.imgobj.maxROIs
    imgobj.Mask_rois = d1.imgobj.Mask_rois;
    imgobj.centroid = d1.imgobj.centroid;
else
    imgobj.Mask_rois = d2.imgobj.Mask_rois;
    imgobj.centroid = d2.imgobj.centroid;
end

%%
thres = 0.15;
R_max = max(nanmean(m_each));
roi_nores = find(R_max <= thres | isnan(R_max));
imgobj.roi_no_res = roi_nores;
all = 1:imgobj.maxROIs;
imgobj.roi_res = setdiff(all, roi_nores);

%roi_pos_R, roi_nega_R
roi_p = [];
roi_n = [];
for i = 1:nroi
    R_max = max(max(m_ave(:,:,i)));
    R_min = min(min(m_ave(:,:,i)));
    if abs(R_max) >= abs(R_min)
        roi_p = [roi_p, i];
    else
        roi_n = [roi_n, i];
    end
end
imgobj.roi_pos_R = roi_p;
imgobj.roi_nega_R = roi_n;

[~, i] = intersect(roi_p, roi_nores);
imgobj.roi_pos_R(i) = [];
[~, i] = intersect(roi_n, roi_nores);
imgobj.roi_nega_R(i) = [];

%%

imgobj = Get_Boot_DOSI(imgobj);

                
%%
imgobj= Get_mat2D(imgobj, sobj);




%%
save([dirname,savefname], 'imgobj', 'sobj');
end