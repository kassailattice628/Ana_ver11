function Divide_Fall(Fall_path, divnum)

%load all data:: 'F', 'Fneu', 'iscell', 'spks', 'ops', 'stat'
Fall = load(Fall_path);

%Fall = cell(1,length(divnum));

for i = 1:length(divnum)
    if i == 1
        i1 = 1;
    else 
        i1 = divnum(i-1)+1;
    end
    range = i1: i1+ divnum(i) - 1;
    
    disp(i)
    [F, Fneu, spks] = divide_data(Fall.F, Fall.Fneu, Fall.spks, range);

    iscell = Fall.iscell;
    ops = Fall.ops;
    stat = Fall.stat;
    
    save_path = Set_save_path(Fall_path, i);
    save(save_path, 'F', 'Fneu', 'iscell', 'spks', 'ops', 'stat');
end

end


function save_path = Set_save_path(fp, n)

n = num2str(n);
[dname, fname, ext] = fileparts(fp);
save_path = [fullfile(dname, fname), '_', n, ext];

end

function [F, Fneu, spks] = divide_data(F, Fneu, spks, range)
    F = F(:, range);
    Fneu = Fneu(:, range);
    spks = spks(:, range);
end