function Plot_Stim_Tuning_selected(~, ~)

%%%%%%%%%%
global imgobj
global sobj

%%%%%%%%%%
stim_list = 1:size(imgobj.dFF_s_ave, 2);


%%
switch sobj.pattern
    case 'Size_rand'
        %%%%%%%%%%
        if length(stim_list) == 5
            set(gca, 'xticklabel', {'0.5deg', '1deg', '3deg', '5deg', '10deg'});
        elseif length(stim_list) ==  6
            set(gca, 'xticklabel', {'0.5deg', '1deg', '3deg', '5deg', '10deg', '20deg'});
        elseif length(stim_list) == 7
            set(gca, 'xticklabel', {'0.5deg', '1deg', '3deg', '5deg', '10deg', '30deg', '50deg'});
        end
        %%%%%%%%%%
        
        for i = imgobj.selectROI
            figure
            plot(stim_list, imgobj.R_size(:, i, 1), 'go-')
            hold on
            plot(stim_list, imgobj.R_size(:, i, 2), 'ror')
            set(gca, 'xtick', stim_list)
        end
        
        
    case {'Sin', 'Rect', 'Gabor', 'MoveBar'}
        %%%%%%%%%%
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
        %%%%%%%%%%
        dir = linspace(0, (2*pi - 2*pi/size(imgobj.dFF_s_each, 2)), size(imgobj.dFF_s_each, 2));
        
        for i = imgobj.selectROI
            R_all_dir = nanmean(imgobj.dFF_s_each(:, :, i));
            
            % Fit tuning curve to double gaussian
            [x, x_me, y, y_me, F, params] = fit_DS_tuning(i, dir);
            
            xp = 0:0.01:2*pi;
            F_fit = F(params, xp);
            size(F_fit)
            
            if ismember(i, imgobj.roi_non_sel) && ismember(i, imgobj.roi_nega_R)
                %negative response
                R_all_dir = -R_all_dir;
                F_fit = -F_fit;
                y = -y;
                y_me = -y_me;
                color = 'r';
                ylim_p1 = [min(R_all_dir)*1.1, 0];
                ylim_p2 = [min(y)*1.1, 0];
                    
            elseif ismember(i, imgobj.roi_pos_R)
                %positive response
                color = 'b';
                ylim_p1 = [0, max(R_all_dir)*1.1] ;
                ylim_p2 = [0, max(y)*1.1];
                
            else
                
                color = 'g';
                ylim_p1 = [0, max(R_all_dir)*1.1] ;
                ylim_p2 = [0, max(y)*1.1];
            end
            %%
            % Raw plot
            figure
            subplot(2,2,1)
            plot(stim_list, R_all_dir, [color, 'o-'])
            xlim([stim_list(1) - 0.1, stim_list(end) + 0.1])
            ylim(ylim_p1)
            title(['ROI=#', num2str(i)])
            set(gca, 'xtick', stim_list,...
                'xticklabel', stim_txt)
            
            % Selectivity
            subplot(2,2,3)
            scatter(x, y, [color, '*']) %original data
            xlim([0, 2*pi])
            ylim(ylim_p2)
            hold on
            scatter(x_me, y_me, 'mo'); %mean plot
            plot(xp, F_fit, 'LineWidth', 2); %fitted func
            title('Dboule Gaussian Fit');
            xlabel('Centered at Pref. Direction or Orientation')
            set(gca, 'xtick', [0, pi/2, pi, 3*pi/2, 2*pi],...
                'xticklabel', {'-pi/2', '0', 'pi/2', 'pi', '3pi/2'})
            
            % Direction, Orientation selectivity
            %figure
            subplot(2,2,[2,4])
            polar([dir, dir(1)], abs([R_all_dir, R_all_dir(1)]), [color, 'o-']);
            hold on
            polar([0, imgobj.Ang_dir(i)], [0, imgobj.L_dir(i)], 'r-')
            polar([0, imgobj.Ang_ori(i)], [0, imgobj.L_ori(i)], 'b-')
            title('DS (red) and OS (blue)')
            
            
            %%
            %%%%%%%%%% index info 
            disp(['1 - CirVal_ori = ', num2str(imgobj.L_ori(i))]);
            disp(['1 - CirVal_dir = ', num2str(imgobj.L_dir(i))]);
        end
end

%%
end