function Plot_RF_selected(i_roi)
%%%%%%%%%%

global imgobj
global sobj

%%%%%%%%%%

if ~isfield(imgobj, 'b_GaRot2D')
    errordlg('Get RF(boot) first!');
else
    %stim_position
    if isfield(sobj, 'center_pos_list_FineMap') && strcmp(sobj.pattern, 'FineMap')
        %Fine map mode
        pos =  sqrt(size(sobj.center_pos_list_FineMap, 1));
    else
        %Normal uni
        pos = sqrt(size(sobj.center_pos_list,1));
    end
    
    %%
    for i = i_roi%imgobj.selectROI
        %Set color acording to RF center position
        data = reshape(imgobj.dFF_boot_med(:,i), pos, pos);
        Plot_FitRF(imgobj.b_GaRot2D(i,:), data, i);
    end
    
end