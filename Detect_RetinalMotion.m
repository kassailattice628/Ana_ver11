%刺激タイミングの取得

%{
stimON, stimOFF は ParamsSave{}.stim1.corON, corOFF に入っているので
X: DataSave(:,1, stim_n) 
Y: DataSave(:,2, stim_n)
%}

frame_stimON = nan(size(ParamsSave, 2) - recobj.prestim, 1);
%f_ON = frame_stimON;
stim_trials = (recobj.prestim + 1) : size(ParamsSave,2);
Eye_Pos = zeros(length(stim_trials), 2);
Eye_Pos2 = cell(length(stim_trials), 2);

[prep, ~, ~, p_off, datap] = Def_len_datap;
ext_fs = zeros(datap, length(stim_trials));
%%

for i = stim_trials
    recTime = ParamsSave{1,i}.AIStartTime:1/recobj.sampf:ParamsSave{1,i}.AIEndTime+1/recobj.sampf;
    if isfield(ParamsSave{1,i}, 'stim1') && isfield(ParamsSave{1,i}.stim1, 'corON')
        on = ParamsSave{1,i}.stim1.corON;
        off = ParamsSave{1,i}.stim1.corOFF;
        
        [~, on] = min(abs(recTime - on));
        [~, off] = min(abs(recTime - off));
        
        %刺激中の eye position の平均値
        Eye_Pos(i - recobj.prestim,1) = mean(DataSave(on:off, 1, i));
        Eye_Pos(i - recobj.prestim,2) = mean(DataSave(on:off, 2, i));
        
        Eye_Pos2{i - recobj.prestim,1} = DataSave(on:off, 1, i);
        Eye_Pos2{i - recobj.prestim,2} = DataSave(on:off, 2, i);
        
        %刺激が出た時のimgフレーム
        %frame_stimON(i - recobj.prestim) = floor((ParamsSave{1,i}.stim1.corON)/imgobj.FVsampt);
        f_ON = floor((ParamsSave{1,i}.stim1.corON)/imgobj.FVsampt);
        
        ext_fs(:,i - recobj.prestim) = f_ON - prep : f_ON + p_off;
            
        
    end
end
%%
%視覚刺激の位置は固定なので， eye position によって dFF の値を区別？
%TrialVariation みたいに計算したい
s_each = zeros(datap, length(stim_trials), imgobj.maxROIs);
rois = 1:imgobj.maxROIs;

for i = rois
   if isnan(imgobj.dFF(1,i))
       continue;
   end
   
   for j = 1:length(stim_trials)
       s_each(:,j,i) = imgobj.dFF(ext_fs(:,j),i);
   end
end

%%
single_dFF = max(s_each(:,:,imgobj.selectROI))';

c = linspace(0.15, 3, length(stim_trials));
sz = linspace(10, 200, length(stim_trials));
[~, i_sort] = sort(single_dFF);
%Eye_Pos = Eye_Pos(i_sort,:);

figure
hold on
scatter(Eye_Pos(:,1), Eye_Pos(:,2), sz(i_sort), c(i_sort), 'filled')
plot(Eye_Pos(:,1), Eye_Pos(:,2),'-')
%surf([Eye_Pos(:,1) Eye_Pos(:,1)], [Eye_Pos(:,2), Eye_Pos(:,2)], [c(:), c(:)], 'FaceColor', 'none', 'EdgeColor', 'interp');
%view(2);
title('Eye Position')
xlim([-8 -7])
ylim([-8.5 -7.5])


%%
figure
hold on

for i = 1:length(stim_trials)
    plot(Eye_Pos2{i,1}, Eye_Pos2{i,2}, '-r')
    
end
plot(Eye_Pos(:,1), Eye_Pos(:,2),'-')
scatter(Eye_Pos(:,1), Eye_Pos(:,2), sz(i_sort), c(i_sort), 'filled')
%%
%{
figure
hold on
scatter(single_dFF, Eye_Pos(:,1), [], c, 'filled')
surf([single_dFF(:), single_dFF(:)], [Eye_Pos(:,1) Eye_Pos(:,1)], [c(:), c(:)], 'FaceColor', 'none', 'EdgeColor', 'interp');

title('Eye horizontal vs dFF')


figure
hold on
scatter(single_dFF, Eye_Pos(:,2), [], c, 'filled')
surf([single_dFF(:), single_dFF(:)],[Eye_Pos(:,2) Eye_Pos(:,2)],[c(:), c(:)], 'FaceColor', 'none', 'EdgeColor', 'interp');

title('Eye vertical vs dFF')
%}
