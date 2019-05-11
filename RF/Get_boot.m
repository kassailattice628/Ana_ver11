function x_boot = Get_boot(data, n_boot)
%data = imgobj.dFF_s_each(:,:,k)

n_data = size(data, 2);
x_boot = zeros(n_boot, n_data);

%remove NaN resample data
parfor i = 1:n_data
    x = rmmissing(data(:,i));
    x_boot_ = bootstrp(n_boot, @mean, x);
    x_boot(:,i) = x_boot_;
end
