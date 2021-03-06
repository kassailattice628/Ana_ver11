function [R_boot_med, P_boot,...
    roi_ds, roi_os, b_ds, b_os,...
    Ci_ds, Ci_os, f_ds, f_os, R_ds, R_os, J_ds, J_os,...
    Fitresult_ds, Fitresult_os] = Get_Boot_DOSI2(imgobj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resample data by bootstrap
% Calc bootstrapped mean of the data and median of each conditions
% Calc vector averages for direction/orientation using bootstrapped data
% Fit the bootstrapped data to the single or double peaked von Mises function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get stim direction vector
direction = imgobj.directions;
n_boot = 5000;

R_boot_med = zeros(length(direction), imgobj.maxROIs);
P_boot = zeros(n_boot, 4, imgobj.maxROIs);
roi_ds = [];
roi_os = [];
% b_ds = zeros(imgobj.maxROIs, 3);
% b_os = zeros(imgobj.maxROIs, 4);
b_ds = zeros(imgobj.maxROIs, 6);
b_os = zeros(imgobj.maxROIs, 6);
Ci_ds = zeros(imgobj.maxROIs, size(b_ds,2)*2);
Ci_os = zeros(imgobj.maxROIs, size(b_os,2)*2);

R_ds = cell(1, imgobj.maxROIs);
R_os = cell(1, imgobj.maxROIs);

J_ds = cell(1, imgobj.maxROIs);
J_os = cell(1, imgobj.maxROIs);

f_ds = zeros(1, imgobj.maxROIs);
f_os = f_ds;

Fitresult_ds = cell(1, imgobj.maxROIs);
Fitresult_os = cell(1, imgobj.maxROIs);


for i = 1:imgobj.maxROIs
    if isempty(rmmissing(imgobj.dFF_s_each(:,:,i)))
        continue
    end
    [P, x_boot, ds, os] = Get_selective_boot(imgobj.dFF_s_each(:,:,i), direction, n_boot);
    P_boot(:,:,i) = P;
    
    R_boot_med_ = [];
    
    %direction
    if ds
        roi_ds = [roi_ds, i];
        [b_ds_, Ci_ds_, f_ds_, R_boot_med_, R_ds_, J_ds_] = Fit_vonMises3(x_boot, direction, median(P(:,2)),1, i);
        if length(b_ds_) == length(b_ds)
            b_ds(i,:) = b_ds_;
            Ci_ds(i,:) = Ci_ds_;
        else
            b_ds(i, 1:length(b_ds_)) = b_ds_;
            Ci_ds(i, 1:length(Ci_ds_)) = Ci_ds_;
        end
        
        f_ds(i) = f_ds_;
        J_ds{i} = J_ds_;
        R_ds{i} = R_ds_;
        %Update L_dir, Ang_dir
        imgobj.Ldir(i) = median(P_boot(:, 1, i));
        imgobj.Ang_dir(i) = median(P_boot(:, 2, i));
        
        [Fitresult_ds{i}, ~] = Get_Fit_for_PredInt(x_boot, direction, median(P(:,2)), f_ds_);
    end
    
    %orientation
    if os
        roi_os = [roi_os, i];
        [b_os(i,:), Ci_os(i,:), f_os_, R_boot_med_, R_os_, J_os_] =...
            Fit_vonMises3(x_boot, direction, median(P(:,4)), 2, i);
        f_os(i) = f_os_;
        J_os{i} = J_os_;
        R_os{i} = R_os_;
        
        %Update L_ori, Ang_ori
        imgobj.Lori(i) = median(P_boot(:, 3, i));
        imgobj.Ang_ori(i) = median(P_boot(:, 4, i)); 
        
        [Fitresult_os{i}, ~] = Get_Fit_for_PredInt(x_boot, direction, median(P(:,4)), f_os_);
    end
    
    if ~ds && ~os
        R_boot_med_ = median(x_boot);
    end
    
    %%%%%%%%%%
    if ~isempty(R_boot_med_)
        R_boot_med(:,i) = R_boot_med_;
    end
        
end

%roi �C��
roi_ds = setdiff(roi_ds, [imgobj.roi_nega_R, imgobj.roi_no_res']);
roi_os = setdiff(roi_os, [imgobj.roi_nega_R, imgobj.roi_no_res']);


P_boot = reshape(P_boot, [], imgobj.maxROIs);
P_boot = sparse(P_boot);
end %% END OF "Get_Boot_Dir_Ori_Select