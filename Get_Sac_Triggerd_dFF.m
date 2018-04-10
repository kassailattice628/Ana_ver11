function Get_Sac_Triggerd_dFF
global imgobj
global ParamsSave

sac_t = [];
loc_t = [];
for i = 1:size(ParamsSave,2)
    sac_t = horzcat(sac_t, ParamsSave{i}.sac_t);
    loc_t = vertcat(loc_t, ParamsSave{i}.loc_t);
end

%%

figure
subplot(1,2,1)
histogram(sac_t, 100)
subplot(1,2,2)
histogram(loc_t(:,1), 100)


pd_sac = fitdist(sac_t', 'Kernel', 'BandWidth', 30);
x = 0:imgobj.FVsampt:imgobj.FVsampt*(2500-1);
y_sac = pdf(pd_sac, x);

pd_loc = fitdist(loc_t(:,1), 'Kernel', 'BandWidth', 30);
y_loc = pdf(pd_loc, x);


figure
plot(x, y_sac, 'r-')
hold on
plot(x, y_loc, 'b-')
hold off

[acor, lag] = xcorr(y_sac, y_loc);
figure, plot(lag, acor)
disp(lag)


%% plot saccade alighned response
%{
mag_os = 200; %magnified sampling
smpt_os = imgobj.FVsampt/mag_os;

nframe = size(imgobj.dFF, 1);
FVt_os = interp1(0:nframe-1, imgobj.FVt, 0:1/mag_os:nframe-1/mag_os, 'spline');

%find sac_t from overspmled time

%%
sac_i_os = [];
for i2 = 1:length(sac_t)
    [~, ind] = find(FVt_os > sac_t(i2), 1, 'first');
    sac_i_os = horzcat(sac_i_os, ind);
end

prep = mag_os * 2;
postp = mag_os * 10;

%%
%test using roi 48

dFF_sac_ave = zeros(imgobj.maxROIs, prep+1+postp);
sac_ave_t = ((-imgobj.FVsampt * 2): smpt_os :imgobj.FVsampt * 10);

%%
for i2 = 11
    if isnan(imgobj.dFF(1,i2))
        continue;
    end
    
    dFF_os = interp1(0:nframe-1, imgobj.dFF(:,i2), 0:1/mag_os: nframe - 1/mag_os, 'spline');
    
    dFF_sac_os = zeros(length(sac_t), length(sac_ave_t));
    for i3 = 1:length(sac_t)
        if sac_i_os(i3) - prep > 0 && sac_i_os(i3) + postp < length(dFF_os)
            dFF_sac_os(i3, :) = dFF_os((sac_i_os(i3) - prep:sac_i_os(i3)+postp));
        end
    end
    
    figure
    hold on
    for i3 = 1:size(dFF_sac_os, 1)
        plot(dFF_sac_os(i3,:))
    end
    hold off
    
end
%%
%figure, plot(FVt_os, dFF_os)
%}
end

