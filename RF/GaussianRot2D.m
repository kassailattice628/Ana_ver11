function f = GaussianRot2D(beta,x)
%
% Gaussian function with rotation.
% beta is a set of gaussian parameters.
% beta = [Amp,x0,x_sd,y0,y_sd,phi]...
% x is input vector or matrix(3D)
%

b1 = beta(1);%Amp
b2 = beta(2);%x0
b3 = beta(3);%x_sd
b4 = beta(4);%y0
b5 = beta(5);%y_sd
b6 = beta(6);%phi( 0 <= phi, phi < pi)

if size(x, 3) == 1
    X = x(:,1);
    Y = x(:,2);
elseif size(x, 3) == 2
    X = x(:,:,1);
    Y = x(:,:,2);
end

%‰ñ“]•â³
Xrot = X.*cos(b6) - Y.*sin(b6);
Yrot = X.*sin(b6) + Y.*cos(b6);
%’†SÀ•W•â³
X0rot = b2*cos(b6) - b4*sin(b6);
Y0rot = b2*sin(b6) + b4*cos(b6);

%2D Gaussian
f = b1*(exp(-( (Xrot-X0rot).^2/(2*(b3)^2) + (Yrot-Y0rot).^2/(2*(b5)^2))));