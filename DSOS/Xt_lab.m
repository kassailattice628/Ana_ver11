function xt_lab = Xt_lab(j, i)
%i = 0: direction
%i = 1: orientation
%j :: length stim directions or orientations

switch i
    case 0
        if j == 8
            xt_lab = {'0', '\pi/4', '\pi/2', '3\pi/4','\pi', '5\pi/4', '3\pi/2', '7\pi/4'};
        elseif j == 12
            xt_lab = {'0', '\pi/6', '\pi/3', '\pi/2','2\pi/3', '5\pi/6', '\pi', '7\pi/6', '4\pi/3',...
            '3\pi/2', '5\pi/3', '11\pi/6'};
        elseif j == 16
            xt_lab = {'0', '\pi/8', '\pi/4', '3\pi/8','\pi/2', '5\pi/8', '3\pi/4', '7\pi/8',...
            '\pi', '9\pi/8', '5\pi/4', '11\pi/8', '3\pi/2', '13\pi/8', '7\pi/4', '15\pi/8'};
        else
            xt_lab = [];
        end
        
    case 1
        if j == 4
            xt_lab = {'0', '\pi/4', '\pi/2', '3\pi/4'};
        elseif j == 6
            xt_lab = {'0', '\pi/6', '\pi/3', '\pi/2','2\pi/3', '5\pi/6'};
        elseif j == 8
            xt_lab = {'0', '\pi/8', '\pi/4', '3\pi/8','\pi/2', '5\pi/8', '3\pi/4', '7\pi/8'};
        else
            xt_lab = [];
        end
end
end