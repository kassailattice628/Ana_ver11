function Plot_Stim_Tuning(~,~, s)
% get stimulus specific tuning properties

%%%%%%%%%%
global imgobj

%%%%%%%%%%

%stim
stim_list = 1:size(imgobj.dFF_s_ave, 2);

%point
prep = ceil(1/imgobj.FVsampt);
p_on = prep + 1;

%%%%%%%%%%
switch s.pattern
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'Size_rand'
        p_duration = round(s.duration/imgobj.FVsampt);
        p_off = prep + 1 + p_duration;
        
        %best size (on & off)
        imgobj.R_size = zeros(length(stim_list), imgobj.maxROIs, 3);
        for k = 1:imgobj.maxROIs
            base = mean(imgobj.dFF_s_ave(1:2, :, k)); % dFF_s_ave(points, stim, ROI)
            
            imgobj.R_size(:, k, 1) = max(imgobj.dFF_s_ave(p_on:p_on+p_duration, :, k) - base)';
            imgobj.R_size(:, k, 2) = max(imgobj.dFF_s_ave(p_off:p_off+p_duration, :, k) - base)';
            imgobj.R_size(:, k, 3) = max(imgobj.dFF_s_ave(p_on:p_off+p_duration, :, k) - base)';
        end
        
        for k = imgobj.selectROI
            figure
            plot(stim_list, imgobj.R_size(:, k, 1), 'o-g')
            hold on
            plot(stim_list, imgobj.R_size(:, k, 2), 'o-r')
            
            %{
            %each trial
            for k2 = stim_list
                for k3 = 1:10
                    if ~isnan(imgobj.dFF_s_each(k3, k2, k))
                        plot(k2, imgobj.dFF_s_each(k3, k2, k), 'og')
                    end
                end
            end
            %}
            
            hold off
            title(['ROI=#', num2str(k)])
            set(gca, 'xtick', stim_list);
            if length(stim_list) == 5
                set(gca, 'xticklabel', {'0.5deg', '1deg', '3deg', '5deg', '10deg'});
            elseif length(stim_list) ==  6
                set(gca, 'xticklabel', {'0.5deg', '1deg', '3deg', '5deg', '10deg', '20deg'});
            elseif length(stim_list) == 7
                set(gca, 'xticklabel', {'0.5deg', '1deg', '3deg', '5deg', '10deg', '30deg', '50deg'});
            end
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {'Sin', 'Rect', 'Gabor', 'MoveBar'}
        if length(stim_list) == 8
            stim_txt = {'0:2pi', '1/4', '1/2', '3/4', 'pi', '5/4', '3/2', '7/4'};
        elseif length(stim_list) == 7 %irregular
            stim_txt = {'0:2pi', '1/4', '1/2', '3/4', 'pi', '5/4', '3/2'};
        elseif length(stim_list) == 12
            stim_txt = {'0:2pi', '1/6', '1/3', '1/2', '2/3', '5/6', 'pi',...
                '7/6', '4/3', '3/2', '5/3', '11/6'};
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
        
        %distribution of dir selectivity
        imgobj.L_ori = zeros(1, imgobj.maxROIs);
        imgobj.L_dir = zeros(1, imgobj.maxROIs);
        
        for k = 1:imgobj.maxROIs
            
            %% Orientation / Direction selectivity by vector averaging%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %calc circular variance
            base = imgobj.dFF_s_ave(1, :, k); % dFF_s_ave(points, stim, ROI)
            
            R_all_dir_max = max(imgobj.dFF_s_ave(p_on:p_on+p_duration, :, k)) - base;
            R_all_dir_min = min(imgobj.dFF_s_ave(p_on:p_on+p_duration, :, k)) - base;
                        
            dir = linspace(0, (2*pi - 2*pi/length(R_all_dir_max)), length(R_all_dir_max));
            
            %negative Ca responses are extracted
            %!!!!! how to treat rebound excitation !!!!!
            if max(abs(R_all_dir_max)) >= max(abs(R_all_dir_min))
                R_all_dir = R_all_dir_max;
                R_all_dir(R_all_dir < 0) = 0;
                line_prop = 'o-b';
            else
                R_all_dir = -R_all_dir_min;
                line_prop = 'o-r';
            end
            
            % orientation
            Z = sum(R_all_dir .* exp(2*1i*dir))/sum(R_all_dir);
            imgobj.L_ori(k) = abs(Z);
            
            % orientation selectivity-degree
            imgobj.Ang_ori(k) = angle(Z)/2 +pi/2;
            
            % direction
            Z = sum(R_all_dir .* exp(1i*dir))/sum(R_all_dir);
            imgobj.L_dir(k) = abs(Z);
            
            % direction selectivity-degree
            angle_Z = angle(Z);
            if angle_Z < 0
                angle_Z = angle_Z + 2*pi;
            end
            imgobj.Ang_dir(k) = angle_Z;
            
            %% plot direction, orientation
            if ismember(k, imgobj.selectROI)
                
                %tuning direction
                figure
                plot(stim_list, R_all_dir, line_prop)
                title(['ROI=#', num2str(k)])
                set(gca, 'xtick', stim_list);
                set(gca, 'xticklabel', stim_txt);
                
                %fit tuning and plot
                fit_DS_OS_tuning(k, dir);
                
                %direction, orientation selectivity
                figure
                subplot(1,2,1)
                polar([dir, dir(1)], [R_all_dir, R_all_dir(1)], line_prop)
                hold on
                polar([0, imgobj.Ang_dir(k)], [0, imgobj.L_dir(k)], 'r-');
                hold off
                title('Move Direction')
                
                subplot(1,2,2)
                polar([0, imgobj.Ang_ori(k)], [0, imgobj.L_ori(k)], 'r-');
                title('Bar Orientation')
                
                disp(['1 - CirVal_ori = ', num2str(imgobj.L_ori(k))])
                disp(['1 - CirVal_dir = ', num2str(imgobj.L_dir(k))])
            end
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {'Images'}
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherwise
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% size tuning plot

