function Get_Fit_params(~, ~)
%%%%%%%%%%
%
% get tuning parameters for "selective" neurons
%
%%%%%%%%%%

global imgobj
global sobj

%%
if ~isfield(imgobj, 'L_dir')
    errordlg('Get Trial Averages!')
end

%%
switch sobj.pattern
    case {'MoveBar', 'Rect'}
        d = size(imgobj.dFF_s_each,2);
        dir = linspace(0, (2*pi - 2*pi/d), d);
        F = @(b, x) b(1)*exp((-(x-(pi/2)).^2)/(2*b(2)^2)) +...
            b(3)*exp((-(x-b(4)-(pi/2)).^2 )/(2*b(5)^2)) + b(6);
        xp = -pi/2: 0.01: 5*pi/2;
        
        F_ori = @(b, x) b(1)*exp((-x.^2)/(2*b(2)^2)) + b(3);
        xp_ori = -pi:0.01:pi;
end

%%
if ~isfield(imgobj, 'tuning_params')
    switch sobj.pattern
        case {'MoveBar', 'Rect'}
            imgobj.tuning_params = zeros(6, imgobj.maxROIs);
            imgobj.tuning_params_ori = zeros(3, imgobj.maxROIs);
            imgobj.hmfw = zeros(1, length(imgobj.roi_dir_sel));
            imgobj.hmfw_ori = imgobj.hmfw;
            
            for k = imgobj.roi_res
                [~, ~, ~, ~, ~, imgobj.tuning_params(:, k)] = fit_DS_tuning(k, dir);
                
                if ismember(k, imgobj.roi_ori_sel)
                    [~, ~, ~, ~, ~, imgobj.tuning_params_ori(:, k)] = fit_OS_tuning(k, dir);
                end
                
            end
    end
end

Plot_fits;

%%
    function Plot_fits
        %% double gaussian plot orientation selectivity
        figure
        hold on
        %me_F_norm = zeros(1, length(xp));
        me_F_norm = zeros(length(xp), length(imgobj.roi_ori_sel));
        
        for i = imgobj.roi_ori_sel
            F_fit = F(imgobj.tuning_params(:,i), xp);
            F_norm = F_fit/max(F_fit);
            %me_F_norm = me_F_norm + F_norm;
            me_F_norm(:, imgobj.roi_ori_sel==i) = F_norm;
            plot(xp, F_norm)
        end
        
        %plot(xp, me_F_norm/length(imgobj.roi_ori_sel), 'k-', 'LineWidth', 2)

        plot(xp, mean(me_F_norm, 2), 'k-', 'LineWidth', 2)
        hold off
        
        xlabel('Orientation (centerd at Pref. Ori)')
        title('Orientation tuning --Double Gaussian--')
        set(gca, 'xtick', [-pi/2, 0, pi/2, pi, 3*pi/2, 2*pi],...
            'xticklabel', {'-pi', '-pi/2', '0', 'pi/2', 'pi', '3pi/2'})
        hold off
        
        %% single gaussian for orientation
        figure
        hold on
        me_F_norm = zeros(1, length(xp_ori));
        
        for i = imgobj.roi_ori_sel
            F_fit_ori = F_ori(imgobj.tuning_params_ori(:, i), xp_ori);
            
            % normalize
            F_norm = F_fit_ori/max(F_fit_ori);
            % HMFW
            hm = (1 - min(F_fit_ori))/2; %half maximum
            x1 = find(F_norm > hm, 1, 'first');
            x2 = find(F_norm > hm, 1, 'last');
            if isempty(x1)
                break
            end
            imgobj.hmfw_ori(i) = xp_ori(x2) - xp_ori(x1);
            
            me_F_norm = me_F_norm + F_norm;
            
            %single trace
            plot(xp_ori, F_norm)
        end
        plot(xp_ori, me_F_norm/length(imgobj.roi_ori_sel), 'k-', 'LineWidth', 2)
        
        xlabel('Orientation (centerd at Pref. Ori)')
        title('Orientation tuning --Single Gaussian--')
        set(gca, 'xtick', [-pi, -pi/2, 0, pi/2, pi],...
            'xticklabel', {'-pi', '-pi/2', '0', 'pi/2', 'pi'})
        hold off
        
        
        %% plot direction selectivity
        figure
        hold on
        me_F_norm = zeros(1, length(xp));
        for i = imgobj.roi_dir_sel
            F_fit = F(imgobj.tuning_params(:, i), xp);
            % normalize F_fit
            F_norm = F_fit/max(F_fit);
            % HMFW
            hm = (1 - min(F_fit))/2; %half maximum
            x1 = find(F_norm > hm, 1, 'first');
            x2 = find(F_norm > hm, 1, 'last');
            
            if isempty(x1)
                break
            end
            imgobj.hmfw(i) = xp(x2) - xp(x1);
            
            me_F_norm = me_F_norm + F_norm;
            
            plot(xp, F_norm)
        end
        plot(xp, me_F_norm/length(imgobj.roi_dir_sel), 'k-', 'LineWidth', 2)
        
        ylim([0, 1.1])
        xlabel('Direction (centerd at Pref. Dir)')
        ylabel('Normalized response')
        title('Normalized Fitted direction tuning')
        set(gca, 'xtick', [-pi/2, 0, pi/2, pi, 3*pi/2, 2*pi],...
            'xticklabel', {'-pi', '-pi/2', '0', 'pi/2', 'pi', '3pi/2'})
        
        %%
        % tuning widht (Half maximum full width)
        hmfw_me = mean(imgobj.hmfw(imgobj.hmfw > 0));
        hmfw_std = std(imgobj.hmfw(imgobj.hmfw > 0));
        
        hmfw_ori_me = mean(imgobj.hmfw_ori(imgobj.hmfw_ori > 0));
        hmfw_ori_std = std(imgobj.hmfw_ori(imgobj.hmfw_ori > 0));
        
        disp(['DS:: HMFW = ', num2str(hmfw_me), ' Å} ', num2str(hmfw_std), ' (rad)'])
        
        disp(['OS:: HMFW = ', num2str(hmfw_ori_me), ' Å} ', num2str(hmfw_ori_std), ' (rad)'])
    end
%%
end