function [x, x_me, y, y_me, fit_g, b_g] = fit_DS_OS_tuning(k, dir)
%fit double Gaussians to direction slective response
% to compare ROIs, centering by preferred direction

global imgobj

x = [];
y = []; 
x_me = [];
y_me = [];

for k2 = 1:length(dir)
    y_s = rmmissing(imgobj.dFF_s_each(:,k2, k));
    x_s = repmat(dir(k2), [length(y_s),1]);
    
    y = [y; y_s];
    x = [x; x_s];
    
    x_me = [x_me; dir(k2)];
    y_me = [y_me; mean(y_s)];
end

% for direction selective cell
% pref direction = imgobj.Ang_dir(i)
if imgobj.L_ori(k) > 0.3 && max(y_me) > 0.3
    %centring
    x_c = imgobj.Ang_ori(k);
    
elseif imgobj.L_dir(k) > 0.2 && max(y_me) > 0.3
    x_c = imgobj.Ang_dir(k);
    
else
    x_c = 0;
end
x = x - x_c;
x = wrapToPi(x);

x_me = x_me - x_c;
x_me= wrapToPi(x_me);

%%%%%%%%%%%
%fit to double gaussian
fit_g = @(b, x) b(1)*exp((-(x-b(2)).^2)/(2*b(3)^2)) + b(4)*exp((-(x-b(5)).^2 )/(2*b(6)^2));
lb_g = [0; -pi; 1; 0; -pi; 1;];
ub_g = [max(y); pi; pi; max(y); pi; pi];
b0_g = [0.5; pi/2; 1; 0.5; 3*pi/2; 1];
[b_g, resnorm, ~, exitflag, output] = lsqcurvefit(fit_g, b0_g, x, y, lb_g, ub_g);
disp(b_g)
%%%%%%%%%%%

end