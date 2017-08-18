function Plot_Stim_Tuning(~,~, s)
%calc stim
global imgobj

%%%%%%%%%%

%stim
stim_list = 1:size(imgobj.dFF_s_ave, 2);

%point
prep = ceil(1/imgobj.FVsampt);
p_on = prep + 1;

switch s.pattern
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'Size_rand'
        
        p_duration = round(s.duration/imgobj.FVsampt);
        p_off = prep + 1 + p_duration;
        
        %best size (on & off)
        imgobj.R_size = zeros(5, imgobj.maxROIs, 2);
        for k = 1:imgobj.maxROIs
            imgobj.R_size(:, k, 1)  = max(imgobj.dFF_s_ave(p_on:p_on+p_duration, :, k))';
            imgobj.R_size(:, k, 2) = max(imgobj.dFF_s_ave(p_off:p_off+p_duration, :, k))';
            
        end
        
        for k = imgobj.selectROI
            figure
            plot(stim_list, imgobj.R_size(:, k, 1), 'o-g')
            hold on
            plot(stim_list, imgobj.R_size(:, k, 2), 'o-r')
            hold off
            title(['ROI=#', num2str(k)])
            set(gca, 'xtick', stim_list);
            set(gca, 'xticklabel', {'0.5deg', '1deg', '3deg', '5deg', '10deg'});
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {'Sin', 'Rect', 'Gabor', 'MoveBar'}
        on_mat = zeros(length(stim_list), length(imgobj.selectROI));
        
        if length(stim_list) == 8
            stim_txt = {'0:2pi', '1/4', '1/2', '3/4', 'pi', '5/4', '3/2', '7/4'};
        elseif length(stim_list) == 7 %irregular
            stim_txt = {'0:2pi', '1/4', '1/2', '3/4', 'pi', '5/4', '3/2'};
        elseif length(stim_list) == 16
            stim_txt = {'0:2pi', '1/8', '1/4', '3/8', '1/2', '5/8', '3/4', '7/8',...
                'pi', '9/8', '5/4', '11/8', '3/2', '13/8', '7/4', '15/8'};
        end
        %
        
        if strcmp(s.pattern, 'MoveBar')
            p_duration = round(s.moveDuration/imgobj.FVsampt);
        else
            p_duration = round(s.duration/imgobj.FVsampt);
        end
        
        %
        for k = 1:length(imgobj.selectROI)
            on_mat(:,k) = max(imgobj.dFF_s_ave(p_on:p_on+p_duration, :, imgobj.selectROI(k)))';
            figure
            plot(stim_list, on_mat(:,k), 'o-b')
            title(['ROI=#', num2str(imgobj.selectROI(k))])
            set(gca, 'xtick', stim_list);
            set(gca, 'xticklabel', stim_txt);
        end
        
        %distribution of dir selectivity
        imgobj.dir_sel_rois = zeros(3, imgobj.maxROIs);
        imgobj.L_ori = zeros(1, imgobj.maxROIs);
        imgobj.L_dir = zeros(1, imgobj.maxROIs);
        %imgobj.Z = zeros(1, imgobj.maxROIs);
        for k = 1:imgobj.maxROIs
            %% Orientation / Direction selectivity index%%%%%%%%%%%%%%%%%%%
            %{
            % orientation/direction selectivity index
            [R_pref_ori, pref_ori] = max(max(imgobj.dFF_s_ave(p_on:p_on+p_duration, :, k)));
            imgobj.dir_sel_rois(1,k) = pref_ori;
            
            %%%%%
            ortho_ori1 = pref_ori + size(imgobj.dFF_s_ave,2)/4;
            if ortho_ori1 > size(imgobj.dFF_s_ave,2)
                ortho_ori1 = ortho_ori1 - size(imgobj.dFF_s_ave,2);
            end
            
            ortho_ori2 = pref_ori - size(imgobj.dFF_s_ave,2)/4;
            if ortho_ori2 < 1
                ortho_ori2 = size(imgobj.dFF_s_ave,2) + ortho_ori2;
            end
            
            R_ortho_ori1 = max(imgobj.dFF_s_ave(p_on:p_on+p_duration, ortho_ori1, k));
            
            R_ortho_ori2 = max(imgobj.dFF_s_ave(p_on:p_on+p_duration, ortho_ori2, k));
            
            %%%%%%
            null_dir = pref_ori + 4;
            if null_dir > size(imgobj.dFF_s_ave,2)
                null_dir = null_dir - size(imgobj.dFF_s_ave,2);
            end
            R_null_dir = max(imgobj.dFF_s_ave(p_on:p_on+p_duration, null_dir, k));
            
            %%%%%%%%%%
            %OI
            imgobj.dir_sel_rois(2, k) = (R_pref_ori + R_null_dir - (R_ortho_ori1 + R_ortho_ori2)) / (R_pref_ori + R_null_dir);
            
            %dI
            imgobj.dir_sel_rois(3,k) = (R_pref_ori - R_null_dir)/R_pref_ori;
            %}
            
            %% vector averaging%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %calc circular variance
            base = imgobj.dFF_s_ave(1, :, k);
            R_all_dir = max(imgobj.dFF_s_ave(p_on:p_on+p_duration, :, k)) - base;
            if length(R_all_dir) == 8
                dir = linspace(0, 2*pi-pi/4, 8);
            elseif length(R_all_dir) == 7
                dir = linspace(0, 2*pi-pi/2, 7);
            elseif length(R_all_dir) == 16
                dir = linspace(0, 2*pi-pi/8, 16);
            end
            
            % orientation
            Z = sum(R_all_dir .* exp(2*1i*dir))/sum(R_all_dir);
            imgobj.L_ori(k) = abs(Z);
            
            % orientation selectivity-degree
            imgobj.Ang_ori(k) = angle(Z)/2;
            
            
            % direction
            Z = sum(R_all_dir .* exp(1i*dir))/sum(R_all_dir);
            imgobj.L_dir(k) = abs(Z);
            
            % direction selectivity-degree
            angle_Z = angle(Z);
            if angle_Z < 0
                angle_Z = angle_Z + 2*pi;
            end
            imgobj.Ang_dir(k) = angle_Z;
            
            %% plot direction
            if ismember(k, imgobj.selectROI)
                figure
                subplot(1,2,1)
                polar([dir, dir(1)], [R_all_dir, R_all_dir(1)], 'o-b')
                hold on
                polar([0, imgobj.Ang_dir(k)], [0, imgobj.L_dir(k)], 'r-');
                hold off
                title('Move direction')
                
                subplot(1,2,2)
                polar([0, imgobj.Ang_ori(k)+pi/2], [0, imgobj.L_ori(k)], 'r-');
                title('Orientation')
                
                disp(['1 - CirVal_ori = ', num2str(imgobj.L_ori(k))])
                disp(['1 - CirVal_dir = ', num2str(imgobj.L_dir(k))])
            end
        end
        
    case {'Images'}
        
    otherwise
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% size tuning plot

