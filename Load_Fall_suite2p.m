function [dFF_suite2p, Mask_rois, centroid] = Load_Fall_suite2p(varargin)

switch nargin
    case 0
        [F, Fneu, iscell, stat] = load_Fall;
    case 2
        %varargin{1: dir name, 2: file name}
        load([varargin{1}, varargin{2}], 'F', 'Fneu', 'iscell', 'stat');
end

rois = find(iscell==1);

Mask_rois = zeros(320*320, length(rois));
centroid = zeros(length(rois), 2);
dFF_suite2p = F(rois', :) - 0.7*Fneu(rois',:);
dFF_suite2p=dFF_suite2p';
F0 = mean(dFF_suite2p(1:78, :));
dFF_suite2p = (dFF_suite2p - F0)./F0;
%%
for i = 1:length(rois)
    n = rois(i);
    a = zeros(320, 320);
    y = stat{n}.ypix + 1;
    x = stat{n}.xpix + 1;
    for m = 1:length(y)
        a(y(m), x(m)) = 1;
    end
    %figure, imshow(a)
    Mask_rois(:,i) = reshape(a,[320*320,1]); 
    
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