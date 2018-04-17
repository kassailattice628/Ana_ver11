

%fit cos curve to direction slective response

% to compare ROIs, centering by preferred direction

ang_list = 0:pi/6:23*pi/12;
x = [];
y = []; 
i = imgobj.selectROI;

x_me = [];
y_me = [];

for i2 = 1:12
    y_s = rmmissing(imgobj.dFF_s_each(:,i2, i));
    x_s = repmat(ang_list(i2), [length(y_s),1]);
    
    y = [y; y_s];
    x = [x; x_s];
    
    x_me = [x_me; ang_list(i2)];
    y_me = [y_me; mean(y_s)];
end


% for direction selective cell
% pref direction = imgobj.Ang_dir(i)
if imgobj.L_ori(i) > 0.2 && max(y_me) > 0.5
    %centring
    x_c = imgobj.Ang_ori(i);
    
elseif imgobj.L_dir(i) > 0.2 && max(y_me) > 0.5
    x_c = imgobj.Ang_dir(i);
end
x = x - x_c;
x = wrapToPi(x);

x_me = x_me - x_c;
x_me= wrapToPi(x_me);


% plot
figure
scatter(x, y, 'b*')
xlim([-pi, pi])
ylim([0, max(y)*1.1])

hold on
scatter(x_me, y_me, 'ro');



%%%%%%%%%%%%%%%%%%%%%%%
%{
%fit to sinusoidal function, mean Ç≈Ç‚ÇÁÇ»Ç¢Ç∆Ç¢ÇØÇ»Ç¢ÅH
yu = max(y_me);
yl = min(y_me);
yr = yu - yl;  %range of y
yz = y_me - yu + (yr/2);

zx = x_me(yz .* circshift(yz,[1 0]) <= 0);     % Find zero-crossings
per = 2*mean(diff(zx));

ym =  mean(y_me); %Estimate offset
xp = -pi:0.01:pi;

fit = @(b, x) b(1)*(cos(x./b(2)) + b(3)) + b(4);

lb = [yu/4;0.5; 0; 0];
ub = [yu; 2; pi; yu];
b0 = [yr; per; 0; ym];
[b, resnorm, ~, exitflag, output] = lsqcurvefit(fit, b0, x_me, y_me, lb, ub);
plot(xp, fit(b, xp))

disp(b)

%}
xp = -pi:0.01:pi;
%%%%%%%
%fit to double gaussian
fit_g = @(b, x) b(1)*exp((-(x-b(2)).^2)/(2*b(3)^2)) + b(4)*exp((-(x-b(5)).^2 )/(2*b(6)^2));
lb_g = [0; -pi; 0; 0; -pi; 0;];
ub_g = [max(y); 2*pi; pi; max(y); 2*pi; pi];
b0_g = [0.5; pi/2; 1; 0.5; 3*pi/2; 1];
[b_g, resnorm, ~, exitflag, output] = lsqcurvefit(fit_g, b0_g, x, y, lb_g, ub_g);
plot(xp, fit_g(b_g, xp))

disp(b_g)