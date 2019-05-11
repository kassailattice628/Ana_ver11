function Plot_Selected_Averages(~, ~, cmin, cmax)
%%%%%%%%%%
% Plot trial averages for selected ROIs
%%%%%%%%%

global imgobj
global sobj

%%
if ~isfield(imgobj, 'dFF_s_ave')
    errordlg(' Get Trial Averages!!')
end

%%
cmin = str2double(get(cmin, 'string'));
cmax = str2double(get(cmax, 'string'));


datap = size(imgobj.dFF_s_ave, 1);
nstim = size(imgobj.dFF_s_ave, 2);
pret = 1;
prep = ceil(pret/imgobj.FVsampt);

nROI = length(imgobj.selectROI);

%%
% duration
switch sobj.pattern
    case {'MoveBar', 'Looming '}
        duration = max(sobj.moveDuration);
        
        if length(sobj.moveDuration) > 1
            A = 1:length(sobj.moveDuration);
            B = flip(A);
            C = repmat([A, B(2:end-1)], 1, 2);
        end
        
    otherwise
        sobj.moveDuration = 0;
        duration = sobj.duration;
end

%% show color map traces (imagesc)
figure
img_x = 1 : size(imgobj.dFF_s_ave, 2);
t = ((0:datap - 1) * imgobj.FVsampt)';

for i = 1: length(imgobj.selectROI)
    subplot(1, length(imgobj.selectROI), i)
    imagesc(t, img_x, imgobj.dFF_s_ave(:,:,imgobj.selectROI(i))')
    caxis([cmin, cmax])
    
    title(['ROI=#', num2str(imgobj.selectROI(i))])
    set(gca,'YTick',1:nstim);% something like this
    ylabel('Stim')
    xlabel('Time(s)')
    
    
    %stim onst
    line([t(prep+1), t(prep+1)], [0, nstim+1], 'Color', 'g', 'LineWidth', 1)
    
    %stim offset
    if length(sobj.moveDuration) > 1
        for i2 = 1:nstim
            x_off = t(prep+1) + sobj.moveDuration(C(i2));
            y = [i2  - 0.5, i2 + 0.5];
            line([x_off, x_off], y, 'Color', 'r', 'LineWidth', 1)
        end
    else
        line([t(prep+1)+duration, t(prep+1)+duration],...
            [0, nstim+1], 'Color', 'r', 'LineWidth', 1)
    end
end

%% plot trace

figure
for i = 1:nROI
    for i2 = 1:nstim
        subplot(nstim, nROI, i + (i2-1) * nROI)
        plot(t, imgobj.dFF_s_ave(:, i2, imgobj.selectROI(i)), 'r-', 'LineWidth', 2)
        xlim([0, datap*imgobj.FVsampt])
        ylim([-0.5, 1])
        if i2 == 1
            title(['ROI=#', num2str(imgobj.selectROI(i))])
        end
        %stim onset
        line([t(prep+1), t(prep+1)],[-1,3], 'Color', 'g', 'LineWidth', 2);
        
        if length(sobj.moveDuration) > 1
            x_off = t(prep+1) + sobj.moveDuration(C(i2));
            y = [-1, 3];
            line([x_off, x_off], y, 'Color', 'g', 'LineWidth', 2);
        else
            line([t(prep+1)+duration, t(prep+1)+duration],[-1,3], 'Color', 'g', 'LineWidth', 2);
        end
    end
end



end