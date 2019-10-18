function Remove_EyeMove_Event

global imgobj

Get_Trial_Averages_RemoveEYE_Event;

if isfield(imgobj, 'P_boot')
    imgobj = rmfield(imgobj, 'P_boot');
end

%Fit and Calc DSI/OSI 
Get_Fit_params2([])

end