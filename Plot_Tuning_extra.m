function Plot_Tuning_extra(imgobj, comp)

stim_list = 1:size(imgobj.dFF_s_ave, 2);

if ismember(imgobj.selectROI, comp.roi_ds2)
    f_vM = @(b, x) b(1) * exp(b(2) * cos(x - b(5))) .*...
        exp(b(3) * cos(2*x - 2*(b(5)+b(6)))) + b(4);
    %
elseif ismember(imgobj.selectROI, comp.roi_os2)
    f_vM = @(b, x) b(1) * exp(b(2) * cos(x - b(5))) .*...
        exp(b(3) * cos(2*x - 2*(b(5)+pi))) + b(4);
        %}
end

%%
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
d_vec = linspace(0, (2*pi - 2*pi/size(imgobj.dFF_s_each, 2)), size(imgobj.dFF_s_each, 2));

i = 125;

R_all_dir = nanmean(imgobj.dFF_s_each(:, :, i));

xp = 0:0.01:2*pi;
F_fit = f_vM(comp.b_os2(i,:), xp);

if ismember(i, imgobj.roi_no_res)

else
    %posotive cells
    ylim_p1 = [0, max(R_all_dir)*1.1];
    
    if ismember(i, imgobj.roi_dir_sel)
        color = 'b';
        
    elseif ismember(i, imgobj.roi_ori_sel)
        color = 'g';
        
    else
        %non selective
        color = 'm';
    end
end
%%
% Raw plot
figure
subplot(1,2,1)
plot(d_vec, R_all_dir, [color, 'o-'])
ylim(ylim_p1)
title(['ROI=#', num2str(i)])
set(gca, 'xtick', stim_list,...
    'xticklabel', stim_txt)

hold on
plot(xp, F_fit, 'LineWidth', 2); %fitted func
title('vonMisesd Fit');
xlabel('Centered at Pref. Direction or Orientation')
set(gca, 'xtick', [0, pi/2, pi, 3*pi/2, 2*pi])

% Direction, Orientation selectivity
%figure
subplot(2,2,[2,4])
polar([d_vec, d_vec(1)], abs([R_all_dir, R_all_dir(1)]), [color, 'o-']);
hold on
polar([0, imgobj.Ang_dir(i)], [0, imgobj.L_dir(i)], 'r-')
polar([0, imgobj.Ang_ori(i)], [0, imgobj.L_ori(i)], 'b-')
title('DS (red) and OS (blue)')

%%
%%%%%%%%%% index info
disp(['1 - CirVal_ori = ', num2str(imgobj.L_ori(i))]);
disp(['1 - CirVal_dir = ', num2str(imgobj.L_dir(i))]);



%%
end