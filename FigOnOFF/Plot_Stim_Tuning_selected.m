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
            
            % Raw plot
            figure
            plot(stim_list, R_all_dir, 'o-')
            xlim([stim_list(1) - 0.1, stim_list(end) + 0.1])
            ylim([0, max(R_all_dir)*1.1])
            title(['ROI=#', num2str(i)])
            set(gca, 'xtick', stim_list,...
                'xticklabel', stim_txt)
            
            % Fit tuning curve to double gaussian
            [x, x_me, y, y_me, F, params] = fit_DS_OS_tuning(i, dir);
            
            figure
            scatter(x, y, 'b*') %original data
            xlim([-pi, pi])
            ylim([0, max(y)*1.1])
            hold on
            scatter(x_me, y_me, 'ro'); %mean plot
            xp = -pi:0.01:pi;
            plot(xp, F(params, xp)); %fitted func
            
            % Direction, Orientation selectivity
            figure
            polar([dir, dir(1)], [R_all_dir, R_all_dir(1)], 'o-');
            hold on
            polar([0, imgobj.Ang_dir(i)], [0, imgobj.L_dir(i)], 'r-')
            polar([0, imgobj.Ang_ori(i)], [0, imgobj.L_ori(i)], 'b-')
            title('Move Direction (red) and Bar Orientation (blue)')
            
            %%%%%%%%%%
            disp(['1 - CirVal_ori = ', num2str(imgobj.L_ori(i))]);
            disp(['1 - CirVal_dir = ', num2str(imgobj.L_dir(i))]);
        end
end

%%
end