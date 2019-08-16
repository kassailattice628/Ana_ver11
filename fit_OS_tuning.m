function [x, x_me, y, y_me, fit_g, b_g] = fit_OS_tuning(k, d)
%%%%%%%%%%
%
% fit single Gaussian funtion for orientation selective responses
% k =: selected roi
% d =: directions vector
%
%%%%%%%%%%

global imgobj
%% %%%%%%%%

x = [];
y = [];
x_me = [];
y_me = [];

%dir to ori
o = wrapTo2Pi(d*2)/2;

for i = 1:length(o)/2
    y_i2 = [];
    for i2 = [i, i + length(o)/2]
        y_s = rmmissing(imgobj.dFF_s_each(:,i2, k));
        x_s = repmat(o(i), length(y_s), 1);
        
        y = [y; y_s];
        x = [x; x_s];
        
        y_i2 = [y_i2; y_s]; 
    end
        x_me = [x_me; o(i)];
        y_me = [y_me; mean(y_i2)];
end

%%
%%%%%%%%%% fit function and parameters

fit_g = @(b, x) b(1)*exp((-x.^2)/(2*b(2)^2)) + b(3);

lb_g = [min(y); 0.01; 0];
ub_g = [max(y); 2*pi; min(y)];
b0_g = [max(y); 1; 0];

%%
%%%%%%%%%% centering

if ismember(k, imgobj.roi_ori_sel)
    x_c = imgobj.Ang_ori0(k) - pi/2;
end

x = x - x_c;
x(x>pi/2) = x(x>pi/2) - pi;
x_me = x_me - x_c;
x_me(x_me>pi/2) = x_me(x_me>pi/2) - pi;

%%%%%%%%%%
% find params for fit
b_g = lsqcurvefit(fit_g, b0_g, x, y, lb_g, ub_g);
%[b_g, resnorm, ~, exitflag, output] = lsqcurvefit(fit_g, b0_g, x, y, lb_g, ub_g);
disp(['roi=#', num2str(k)])
disp(['Amp1 = ', num2str(b_g(1))])
disp(['SD1 = ', num2str(b_g(2))])
%%%%%%%%%%

%% test plot
%{
xp_ori = -pi/2:0.01:pi/2;
fit = fit_g(b_g, xp_ori);

figure
subplot(2, 2, 3)
scatter(x, y, 'g*')
xlim([-pi/2, pi/2])
hold on
scatter(x_me, y_me, 'mo');
plot(xp_ori, fit, 'LineWidth', 2);
title('Single Gaussian Fit for Orientation')

set(gca, 'xtick', [-pi/2, 0, pi/2],...
    'xticklabel', {'-pi/2', 'Pref. - pi/2', 'pi/2'})
hold off
%}
%%
end
