function [R_boot_med, P_boot,...
    roi_os, b_os,...
    Ci_os, f_os] = Get_Boot_BarOS(imgobj)


%Stimuli
ori = imgobj.orientations;
n_boot = 5000;

R_boot_med = zeros(length(ori), imgobj.maxROIs);
%R_boot_med2 = zeros(length(ori)*2, imgobj.maxROIs);
P_boot = zeros(n_boot, 4, imgobj.maxROIs);
roi_os = [];
b_os = zeros(imgobj.maxROIs, 4);
Ci_os = zeros(imgobj.maxROIs, size(b_os,2)*2);

f_os = zeros(1, imgobj.maxROIs);

for i = 1:imgobj.maxROIs
    if isempty(rmmissing(imgobj.dFF_s_each(:,:,i)))
        continue
    end
    
    [P, x_boot, os] = Get_selective_boot_BarOS(imgobj.dFF_s_each(:,:,i),...
        ori, n_boot);
    P_boot(:,:,i) = P;
    R_boot_med_ = [];
    
    if os
        roi_os = [roi_os, i];
        
        [b_os(i,:), Ci_os(i,:), f_os_, R_boot_med_] = Fit_vonMises2_(x_boot, ori, median(P(:,4)), i);
        
        f_os(i) = f_os_;
        
        %Update L_ori, Ang_ori
        imgobj.Lori(i) = median(P_boot(:,3,i));
        imgobj.Ang_ori(i) = median(P_boot(:,4,i));
    end
    
    
    if ~os
        R_boot_med_ = median(x_boot);
    end
    
    %%%%%%%%%%
    if ~isempty(R_boot_med_)
        R_boot_med(:,i) = R_boot_med_;
    end
end

%roi èCê≥
roi_os = setdiff(roi_os, [imgobj.roi_nega_R, imgobj.roi_no_res']);

P_boot = reshape(P_boot, [], imgobj.maxROIs);
P_boot = sparse(P_boot);
end %% END OF "Get_Boot_BarOS"


%%
function [P, x_boot, os] = Get_selective_boot_BarOS(data, ori, n_boot)
%data = imgobj.dFF_s_each(:,:,k)

n_data = size(data, 2);
x_boot = zeros(n_boot, n_data);

%remove NaN and resample data for each direction
parfor i = 1:n_data
    x = rmmissing(data(:,i));
    x_b = bootstrp(n_boot, @mean, x);
    x_boot(:,i) = x_b;
end

%Get selectivity indices and prefered agles from resampled data
P = zeros(n_boot, 4);
parfor i = 1:n_boot
    Z =  sum(x_boot(i,:) .* exp(2*(1i * ori)))/sum(x_boot(i,:));
    osi = abs(Z);
    ang_ori = angle(Z)/2;
    P(i, :) = [0, 0, osi, ang_ori];
end

%if 10% border is higher than the threshold, the cell was defined to have a
%selectivity for direction, or orientation

%orientation
if prctile(P(:,3), 10) > 0.15
    os = 1;
else
    os = 0;
end


end

%%
function [b_fit, ci, f_select, R_boot_med] =...
    Fit_vonMises2_(data_boot, ori, pref, roin)
%%
global hfig

R_boot_med = median(data_boot);

data = reshape(data_boot, 1, []);
opts = optimset('Display','off');

%orientation ÇÃÇ›
ori_ = repmat(ori, [size(data_boot,1), 1]);
ori_ = reshape(ori_, 1, []);

[f_vM, b0, bl, bu] = Set_FitFc;
[b_fit, ~, ci] = Exec_Fit(f_vM, b0, bl, bu);
%selectivity %2 :: OS
f_select = 2;

%ïœçX
if get(hfig.h_CB, 'Value')
    Plot_DSOS(f_vM, b_fit, dir, R_boot_med, roin, f_select)
end

%%
    function  [f_vM, b0, bl, bu] = Set_FitFc
        b0 = [1, 1, pref, 0];
        
        bl = [0.001, 0.01, 0, 0];
        bu = [5, 5, pi, 5];
        %f_vM = Select_vonMises(2);
        %0 to pi Ç≈ wrap ÇµÇΩÇ‡Ç‡ÇÃÇ™çÏÇËÇΩÇ¢ÇÃÇ≈
        f_vM = @(b, x) b(1) * exp(b(2) * cos(2*(x - b(3)))) + b(4);
    end
%%
    function [b_fit, res, ci] = Exec_Fit(f_vM, b0, bl, bu)
        [b_fit, res, r, ~,~,~,J] = lsqcurvefit(f_vM, b0, ori_, data, bl, bu, opts);
        ci = nlparci(b_fit,r,'jacobian',J);
        ci = reshape(ci', 1, []);
        disp(['ROI# = ', num2str(roin)])
        disp(res)
    end
end