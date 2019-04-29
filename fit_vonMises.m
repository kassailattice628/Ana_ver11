function [b_g] = fit_vonMises(k, d)
%%%%%%%%%%
%
% von Mises function is used to fit the direction/orientation tuning
% responses
%
% k =: selected roi
% d =: detection vector
%
%%%%%%%%%%

global imgobj

%%%%%%%%%%

if nargin == 0
    k = imgobj.selectROI;
    d_size = size(imgobj.dFF_s_each,2);
    d = linspace(0, (2*pi - 2*pi/d_size), d_size);
end

%%%%%%%%%%
x = [];
y = [];
x_me = [];
y_me = [];

%ï°êîëIëÇµÇΩéûÇÃÇΩÇﬂÇ…ÅD
for k2 = 1:length(d)
    y_s = rmmissing(imgobj.dFF_s_each(:,k2, k));
    x_s = repmat(d(k2), [length(y_s),1]);
    
    y = [y; y_s];
    x = [x; x_s];
    
    x_me = [x_me; d(k2)];
    y_me = [y_me; mean(y_s)];
end

max(y)
%%
%%%%%%%%%% fit function and parameters
if ismember(k, imgobj.roi_dir_sel)
    c = imgobj.Ang_dir(k);
    %b0_g = [1, pi];
    %fit_g = @(b, x) b(1) * (exp(b(2)*cos(x - c)))/exp(b(2));
    b0_g = [1, pi, 1];
    fit_g = @(b, x) b(1) * (exp(b(2) * cos(x - c)))/exp(b(2)) +...
        b(3)*(b(1) * (exp(b(2) * cos(x - c + pi)))/exp(b(2)));
    
elseif ismember(k, imgobj.roi_ori_sel)
    c = imgobj.Ang_ori(k) - pi/2;
    disp(c)
    b0_g = [1, pi, 1];
    fit_g = @(b, x) b(1) * (exp(b(2) * cos(x - c)))/exp(b(2)) +...
        b(3)*(b(1) * (exp(b(2) * cos(x - c + pi)))/exp(b(2)));
end




%%
b_g = lsqcurvefit(fit_g, b0_g, x, y);
disp(b_g)

xp = 0:0.01:2*pi;
F_fit = fit_g(b_g, xp);

figure,
hold on
plot(x, y, 'b*');
plot(x_me, y_me, 'mo');
plot(xp, F_fit, 'k-', 'LineWidth',2);

end