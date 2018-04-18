function s_each = Delete_event(s_each, show, th, idx)
%%%%%%%%%%
%
% Check event and delete strange event
%
% show =: 0/1, if '1', plot dFF_s_eahc and check
% th =: threshold for std value, which defines strange event
% idx =: roi
%
%%%%%%%%%%

global imgobj
%s_each = imgobj.dFF_s_each;
%%
if nargin == 1
    show = 0;
    th = 1;
    idx = [];
else
    if show == 1
        
    end
    
    if length(idx) > 1
        errordlg('multiple idx are not supported.')
    end
end

%%
if isempty(idx)
    % for all roi
    roi_std = nanstd(s_each);
    [val_std, i2] = max(roi_std);
    val_std = reshape(val_std, [imgobj.maxROIs, 1]);
    i2 = reshape(i2, [imgobj.maxROIs, 1]);
    roi_ch = find(val_std > th);
    
else
    roi_ch = idx;
    roi_std = nanstd(s_each(:,:, roi_ch));
    [val_std, i2] = max(roi_std);
    if val_std > th
        %i2 = reshape(i2, [imgobj.maxROIs, 1]);
    end
end


%% show each event
if show == 0
    % delete detected event
    for i = roi_ch'
        [~, i3] = nanmax(s_each(:, i2(i),i));
        s_each(i3, i2(i), i) = NaN;
    end
 
elseif show == 1
    % not delete event, just show
    for i = roi_ch
        x = [];
        y = [];
        events = rmmissing(s_each(:,:,i));
        
        for j = 1:size(events,2)
            x = [x; repmat(j, size(events,1),1)];
            y = [y; events(:, j)];
        end
        figure
        scatter(x, y, '*b');
    end
end

%%
end