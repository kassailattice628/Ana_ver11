function Col_ROIs(~,~)
%%
global imgobj
global mainvar
global sobj

if ~isfield(imgobj, 'img_sz')
    img_sz = 320;
else
    img_sz = imgobj.img_sz;
end

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
        map_size;
        
    case {'Sin', 'Rect', 'Gabor'}
        map_angler(0, imgBG);
        
    case {'MoveBar', 'MoveSpot'}
        map_angler(0, imgBG);
        map_angler(1, imgBG);
        map_angler(2, imgBG);
        
    case {'Uni'}
        map_nxn(1);
        
        if isfield(imgobj, 'b_GaRot2D')
            imgBG = zeros(img_sz * img_sz, 3);
            map_nxn_use_fitdata;
        end
        
    case 'FineMap'
        map_nxn(2);
        if isfield(imgobj, 'b_GaRot2D')
            
            
            imgBG = zeros(img_sz * img_sz, 3);
            map_nxn_use_fitdata;
        end
        
    case 'StaticBar'
        map_angler(1, imgBG);
    otherwise
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function map_size
        imgBG2 = zeros(img_sz * img_sz, 3);
        imgBG3 = zeros(img_sz * img_sz, 3);
        
        %RGB_list = colormap(jet(7));
        RGB_list = colormap(jet(size(imgobj.R_size,1)));
        for i2 = imgobj.roi_res
            [~, best_i_on] = max(imgobj.R_size(1:5, i2, 1));
            [~, best_i_off] = max(imgobj.R_size(1:5, i2, 2));
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
            
            
            
            if size(imgobj.R_size, 3) == 3
                [~, best_i_onoff] = max(imgobj.R_size(1:5, i2, 3));
                RGB3 = RGB_list(best_i_onoff,:);
                imgBG3(imgobj.Mask_rois(:,i2),1) = RGB3(1);
                imgBG3(imgobj.Mask_rois(:,i2),2) = RGB3(2);
                imgBG3(imgobj.Mask_rois(:,i2),3) = RGB3(3);
            end
            
            
        end
        
        imgBG = reshape(imgBG,[img_sz, img_sz, 3]);
        imgBG2 = reshape(imgBG2,[img_sz, img_sz, 3]);
        imgBG3 = reshape(imgBG3,[img_sz, img_sz, 3]);
        
        
        %show image
        figure
        subplot(1,2,1)
        imshow(imgBG)
        %colormap(jet(7))
        colormap(jet(size(imgobj.R_size,1)))
        colorbar
        
        subplot(1,2,2)
        imshow(imgBG2)
        colorbar
        
        figure
        imshow(imgBG)
        figure
        imshow(imgBG2)
        
        figure
        imshow(imgBG3)
        %}
        
    end

%% %%%%%%%%%%%%%%%%%%%% %%
    function map_angler(type, imgBG)
        
        switch type
            case 0 %for direction selective
                n = 36;
                h_list = linspace(0, 1, n);
                angle_list = linspace(0, 2*pi, n);
                L = imgobj.L_dir;
                Ang = imgobj.Ang_dir;
                
                if isfield(imgobj, 'roi_ds')
                    rois = imgobj.roi_ds;
                else
                    rois = imgobj.roi_dir_sel;
                end
                
            case 1 %for orientation selective
                n = 9;
                h_list = linspace(0, 1, n);
                angle_list = linspace(-pi/2, pi/2, n);
                L = imgobj.L_ori;
                Ang = imgobj.Ang_ori;
                
                if isfield(imgobj, 'roi_os')
                    rois = imgobj.roi_os;
                else
                    rois = imgobj.roi_ori_sel;
                end
                
            case 2 %for non-selective cell
                rois_n = imgobj.roi_non_sel;
                
        end
        
        [RGB] = set_col(type);
        
        show_map(type, RGB);
        %%%%%%%%%%
        
        %%
        function [RGB] = set_col(type)
            switch type
                % direction
                case 0 %{0, 1}
                    RGB = [];
                    if ~isempty(rois)
                        
                        for i2 = rois
                            %set HSV
                            ang1 = find(angle_list > Ang(i2), 1, 'first');
                            ang2 = find(angle_list <= Ang(i2), 1, 'last');
                            if abs(Ang(i2) - angle_list(ang1)) < abs(Ang(i2) - angle_list(ang2))
                                ang = ang1;
                            else
                                ang = ang2;
                            end
                            
                            h = h_list(ang);
                            
                            L(i2) = L(i2)*1.5;
                            if L(i2) > 1, v = 1; else, v = L(i2)  ; end
                            
                            HSV_roi = [h, 1, v];
                            RGB = hsv2rgb(HSV_roi);
                            
                            imgBG(imgobj.Mask_rois(:,i2),1) = RGB(1);
                            imgBG(imgobj.Mask_rois(:,i2),2) = RGB(2);
                            imgBG(imgobj.Mask_rois(:,i2),3) = RGB(3);
                        end
                    end
                    
                case 1 %Orentation shown in bar form
                    RGB =  zeros(length(rois), 3);
                    if ~isempty(rois)
                        for i2 = rois
                            %set HSV
                            ang1 = find(angle_list > Ang(i2), 1, 'first');
                            ang2 = find(angle_list <= Ang(i2), 1, 'last');
                            
                            if abs(Ang(i2) - angle_list(ang1)) <...
                                    abs(Ang(i2) - angle_list(ang2))
                                
                                ang = ang1;
                            else
                                ang = ang2;
                            end
                            
                            h = h_list(ang);
                            L(i2) = L(i2) * 1.5;
                            if L(i2) > 1, v = 1; else, v = L(i2); end
                            
                            HSV_roi = [h, 1, v];
                            RGB(rois == i2, :) = hsv2rgb(HSV_roi);
                            
                        end
                        
                    end
                    % non-selective map
                case 2
                    RGB=[];
                    if ~isempty(rois_n)
                        for i2 = rois_n
                            if ismember(i2, imgobj.roi_nega_R)
                                % negative response
                                imgBG(imgobj.Mask_rois(:,i2),1) =  1;%imgobj.R_max(i2);
                                imgBG(imgobj.Mask_rois(:,i2),2) =  0;
                                imgBG(imgobj.Mask_rois(:,i2),3) =  1;
                                
                            elseif ismember(i2, imgobj.roi_pos_R)
                                % non-selective positive response
                                imgBG(imgobj.Mask_rois(:,i2),1) =  0.4;%imgobj.R_max(i2);
                                imgBG(imgobj.Mask_rois(:,i2),2) =  1;
                                imgBG(imgobj.Mask_rois(:,i2),3) =  0.6;
                                
                            end
                        end
                    end
            end
        end
        
        %%
        function show_map(type, RGB)
            switch type
                case 0
                    imgBG = reshape(imgBG,[img_sz, img_sz, 3]);
                    figure
                    imshow(imgBG)
                    hold on
                    % vector map
                    [U, V] = pol2cart(Ang, L);
                    quiver(imgobj.centroid(1,rois), imgobj.centroid(2,rois), U(rois)*50, -V(rois)*50,...
                        'AutoScale', 'off', 'Color', 'w')
                    axis ij
                    axis([0, img_sz, 0, img_sz])
                    hold off
                    
                    colormap(hsv(n));
                    
                case 1
                    imgBG = zeros(img_sz, img_sz);
                    figure
                    imshow(imgBG)
                    hold on
                    for i2 = rois
                        Put_template_bar(i2, imgobj.centroid, RGB(rois==i2, :), Ang);
                    end
                    hold off
                    
                case 2
                    
                    imgBG = reshape(imgBG,[img_sz, img_sz, 3]);
                    figure
                    imshow(imgBG)
            end
        end
        
        %% end of map_angler
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
        h_list = linspace(0, 0.9, div);
        %blightness value -> along row (=horizontal position)
        v_list = linspace(0.4, 1, div);
        
        %stim position
        
        H = repmat(h_list', 1, div);
        V = repmat(v_list, div, 1);
        for n1 = 1:div
            for n2 = 1:div
                RGB_stim(n1, n2, :) = hsv2rgb([H(n1, n2), 1, V(n1, n2)]);
            end
        end
        
        figure
        imagesc(RGB_stim)
        
        %roiごとに best position を出す．
        %best positionごとに，hue と value を与えて
        %roiを色付けする
        [val, ind] = max(max(imgobj.dFF_s_ave,[],1));
        
        for i2 = 1:imgobj.maxROIs
            %h(=hue) for vertical position
            %h = h_list(ceil(ind(:,:,i2)/div));
            h = H(ind(:,:,i2));
            
            %v(=blightness value) for horizontal position
            %v_res = rem(ind(:,:,i2), div);
            v_res = V(ind(:,:,i2));
            
            if val <= 0.15
                %no res cell is not colorized (blightness = 0)
                v = 0;
            else
                v = v_res;
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
    end


%% %%%%%%%%%%%%%%%%%%%% %%
    function map_nxn_use_fitdata
        
        color_div = 100;
        %hue -> along column (vertical position)
        h_list = linspace(0, 0.9, color_div);
        %blightness
        v_list = linspace(0.4, 1, color_div);
        
        %stim position
        RGB_stim = zeros(color_div, color_div, 3);
        H = repmat(h_list', 1, color_div);
        V = repmat(v_list, color_div, 1);
        
        for n1 = 1:color_div
            for n2 = 1:color_div
                RGB_stim(n1, n2, :) = hsv2rgb([H(n1, n2), 1, V(n1, n2)]);
            end
        end
        
        figure,
        imagesc(RGB_stim);
        
        % Fit した center (x, y) を hue と value に当てはめる
        % Fit params するときの -3 ~ 13 の範囲で 中心を評価するのでその補正
        pos_x = (imgobj.b_GaRot2D(:,2) + 3)/16;
        pos_y = (imgobj.b_GaRot2D(:,4) + 3)/16;
        
        
        for n = 1:imgobj.maxROIs
            
            %h for verticak position
            i_h = knnsearch(h_list', pos_y(n));
            h = h_list(i_h);
            %v for horizontal position
            i_v = knnsearch(v_list', pos_x(n));
            v = v_list(i_v);
            
            if ismember(n, imgobj.roi_no_res)...
                    || imgobj.b_GaRot2D(n,1) < 0.15
                v = 0;
            end
            
            HSV_roi = [h, 1, v];
            RGB = hsv2rgb(HSV_roi);
            imgBG(imgobj.Mask_rois(:,n), 1) = RGB(1);
            imgBG(imgobj.Mask_rois(:,n), 2) = RGB(2);
            imgBG(imgobj.Mask_rois(:,n), 3) = RGB(3);
        end
        imgBG = reshape(imgBG, [img_sz, img_sz, 3]);
        
        %plot
        figure
        imshow(imgBG)
        axis ij
        axis([0, 320, 0, 320])
        
    end

end %End of Col_ROIs