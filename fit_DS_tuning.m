function [x, x_me, y, y_me, fit_g, b_g] = fit_DS_tuning(k, d)
%%%%%%%%%%
%
% fit double Gaussians to dection slective response
% to compare ROIs, centering by preferred direction
%
% k =: selected roi
% d =: dection vector
%
%%%%%%%%%%

global imgobj
%% %%%%%%%%

x = [];
y = [];
x_me = [];
y_me = [];

for k2 = 1:length(d)
    y_s = rmmissing(imgobj.dFF_s_each(:,k2, k));
    x_s = repmat(d(k2), [length(y_s),1]);
    
    y = [y; y_s];
    x = [x; x_s];
    
    x_me = [x_me; d(k2)];
    y_me = [y_me; mean(y_s)];
end
%%
%%%%%%%%%% fit function and parameters

fit_g = @(b, x) b(1)*exp((-(x-(pi/2)).^2)/(2*b(2)^2)) +...
    b(3)*exp((-(x-b(4)-(pi/2)).^2 )/(2*b(5)^2)) + b(6);

lb_g = [0.15; 0.01; 0; 2*pi/3; pi/2; 0];
ub_g = [max(y); pi/2; max(y); 4*pi/3; pi; min(y)];
b0_g = [0.5; 1; 0.5; pi; 1; 0];

%%
%%%%%%%%%% centering
a = imgobj.Ang_dir(k);
b = imgobj.Ang_ori0(k);

if ismember(k, imgobj.roi_ori_sel) && ismember(k, imgobj.roi_dir_sel) %both selective
    x_c = a - pi/2;
    
elseif ismember(k, imgobj.roi_dir_sel) %direction only
    x_c = a - pi/2;
    
elseif ismember(k, imgobj.roi_ori_sel) %orientation only
    b2 = wrapTo2Pi(b - pi); % clockwise
    i1 = find(d > b & b2 >= d);
    i2 = setdiff(1:12, i1);
    
    %if max(nanmax(imgobj.dFF_s_each(:,i1,k))) >= max(nanmax(imgobj.dFF_s_each(:,i2,k)))
    if max(max(imgobj.dFF_s_ave(:,i1,k))) >= max(max(imgobj.dFF_s_ave(:,i2, k)))
        x_c = b;
    else
        x_c = b - pi;
    end
    
else %non-selective
    x_c = 0;
end

%%%%%%%%%%
x = x - x_c;
x = wrapTo2Pi(x);

x_me = x_me - x_c;
x_me = wrapTo2Pi(x_me);

%%%%%%%%%%%
% find params for fit
[b_g, resnorm, ~, exitflag, output] = lsqcurvefit(fit_g, b0_g, x_me, y_me, lb_g, ub_g);
disp(['roi=#', num2str(k)])
disp(['Amp1 = ', num2str(b_g(1))])
disp(['SD1 = ', num2str(b_g(2))])
disp(['Amp2 = ', num2str(b_g(3))])
disp(['Cener2 = ', num2str(b_g(4))])
disp(['SD2 = ', num2str(b_g(5))])
%%%%%%%%%%%

end