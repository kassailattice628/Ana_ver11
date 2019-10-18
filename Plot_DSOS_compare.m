function Plot_DSOS_compare(d1, d2, roin, types)
%”äŠr‚·‚é condition ‚Å•\Ž¦‚ð‘µ‚¦‚Ä DSOS properties ‚ð plot

for roi = roin
    
    [x1, y1] = set_dFF_s_each(d1, roi);
    [x2, y2] = set_dFF_s_each(d2, roi);
    
    %DS, OS, Nonselective, Ambiguos
    
    dir_vec = d1.imgobj.directions;
    R_boot_med1 =  d1.imgobj.dFF_boot_med(:, roi)';
    R_boot_med2 =  d2.imgobj.dFF_boot_med(:, roi)';
    
    %%
    figure,
    subplot(1,2,1)
    plot(x1, y1, '.')
    hold on
    plot(x2, y2, '.')
    %
    ax = gca;
    ax.ColorOrderIndex = 1;
    plot(dir_vec, R_boot_med1, 'o')
    plot(dir_vec, R_boot_med2, 'o')
    %
    ax.ColorOrderIndex = 1;
    
    if length(types) == 2
        type = types;
    elseif length(types) == 1
        type = [types, types];
    end
    
    plot_FR(d1, roi, type(1))
    plot_FR(d2, roi, type(2))
    %{
    if type == 1 %DS
        plot(d1.imgobj.FR_ds{roi}, 'predobs' );
        plot(d2.imgobj.FR_ds{roi}, 'predobs' );
    elseif type == 2 %OS
        plot(d1.imgobj.FR_os{roi}, 'predobs' );
        plot(d2.imgobj.FR_os{roi}, 'predobs' );
    end
    %}
    
    
    xlim([-0.1, 2*pi+0.1])
    ylim([0, max(max(R_boot_med1), max(R_boot_med2))*1.3])
    title(['ROI# = ', num2str(roi)])
    set(gca, 'xtick', [0, pi/2, pi, 3*pi/2, 2*pi],...
        'xticklabel', {'0', '\pi/2', '\pi', '3\pi/2', '2\pi'})
    xlabel('Move Angle (deg)');
    
    %%
    subplot(1,2,2)
    polarplot([dir_vec, dir_vec(1)], [R_boot_med1, R_boot_med1(1)], 'o-');
    hold on
    polarplot([dir_vec, dir_vec(1)], [R_boot_med2, R_boot_med2(1)], 'o-');
    
    
    pax = gca;
    pax.ThetaAxisUnits = 'radians';
    rlim([0, max(max(R_boot_med1), max(R_boot_med2))*1.3])
    title(['ROI# = ', num2str(roi)])
    
    
    %%  %%%%%%%%%%%%%%%
    figure,
    subplot(1,2,1)
    plot(x1, y1, '.')
    hold on
    plot(dir_vec, R_boot_med1, 'o')
    plot_FR(d1, roi, type(1))
    
    xlim([-0.1, 2*pi+0.1])
    ylim([0, max(max(R_boot_med1), max(R_boot_med2))*1.3])
    
    subplot(1,2,2)
    plot(x2, y2, '.')
    hold on
    plot(dir_vec, R_boot_med2, 'o')
    plot_FR(d2, roi, type(2))
    
    
    xlim([-0.1, 2*pi+0.1])
    ylim([0, max(max(R_boot_med1), max(R_boot_med2))*1.3])
    title(['ROI# = ', num2str(roi)])
    set(gca, 'xtick', [0, pi/2, pi, 3*pi/2, 2*pi],...
        'xticklabel', {'0', '\pi/2', '\pi', '3\pi/2', '2\pi'})
    xlabel('Move Angle (deg)');
    
end
end

%%
function [x, y] = set_dFF_s_each(d, roi)
x = [];
y = [];
for j = 1:length(d.imgobj.directions)
    for i = 1:size(d.imgobj.dFF_s_each(:, j, roi), 1)
        y_ = d.imgobj.dFF_s_each(i, j, roi);
        
        if ~isnan(y_)
            x = [x, d.imgobj.directions(j)];
            y = [y, y_];
        end
    end
end

end

%%
function plot_FR(d, roi, type)
    if type == 1 %DS
        plot(d.imgobj.FR_ds{roi}, 'predobs' );
    elseif type == 2 %OS
        plot(d.imgobj.FR_os{roi}, 'predobs' );
    end
end

