function [b_e, x_edge, y_edge] = Plot_FitRF(beta, data, i)
%%%%%%%%%%%
% beta(1) = Amp(amplitude)
% beta(2) = x0 (x center)
% beta(3) = xsd (x SD)
% beta(4) = y0 (y center)
% beta(5) = ysd (y SD)
% beta(6) = theta(rotation angle)

% data => neural responses along stim position matrix

% i => selected ROI
%%%%%%%%%%
global sobj

%%%%%%%%%%

%define output
b_e = zeros(1,5);
x_edge = [];
y_edge = [];

%%%%%%%%%%
if beta(1) < 0.15
    disp(['Peak Amplitude of ROI#', num2str(i), ' is too weak']);
    
else
    % Show plot
    figure;
    data_ = data;
    im = imagesc(data_);
    caxis([0.1,1])
    im.AlphaData = .5;
    title(['ROI#: ', num2str(i), ', ', sobj.pattern]);
    hold on
    
    % contour
    x = -20:0.1:20;
    [X, Y] = meshgrid(x);
    d = zeros(length(x), length(x),2);
    d(:,:,1) = X;
    d(:,:,2) = Y;
    G_fit = GaussianRot2D(beta, d);
    contour(X, Y, G_fit);
    
    %G_fit の値を使って，Xsd から Z > 0.15 の値を（Yも同様）を取得
    % the points over the threshold along the long and short axis
    fcn_gauss = @(b, x) b(1) .* exp(-((x)./b(2)).^2);
    x =  0:0.01:20;
    
    %Xsd
    b = [beta(1), beta(3)];
    fcn_x = fcn_gauss(b, x);
    ind = find(fcn_x >= 0.15, 1, 'last');
    x_edge = x(ind);
    
    %Ysd -> short
    b = [beta(1), beta(5)];
    fcn_y = fcn_gauss(b, x);
    ind = find(fcn_y >= 0.15, 1, 'last');
    y_edge = x(ind);
    
    %%%%%%%%%
    %plot Elipse
    
    b_e = [beta(2), x_edge, beta(4), y_edge, beta(6)];
    FE_ = ElipseRot(b_e);
    plot(FE_(1,:), FE_(2,:), 'r-', 'LineWidth', 2);
    
    %%%%%%%%%%
    %plot RF center
    
    plot(beta(2), beta(4), 'ro');
    
    %%%%%%%%%%
    %plot Line along the long axis ot
    
    %LineRot(beta);
    
end
%{
%check edge size
figure
plot(x, fcn_x, 'r')
hold on
line([x_edge, x_edge],[0, beta(1)], 'Color','red','LineStyle','--')

plot(x, fcn_y, 'b')
line([y_edge, y_edge],[0, beta(1)], 'Color','blue','LineStyle','--')

line([min(x), max(x)],[0.15, 0.15], 'Color', 'black', 'LineStyle', '--');
%}

end

%%
%%%%%%%%%% %%%%%%%%%% %%%%%%%%%% %%%%%%%%%%
function FE = ElipseRot(beta)
%Elipse
t = 0:0.01:2*pi;

x0 = beta(1);
a = beta(2);
y0 = beta(3);
b = beta(4);

if b > a
    theta = -beta(5);
else
    theta = pi -beta(5);
end

x1 = [a*cos(t); b*sin(t)];

%rotation
R = [cos(theta), -sin(theta);...
    sin(theta), cos(theta)];

%center
c = [x0 * ones(1,length(t)); y0 * ones(1,length(t))];

FE = R * x1 + c;


end


%%
function LineRot(beta)

if beta(5) <= beta(3)
    theta = pi - beta(6);
else
    theta = -beta(6);
end


x =  -20:0.1:20;
y = zeros(1, length(x));
x = -20:0.1:20;
x1 = [x; y];
rot = [cos(theta) -sin(theta);
    sin(theta) cos(theta)];
x1_ = rot * x1;
x1_(1,:) = x1_(1,:) + beta(2);
x1_(2,:) = x1_(2,:) + beta(4);
%y_line = tan(beta(6)) * (x - imgobj.b_GaRot2D(i,2)) + imgobj.b_GaRot2D(i,4);
plot(x1_(1,:),x1_(2,:))


end
