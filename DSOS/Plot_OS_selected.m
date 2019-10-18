function Plot_OS_selected
%%%%%%%%%% %%%%%%%%%%

global imgobj

%%%%%%%%%% %%%%%%%%%%

if ~isfield(imgobj, 'P_boot')
    errordlg('Get boot OS first!')
    
else
    
    %angles = imgobj.orientations;
    angles = 0:imgobj.orientations(2):pi - imgobj.orientations(2); 
    for i = imgobj.selectROI
        %Colore is set acoording to the tuning properties.
        if ismember(i, imgobj.roi_no_res)
            Plot_OS([],[], angles, imgobj.dFF_boot_med(:,i)', i, [])
            
        elseif ismember(i, imgobj.roi_nega_R)
            Plot_OS([],[], angles, imgobj.dFF_boot_med(:,i)', i, [])
            
        else
            
            if ismember(i, imgobj.roi_os)
                disp('OS')
                %f_vM = Select_vonMises(imgobj.f_os(i));
                f_vM = @(b, x) b(1) * exp(b(2) * cos(2*(x - b(3)))) + b(4);
                b_fit = imgobj.b_os(i,:);
                
                Plot_OS(f_vM, b_fit, angles, imgobj.dFF_boot_med(:,i)', i, 2)
            end
            
            is_nonsel = ismember(i, imgobj.roi_res) && ~ismember(i, imgobj.roi_os');
            if is_nonsel
                
                Plot_OS([],[], angles, imgobj.dFF_boot_med(:,i)', i, [])
            end
            
        end
        
    end
end
end

function Plot_OS(f_vM, b_fit, d_vec, R_boot_med, roin, type)
global imgobj

%remove NaN
x = []; y = [];

for j = 1:length(d_vec)
   for i = 1:size(imgobj.dFF_s_each(:, j, roin), 1)
       y_ = imgobj.dFF_s_each(i, j, roin);
       if ~isnan(y_)
           x = [x, d_vec(j)];
           y = [y, y_];
       end
   end
end

%%%%%%%%%%
plot_fit = 0;
if isempty(type)
    if ismember(roin, imgobj.roi_no_res)
        %txt2 = 'No Responding';
        color = 'k';
        plot_fit = 0;
    elseif ismember(roin, imgobj.roi_nega_R)
        %txt2 = 'Negative Response';
        color = 'r';
        plot_fit = 0;
        
    else
        color = 'm';
        %txt2 = 'Non selective';
        plot_fit = 0;
    end
    
elseif type == 2
    color = 'g';
    %txt2 = 'Polar Distribution (OS)';
    plot_fit = 1;
end

%%%%%%%%%%
xp = 0:0.005:pi;
figure
hold on

%Raw data
plot(x, y, [color, '.']);

%Medain of bootstrapped mean 
plot(d_vec, R_boot_med, [color, 'o'], 'MarkerSize', 7)
%fit
if plot_fit == 1
    plot(xp, f_vM(b_fit, xp), [color, '-'], 'LineWidth', 2)
end

xlim([-0.1, pi+0.1])
ylim([0, 1.1*max(y)])
title(['ROI# = ', num2str(roin)])
set(gca, 'xtick', [0, pi/6, pi/3 pi/2 2*pi/3, 5*pi/6, pi],...
    'xticklabel', {'0', '\pi/6', '\pi/3', '\pi/2', '2\pi/3', '5\pi/6', 'pi'})
xlabel('Bar Orientation (deg)');
end
