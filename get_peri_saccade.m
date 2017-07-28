function [H, V, time] = get_peri_saccade(locs, data, n, r)
%%
global hfig
H=[];
V=[];
time=[];

if ~isempty(locs) && isfield(hfig, 'peri_saccade')
    time = 1/r.sampf : 1/r.sampf : 400 * 1/r.sampf;
    time = repmat(time', [1, length(locs)]); 
    H = time;
    V = time;
    for i = 1:length(locs)
        t_point = (locs(i)-100):(locs(i)+299);        
        if max(t_point) > size(data,1)
            t_end = 400 + size(data,1)-max(t_point);
            t_point(1:t_end)= (locs(i)-100):size(data,1);
            t_point(t_end + 1: end) = size(data,1);
        elseif t_point(1) <= 0
            t_point(t_point <= 0) = 1;
        end
        
        H(:, i) = data(t_point, 1, n) - data(t_point(1), 1, n);
        V(:, i) = data(t_point, 2, n) - data(t_point(1), 2, n);
    end
    
    axes(hfig.axes6_1);
    plot(time, H);
    ylim([-4, 4])
    title('Horizontal')
    
    axes(hfig.axes6_2);
    plot(time, V);
    ylim([-4, 4])
    title('Vertical')
end
end