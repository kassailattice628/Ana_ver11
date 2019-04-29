function Plot_Tuning_Distributions(~, ~)
%%%%%
%
% sumarized the stimulus dependent tuning properties
%
%%%%%

global sobj
global imgobj

%% colorize ROIs
Col_ROIs;

%% histogram of tuning properties
switch sobj.pattern
    case 'MoveBar'
        %nbins = 24;
        %roi = imgobj.roi_res;
        
        r_o = imgobj.roi_ori_sel;
        r_d = imgobj.roi_dir_sel;
        
        %
        figure
        subplot(2, 3, 1)
        dot_plot(imgobj.L_ori(r_o));
        
        subplot(2, 3, 2)
        histo_plot(imgobj.Ang_ori(r_o), 1);
        
        
        subplot(2, 3, 3)
        plot(imgobj.Ang_ori(r_o), imgobj.L_ori(r_o), 'bo')
        title('Angle-ori vs L-ori')
        xlim([-pi/2, pi/2])
        
        
        
        subplot(2, 3, 4)
        dot_plot(imgobj.L_dir(r_d));
        
        subplot(2, 3, 5)
        histo_plot(imgobj.Ang_dir(r_d), 0);
        
        subplot(2, 3, 6)
        plot(imgobj.Ang_dir(r_d), imgobj.L_dir(r_d), 'bo')
        title('Angle-dir vs L-dir')
        xlim([0, 2*pi])
        
end


%% mean plot
    function dot_plot(d)
        me_dir =  mean(d);
        std_dir = std(d);
        
        plot(1, d, 'b.')
        hold on
        errorbar(1.1, me_dir, std_dir, 'o')
        xlim([0, 2])
        
    end
%% histogram plot
    function histo_plot(d, opt)
        if opt == 0 %direction
            bins = 0: pi/12 : 2*pi;
            ticks = [0, pi/2, pi, 3*pi/2, 2*pi];
            labels = {'0', 'pi/2', 'pi', '3pi/2', '2pi'};
            lims = [0, 51/24*pi];
            txt = 'Direction';
            
        elseif opt == 1 %Orientation
            bins = -pi/2 : pi/24 : pi/2;
            ticks = [-pi/2, 0, pi/2];
            labels = {'-pi/2', '0', 'pi/2'};
            lims = [-pi/2, pi/2];
            txt = 'Orientation';
        end
        
        h_dir = histogram(d);
        h_dir.BinEdges = bins;
        
        xlim(lims)
        xticks(ticks);
        xticklabels(labels)
        title(txt);
    end


%%
end