function Plot_DSOS_selected
%
%%%%%%%%%% %%%%%%%%%% %%%%%%%%%% %%%%%%%%%%

global imgobj

%%%%%%%%%% %%%%%%%%%% %%%%%%%%%% %%%%%%%%%%

if ~isfield(imgobj, 'P_boot')
    errordlg('Please Get DS/OS first!')
    
else
    
    for i = imgobj.selectROI
        %Colore is set acoording to the tuning properties.
        if ismember(i, imgobj.roi_no_res)
            Plot_DSOS([],[], imgobj.directions, imgobj.dFF_boot_med(:,i)', i, [])
            
        elseif ismember(i, imgobj.roi_nega_R)
            Plot_DSOS([],[], imgobj.directions, imgobj.dFF_boot_med(:,i)', i, [])
            
        else
            if ismember(i, imgobj.roi_ds)
                disp('DS')
                f_vM = Select_vonMises(imgobj.f_ds(i));
                b_fit = imgobj.b_ds(i,:);
                if b_fit(5) == 0 && b_fit(6) == 0
                    b_fit(5:6) = [];
                end
                Plot_DSOS(f_vM, b_fit, imgobj.directions, imgobj.dFF_boot_med(:,i)', i, 1)
                
            end
            
            if ismember(i, imgobj.roi_os)
                disp('OS')
                f_vM = Select_vonMises(imgobj.f_os(i));
                b_fit = imgobj.b_os(i,:);
                
                Plot_DSOS(f_vM, b_fit, imgobj.directions, imgobj.dFF_boot_med(:,i)', i, 2)
            end
            
            is_nonsel = ismember(i, imgobj.roi_res) && ~ismember(i, imgobj.roi_ds)...
                && ~ismember(i, imgobj.roi_os');
            if is_nonsel
                
                Plot_DSOS([],[], imgobj.directions, imgobj.dFF_boot_med(:,i)', i, [])
            end
            
        end
        
    end
end
end