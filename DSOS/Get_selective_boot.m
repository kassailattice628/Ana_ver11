function [P, x_boot, ds, os] = Get_selective_boot(data, dir, n_boot)
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
    [dsi, ang_dir] = Get_DOSI(x_boot(i,:), dir, 0);
    [osi, ang_ori] = Get_DOSI(x_boot(i,:), dir, 1);
    P(i, :) = [dsi, ang_dir, osi, ang_ori];
end

%if 10% border is higher than the threshold, the cell was defined to have a
%selectivity for direction, or orientation
%direction
if prctile(P(:,1), 10) > 0.2
    ds = 1;
else
    ds = 0;
end

%orientation
if prctile(P(:,3), 10) > 0.15
    os = 1;
else
    os = 0;
end


end
