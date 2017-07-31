function Plot_Stim_Tuning(~,~, s)

switch s.pattern
    case 'Size_rand'
        text_tuning = 'Size Tuning';
    case {'Sin', 'Rect', 'Gabor', 'MoveBar'}
        text_tuning = 'Dir/Ori Tuning';
    case {'Images'}
        text_tuning = 'Image selectivity';
    otherwise
        text_tuning = '';
        visible = 'off';
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% size tuning plot
function Get_peak_me

end

