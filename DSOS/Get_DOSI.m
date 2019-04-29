function [rho, the] = Get_DOSI(data, dir, ind)
switch ind
    case 0 %direction
        Z = sum(data.* exp(1i * dir)) / sum(data); 
        the = wrapTo2Pi(angle(Z));
    case 1 %orientation
        Z = sum(data .* exp(2i * dir)) / sum(data); 
        the = wrapTo2Pi(angle(Z))/2;
end
rho = abs(Z);
end