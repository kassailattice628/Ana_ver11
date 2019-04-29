function Put_template_bar(i, C, Col, ang)
%%
%{
 figure

%base img
BG = zeros(320,320);
imshow(BG);

roi = 1:10;
C = randi([1,320], 10,2);

ang = rand(10,1) * pi;
%}


W = 4;
L = 30;

%for i = roi
X = [C(1,i) - L/2 * cos(ang(i)), C(1,i) + L/2 * cos(ang(i))];
Y = [C(2,i) + L/2 * sin(ang(i)), C(2,i) - L/2 * sin(ang(i))];
line(X, Y, 'Color', Col, 'LineWidth', W)
hold on
%end
%%
end
