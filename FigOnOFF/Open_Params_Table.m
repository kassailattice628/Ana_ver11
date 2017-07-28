function Open_Params_Table(hfig_handle, r, s)
global hfig
h_name =  'params_table';
hfig.params_table = figure('Position', [1010, 20, 360, 460], 'Name', 'Parameters',...
    'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off',...
    'DeleteFcn', {@Close_subwindow, hfig_handle, h_name});

[rnames, values]= Get_stim_param_values(r, s);

hfig.params_table_contents = uitable(hfig.params_table,...
    'Data', values,...
    'ColumnName','Value', 'ColumnWidth',{100}, 'ColumnFormat', {'char'}, ...
    'RowName',rnames,...
    'position',[5 0 350 300]);


%Set table width and height
hfig.params_table_contents.Position(2) =  455 - hfig.params_table_contents.Extent(4)-5;
hfig.params_table_contents.Position(3) =  hfig.params_table_contents.Extent(3);
hfig.params_table_contents.Position(4) =  hfig.params_table_contents.Extent(4);
%}
end