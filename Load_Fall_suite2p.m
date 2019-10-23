function [dFF_suite2p, Mask_rois, centroid] = Load_Fall_suite2p(varargin)
% suitsp Ç≈èoóÕÇµÇΩ Fall.mat Ç©ÇÁ
% F: ROI fluorescence
% Fneu: Neuropil fluorescence
% iscell: ROI is cell or not (1/0)
% stat: other inof. like ROI position

switch nargin
    case 0
        [F, Fneu, iscell, stat] = load_Fall;
        imgsz = 320;
        f0s = 76;
    case 2
        errordlg('The number of parameters should be 3 or 4')
    case 3
        %varargin{1: dir name, 2: file name, 3:imgobj}
        im = varargin{3};
        if isfiled(im, 'imgsz')
            imgsz = max(im.imgsz);
            f0s = im.f0;
            load([varargin{1}, varargin{2}], 'F', 'Fneu', 'iscell', 'stat');
        else
            errordlg('imgobj.imgsz is not defined !!! ')
        end

    case 4
        imgsz = varargin{3};
        f0s = varargin{4};
end

rois = find(iscell==1);

%% Response

dFF_suite2p = F(rois', :) - 0.7*Fneu(rois',:);
dFF_suite2p = dFF_suite2p';

F0 = mean(dFF_suite2p(1:f0s, :));

dFF_suite2p = (dFF_suite2p - F0)./F0;

%% ROI shape and position (and roi center)
Mask_rois = zeros(imgsz*imgsz, length(rois));
centroid = zeros(length(rois), 2);
for i = 1:length(rois)
    n = rois(i);
    a = zeros(imgsz, imgsz);
    y = stat{n}.ypix + 1;
    x = stat{n}.xpix + 1;
    for m = 1:length(y)
        a(y(m), x(m)) = 1;
    end
    %figure, imshow(a)
    Mask_rois(:,i) = reshape(a,[imgsz*imgsz,1]);
    
    %
    centroid(i,:) = fliplr(stat{n}.med);
end
%%
Mask_rois = logical(Mask_rois);
centroid = centroid';

end


%%
function  [F, Fneu, iscell, stat] = load_Fall

[fname, dirname] = uigetfile('*.mat',...
    'Select Fall.mat from suit2p)');

load([dirname, fname], 'F', 'Fneu', 'iscell', 'stat');

end