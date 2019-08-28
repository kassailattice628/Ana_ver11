function Get_Fit_params2(~, ~, check_box)
%%%%%%%%%%
%
% Detect DS/OS selective cells by bootstrap
% Get tuning parameters from selective cell.
%
%%%%%%%%%%

global imgobj
global sobj

%%
if ~ isfield(imgobj, 'dFF_s_each')
    errordlg('Get Trial Averages!')
    
    
    %%
else
    switch sobj.pattern
        case {'Uni', 'FineMap'}
            if ~isfield(imgobj, 'dFF_boot_med')
                [R_boot_med, b_GaRot2D, Ci_GaRot2D, b_Ellipse] = ...
                    Get_Boot_RF(imgobj);
                
                imgobj.dFF_boot_med = R_boot_med;
                imgobj.b_GaRot2D = b_GaRot2D;
                imgobj.Ci_GaRot2D = Ci_GaRot2D;
                imgobj.b_Ellipse = b_Ellipse;
                
                %plot ‚¾‚¯•ª‚¯‚½‚¢‚ª
            else
                %Plot only
                i_roi = 1:imgobj.maxROIs;
                i_roi = i_roi(imgobj.b_GaRot2D(:,1) >= 0.15);
                if get(check_box, 'Value')
                    Plot_RF_selected(i_roi);
                end
            end
            
        case {'MoveBar', 'Rect'}
            if ~isfield(imgobj, 'P_boot')
                disp('Bootstrapping...')
                
                [R_boot_med, P_boot, roi_ds, roi_os, b_ds, b_os, Ci_ds, Ci_os, f_ds, f_os]...
                    = Get_Boot_DOSI(imgobj);
                
                imgobj.dFF_boot_med = R_boot_med;
                imgobj.P_boot = P_boot;
                imgobj.f_ds = f_ds;
                imgobj.f_os = f_os;
                imgobj.roi_ds = roi_ds;
                imgobj.roi_os = roi_os;
                imgobj.b_ds = b_ds;
                imgobj.b_os = b_os;
                imgobj.Ci_ds = Ci_ds;
                imgobj.Ci_os = Ci_os;
                
                %Reget stim average
                Get_Trial_Averages([],[],0);
                Plot_All_Averages([], [], -1, 1);
                
            else
                %Plot only
                errordlg('Already calculated.')
            end
            
        case 'StaticBar'
            if ~isfield(imgobj, 'P_boot')
                disp('Bootstrapping...')
                
                [R_boot_med, P_boot, roi_os, b_os, Ci_os, f_os] =...
                    Get_Boot_BarOS(imgobj);
                
                imgobj.dFF_boot_med = R_boot_med;
                imgobj.P_boot = P_boot;
                imgobj.f_os = f_os;
                imgobj.roi_os = roi_os;
                imgobj.b_os = b_os;
                imgobj.Ci_os = Ci_os;
                
            else
                %Plot only
                errordlg('Already calculated.')
            end
    end
end

%%





end % END OF "Get_Fit_Params2"
