function Col_ROIs(~,~)
%%
global imgobj
global mainvar

img_sz = 320;

%%
if ~isfield(imgobj, 'Mask_rois')
    [roiname, dir] = uigetfile([mainvar.dirname, '*.zip'], 'Select ImageJ ROI data');
    ROIs = ReadImageJROI([dir,roiname]);
    
    %ROI‚ÌˆÊ’uî•ñŠi”[—p
    c = cell(imgobj.maxROIs,1);
    r = cell(imgobj.maxROIs,1);
    %mask
    %M = false(img_sz, img_sz, imgobj.maxROIs);
    imgobj.Mask_rois = false(img_sz * img_sz, imgobj.maxROIs);
    imgobj.centroid = zeros(2, imgobj.maxROIs);
    
    for i = 1:imgobj.maxROIs
        c{i} = [ROIs{1,i}.mnCoordinates(:,1); ROIs{1,i}.mnCoordinates(1,1)];
        r{i} = [ROIs{1,i}.mnCoordinates(:,2); ROIs{1,i}.mnCoordinates(1,2)];
        
        %ROIˆÊ’u‚Ìmask
        %M(:,:,i) = poly2mask(c{i}, r{i}, img_sz, img_sz); %ROI 1ŒÂ‚¸‚Â
        M2d = poly2mask(c{i}, r{i}, img_sz, img_sz);
        rp = regionprops(M2d,'centroid');
        disp(i)
        disp(rp)
        if ~isempty(rp)
            imgobj.centroid(:,i) = (rp.Centroid)';
        else
            imgobj.centroid(:,i) = [0, 0];
        end
        imgobj.Mask_rois(:,i) = reshape(M2d, [], 1);
    end
end


[U, V] = pol2cart(imgobj.Ang_dir, imgobj.L_dir);

%% set colormap %%
%10 deg ‚Ý‚ÅF‚Â‚¯‚é
h_list = linspace(0, 1, 36);
angle_list = linspace(0, 2*pi, 36);
%%

%background img
imgBG = zeros(img_sz * img_sz, 3);

rois_selective = find(imgobj.L_dir > 0.4);
rois_max = max(max(imgobj.dFF_s_ave));
rois_valid = find(rois_max > 0.3);
rois = intersect(rois_selective, rois_valid);
%disp(rois')
for i = rois'
    %set HSV
    ang1 = find(angle_list > imgobj.Ang_dir(i), 1, 'first');
    ang2 = find(angle_list <= imgobj.Ang_dir(i), 1, 'last');
    if abs(imgobj.Ang_dir(i)-ang1) < abs(imgobj.Ang_dir(i) - ang2)
        ang = ang1;
    else
        ang = ang2;
    end
    h = h_list(ang);
    
    v = imgobj.L_dir(i);
    if imgobj.L_dir(i) > 1
        v = 1;
    end
    
    HSV_roi = [h, 1, v];
    RGB = hsv2rgb(HSV_roi);
    
    imgBG(imgobj.Mask_rois(:,i),1) = RGB(1);
    imgBG(imgobj.Mask_rois(:,i),2) = RGB(2);
    imgBG(imgobj.Mask_rois(:,i),3) = RGB(3);
end

%%
imgBG = reshape(imgBG,[img_sz, img_sz, 3]);
figure
subplot(1,2,1)
imshow(imgBG)
colormap(hsv(36));
colorbar;

subplot(1,2,2)
quiver(imgobj.centroid(1,rois), imgobj.centroid(2,rois), U(rois)*10, -V(rois)*10)
axis ij
axis([0, 320, 0, 320])
axis square
set(gca, 'Xticklabel', [], 'YTicklabel', []);




%%