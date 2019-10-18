fn = 4;
fpath = '/Volumes/pSSD_T1/190226mat/386/SC_';%4_.mat';

s_add = [];
s_ave = [];


for i = 1:length(fn)
    
    fname = [fpath, num2str(fn(i)), '_.mat'];
    load(fname)
    s_ = imgobj.dFF_s_each;
    ave_ = imgobj.dFF_s_ave;
    
    if i == 1
        roi_n = size(s_,3);
    end
    
    count = 0;
    
    % retreive data
    a = min(isnan(s_(:,:,1)),[],2);
    len_a0 = length(a(a==0));
    
    %concat data
    s_add = cat(1, s_add, s_(a==0,:,1:roi_n));
    %s_ave = cat(1, s_ave, 
end

%%%
catobj = Get_Stim_Tuning_cat(s_add);

%%%
