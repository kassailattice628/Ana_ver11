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
        
        figure
        subplot(2, 2, 1)
        dot_plot(imgobj.L_dir);
        
        subplot(2, 2, 2)
        histo_plot(imgobj.Ang_dir, 0);
        
        subplot(2, 2, 3)
        dot_plot(imgobj.L_ori);
        
        subplot(2, 2, 4)
        histo_plot(imgobj.Ang_ori, 1);
end


%% mean plot
    function dot_plot(d)
        me_dir =  mean(d);
        std_dir = std(d);
        
        plot(1, d, 'b.')
        hold on
        errorbar(1.1, me_dir, std_dir, 'o')
    end
%% histogram plot
    function histo_plot(d, opt)
        if opt == 0 %direction
            bins = 0:pi/12:2*pi;
            ticks = [0, pi/2, pi, 3*pi/2, 2*pi];
            labels = {'0', 'pi/2', 'pi', '3pi/2', '2pi'};
            lims = [0, 51/24*pi];
        elseif opt == 1
            bins = -pi/2 : pi/24 : pi/2;
            ticks = [-pi/2, 0, pi/2];
            labels = {'-pi/2', '0', 'pi/2'};
            lims = [-12/24*pi, 12/24*pi];
        end
        
        h_dir = histogram(d);
        h_dir.BinEdges = bins;
        
        xlim(lims)
        xticks(ticks);
        xticklabels(labels)
    end


%%
end