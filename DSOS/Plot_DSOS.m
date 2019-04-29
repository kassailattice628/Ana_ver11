function Plot_DSOS(f_vM, b_fit, d_vec, R_boot_med, roin, type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot Bootstrapped data
% if the selected roi, defined in roin, have DS and/or OS
% vM fitted curve is superimposed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global imgobj

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%remove NaN from recorded data point
x = [];
y = [];
for j = 1:length(d_vec)
    for i = 1:size(imgobj.dFF_s_each(:, j, roin), 1)
        y_ = imgobj.dFF_s_each(i, j, roin);
        if ~isnan(y_)
            x = [x, d_vec(j)];
            y = [y, y_];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set color
plot_fit = 0;

if isempty(type)
    
    if ismember(roin, imgobj.roi_no_res)
        txt2 = 'No Responding';
        color = 'k';
        plot_fit = 0;
        
    elseif ismember(roin, imgobj.roi_nega_R)
        txt2 = 'Negative Response';
        color = 'r';
        plot_fit = 0;
        
    else
        color = 'm';
        txt2 = 'Non selective';
        plot_fit = 0;
    end
    
elseif type == 1
    color = 'b';
    txt2 = 'Polar Distribution (DS)';
    plot_fit = 1;
    
elseif type == 2
    color = 'g';
    txt2 = 'Polar Distribution (OS)';
    plot_fit = 1;
end


%%%%%%%%%%%%%%%%%%%%


xp = 0:0.01:2*pi;



figure

%Raw plot
subplot(1,2,1)
hold on
%data mean
plot(x, y, [color, '.']);
%bootstrapped median
plot(d_vec, R_boot_med, [color, 'o'], 'MarkerSize', 7)
%fit
if plot_fit == 1
    plot(xp, f_vM(b_fit, xp), [color, '-'], 'LineWidth', 2)
end

xlim([-0.1, 2*pi+0.1])
title(['ROI# = ', num2str(roin)])
set(gca, 'xtick', [0, pi/2, pi, 3*pi/2, 2*pi],...
    'xticklabel', {'0', 'pi/2', 'pi', '3pi/2', '2ƒÎ'})
xlabel('Move Angle (deg)');

%Polar plot
subplot(1,2,2)
polar([d_vec, d_vec(1)], [R_boot_med, R_boot_med(1)], [color, 'o-']);
hold on;
title(txt2)
