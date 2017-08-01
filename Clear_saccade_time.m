function Clear_saccade_time(~,~, opt)
global ParamsSave
global n
global hfig

if opt == 1
    ParamsSave{1,n}.sac_t = [];
    set(hfig.sac_locs, 'String', '');
    % reset event plot
    set(hfig.plot1_1_sac, 'XData', NaN, 'YData', NaN);
    set(hfig.plot1_2_sac, 'XData', NaN, 'YData', NaN);
    set(hfig.plot2_2, 'XData', NaN, 'YData', NaN);
    
elseif opt == 2
    for i = 1:size(ParamsSave, 2)
        ParamsSave{1,i}.sac_t = [];
    end
end
