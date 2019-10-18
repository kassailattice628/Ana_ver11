function Get_Mosaic_Average

global sobj
global imgobj
global recobj
global ParamsSave
%% Analysis for Mosaic RF


div = sobj.div_zoom;
dist = sobj.dist;

% prepare pseudo stim postition
pix_bg = 500;
VIS_div = pix_bg / div;

STIM_ave = zeros(pix_bg, pix_bg);
RESPONSE_ave = STIM_ave;

for roi = imgobj.selectROI
    
    if imgobj.R_max(roi) <= 0.15
        continue
    end
    
    for n = recobj.prestim + 1:size(ParamsSave, 2)
        sz_dots = ParamsSave{1,n}.stim1.size_deg_mat;
        num_dots = length(sz_dots);
        stim_pos = ParamsSave{1,n}.stim1.position_deg_mat;
        
        %shift stim position from (0,0) -> pos -> pix
        stim_pos2 = (stim_pos + div/2) * VIS_div;
        %stim size deg2pix
        deg2pix = pix_bg/dist;
        sz_dots_pix = sz_dots * deg2pix;
        %
        %neural response
        R = max(imgobj.dFF_s_ave(:,n - recobj.prestim, roi));
        
        STIM = zeros(pix_bg, pix_bg);
        RESPONSE = STIM;
        for i = 1:num_dots
            x_ = stim_pos2(1,i)-sz_dots_pix(i)/2 : stim_pos2(1,i)+sz_dots_pix(i)/2 -1;
            y_ = stim_pos2(2,i)-sz_dots_pix(i)/2 : stim_pos2(2,i)+sz_dots_pix(i)/2 -1;
            STIM(x_ + 1 , y_ + 1) = 1;
            RESPONSE(x_ + 1 , y_ + 1) = R;
        end
        
        STIM_ave = STIM_ave + STIM;
        RESPONSE_ave = RESPONSE_ave + RESPONSE;
    end
    %STIM_ave = STIM_ave/length(recobj.prestim+1:size(ParamsSave, 2));
    
    ResStim_ave = RESPONSE_ave ./ STIM_ave;
    
    figure
    colormap(gray(20))
    subplot(1,2,1)
    image(STIM_ave)
    subplot(1,2,2)
    imagesc(ResStim_ave)
end

