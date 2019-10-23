function [img, i_with_opt] = Remove_opt_frames(img)
%
% Remove frames with optpgenetics stimulation, which contatin maximum
% intensity (4095).
% img: Tiff stack
% f0s: Maximum frame number for f0
% P: ParamsSave;

global imgobj
global ParamsSave

f0s = GetF0;

if isfield(imgobj, 'FVsampt')
    fv_sampt = imgobj.FVsampt;
    %fv_sampt = 0.574616;
else
    fv_sampt = input('Set frame time per sec: ');
    
end

%%

f0 = 1:f0s; % no visual stim trials.

i_with_opt = find(max(max(img == 4095)))';

i_me_fr = setdiff(f0, i_with_opt);
mean_frame = mean(img(:,:,i_me_fr),3);

% Frames with 4095 intensity during visual stimulation

time_frame = (0:size(img,3)) * fv_sampt;

i_vis =[];

if ~isempty(ParamsSave)
    for i = 1:size(ParamsSave,2)
        if isfield(ParamsSave{i}, 'stim1')
            %stim start
            t1 = ParamsSave{i}.AIStartTime + ParamsSave{i}.stim1.On_time;
            t2 = ParamsSave{i}.AIStartTime + ParamsSave{i}.stim1.Off_time;
            i_f = intersect(find(time_frame >= t1), find(time_frame < t2));
            i_vis = [i_vis, i_f];
        end
    end
end

% i_vis ‚Æ‹¤’Ê‚Ì i_with_opt
for i = setdiff(i_with_opt, i_vis)
    img(:,:,i) = mean_frame;
end

end