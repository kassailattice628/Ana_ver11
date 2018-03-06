function Col_ROIs(~,~)
%%
global imgobj
global mainvar
global sobj

img_sz = 320;

%% make ROI MASK for response map
if ~isfield(imgobj, 'Mask_rois')
    %import ROI info from imageJ format
    [roiname, dir] = uigetfile([mainvar.dirname2, '*.zip'], 'Select ImageJ ROI data');
    ROIs = ReadImageJROI([dir,roiname]);
    
    %ROI position (XY-cordinate)
    c = cell(imgobj.maxROIs,1);
    r = cell(imgobj.maxROIs,1);
    %mask
    imgobj.Mask_rois = false(img_sz * img_sz, imgobj.maxROIs);
    %center position
    imgobj.centroid = zeros(2, imgobj.maxROIs);
    
    for i = 1:imgobj.maxROIs
        c{i} = [ROIs{1,i}.mnCoordinates(:,1); ROIs{1,i}.mnCoordinates(1,1)];
        r{i} = [ROIs{1,i}.mnCoordinates(:,2); ROIs{1,i}.mnCoordinates(1,2)];
        
        %MASK for each ROI, extract ROI center
        M2d = poly2mask(c{i}, r{i}, img_sz, img_sz);
        rp = regionprops(M2d,'centroid');
        if ~isempty(rp)
            imgobj.centroid(:,i) = (rp.Centroid)';
        else
            imgobj.centroid(:,i) = [0, 0];
        end
        imgobj.Mask_rois(:,i) = reshape(M2d, [], 1);
    end
end
%%
%background img
imgBG = zeros(img_sz * img_sz, 3);

%% make color map
switch sobj.pattern
    case 'Size_rand'
        map_size
        
    case {'Sin', 'Rect', 'Gabor', 'MoveBar'}
        map_angler;
        
    case {'Uni'}
        map_nxn(1);
        
    case 'FineMap'
        map_nxn(2)
        
    otherwise
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function map_size
        imgBG2 = zeros(img_sz * img_sz, 3);
        %% set colormap based on 1 parameter
        rois = find(max(imgobj.R_size(:,:,2))>0.15);
        RGB_list = colormap(jet(7));
        for i2 = rois
            [~, best_i_on] = max(imgobj.R_size(:, i2, 1));
            [~, best_i_off] = max(imgobj.R_size(:, i2, 2));
            %ON
            RGB = RGB_list(best_i_on,:);
            imgBG(imgobj.Mask_rois(:,i2),1) = RGB(1);
            imgBG(imgobj.Mask_rois(:,i2),2) = RGB(2);
            imgBG(imgobj.Mask_rois(:,i2),3) = RGB(3);
            %OFF
            RGB2 = RGB_list(best_i_off,:);
            imgBG2(imgobj.Mask_rois(:,i2),1) = RGB2(1);
            imgBG2(imgobj.Mask_rois(:,i2),2) = RGB2(2);
            imgBG2(imgobj.Mask_rois(:,i2),3) = RGB2(3);
        end
        
        imgBG = reshape(imgBG,[img_sz, img_sz, 3]);
        imgBG2 = reshape(imgBG2,[img_sz, img_sz, 3]);
        
        %show image
        figure
        subplot(1,2,1)
        imshow(imgBG)
        colormap(jet(7))
        colorbar
        
        subplot(1,2,2)
        imshow(imgBG2)
        colorbar
        %}
        
    end

%% %%%%%%%%%%%%%%%%%%%% %%
    function map_angler
        %% set colormap based on angler info
        % colorized every 10 deg in hue (HSV space), 360/10 = 36
        h_list = linspace(0, 1, 36);
        angle_list = linspace(0, 2*pi, 36);
        
        rois_selective = find(imgobj.L_dir > 0.2);
        rois_max = max(max(imgobj.dFF_s_ave));
        rois_valid = find(rois_max > 0.15);
        rois = intersect(rois_selective, rois_valid);
        
        for i2 = rois'
            %set HSV
            ang1 = find(angle_list > imgobj.Ang_dir(i2), 1, 'first');
            ang2 = find(angle_list <= imgobj.Ang_dir(i2), 1, 'last');
            if abs(imgobj.Ang_dir(i2)-ang1) < abs(imgobj.Ang_dir(i2) - ang2)
                ang = ang1;
            else
                ang = ang2;
            end
            h = h_list(ang);
            
            v = imgobj.L_dir(i2);
            if imgobj.L_dir(i2) > 1
                v = 1;
            end
            
            HSV_roi = [h, 1, v];
            RGB = hsv2rgb(HSV_roi);
            
            imgBG(imgobj.Mask_rois(:,i2),1) = RGB(1);
            imgBG(imgobj.Mask_rois(:,i2),2) = RGB(2);
            imgBG(imgobj.Mask_rois(:,i2),3) = RGB(3);
        end
        
        imgBG = reshape(imgBG,[img_sz, img_sz, 3]);
        
        figure
        %subplot(1,2,1)
        % response map
        imshow(imgBG)
        hold on
        % vector map
        [U, V] = pol2cart(imgobj.Ang_dir, imgobj.L_dir);
        quiver(imgobj.centroid(1,rois), imgobj.centroid(2,rois), U(rois)*50, -V(rois)*50,...
            'AutoScale', 'off', 'Color', 'w')
        axis ij
        axis([0, 320, 0, 320])
        hold off
        
        colormap(hsv(36));
        
        %{
        subplot(1,2,2)
        % vector map
        [U, V] = pol2cart(imgobj.Ang_dir, imgobj.L_dir);
        quiver(imgobj.centroid(1,rois), imgobj.centroid(2,rois), U(rois)*50, -V(rois)*50,...
            'AutoScale', 'off')
        axis ij
        axis([0, 320, 0, 320])
        axis square
        set(gca, 'Xticklabel', [], 'YTicklabel', []);
        %}
    end

%% %%%%%%%%%%%%%%%%%%%% %%
    function map_nxn(type)
        
        if type == 1
            div = sobj.divnum;
        elseif type == 2
            div = sobj.div_zoom;
        end
        
        % Colorize ROI along with stimulus positions (N x N divisions).
        
        %hue -> along column (=vertical position)
        h_list = linspace(0, 1, div+1);
        %blightness value -> along row (=horizontal position)
        v_list = linspace(0.2, 1, div+1);
        
        %roiごとに best position を出す．
        %best positionごとに，hue と value を与えて
        %roiを色付けする
        [val, ind] = max(max(imgobj.dFF_s_ave,[],1));
        
        for i2 = 1:imgobj.maxROIs
            %h(=hue) for vertical position
            h = h_list(ceil(ind(i2)/div));
            
            %v(=blightness value) for horizontal position
            v_res = rem(ind(i2), div);
            if v_res == 0
                v = v_list(end);
            else
                v_res = div;
                v = v_list(v_res);
            end
            
            if val <= 0.15
                v = 0;
            end
            
            HSV_roi = [h, 1, v];
            RGB = hsv2rgb(HSV_roi);
            imgBG(imgobj.Mask_rois(:,i2), 1) = RGB(1);
            imgBG(imgobj.Mask_rois(:,i2), 2) = RGB(2);
            imgBG(imgobj.Mask_rois(:,i2), 3) = RGB(3);
        end
        
        imgBG = reshape(imgBG, [img_sz, img_sz, 3]);
        
        %plot
        figure
        imshow(imgBG)
        axis ij
        axis([0, 320, 0, 320])
        %colormap(hsv(div))
        
        
        %stim position
        RGB_stim = zeros(div, div, 3);
        H = repmat(h_list(1:div)', 1, div);
        V = repmat(v_list(1:div), div, 1);
        for n1 = 1:div
            for n2 = 1:div
                RGB_stim(n1, n2, :) = hsv2rgb([H(n1, n2), 1, V(n1, n2)]);
            end
        end
        
        figure
        imagesc(RGB_stim)
        
    end



end %End of Col_ROIs