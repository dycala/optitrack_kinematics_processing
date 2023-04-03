
function [Reach] = add_stim(Reach,stimtime)

%% Adds stim to Reach file

check = exist('stimtime');
mid = ceil(length(Reach(1).real_kin)/2);
if check == 1
    for i=1:length(Reach)
        for ii=1:length(stimtime)
            if Reach(i).out(1,1)<stimtime(ii,1) && Reach(i).out(end,1)>stimtime(ii,1)
                Reach(i).stim = 1
                Reach(i).stimtime = stimtime(ii,1)
                if size(stimtime,2) == 2
                    [~,idx] = min(abs(Reach(i).out(:,1)-stimtime(ii,1)));
                    Reach(i).stimtloc = Reach(i).out(idx,2) ;  
                end
                break
            end
        end
    end
end

% find nonstimed reaches
for i = 1:length(Reach)
    if Reach(i).stim == 1
        first = i;
        break
    end
end

for i = 1:length(Reach)
    if Reach(i).stim == 1
        last = i;
    end
end

% add pre and post stim'd reaches
for i = 1:length(Reach)
    if i < first
        Reach(i).stim= 0;
    elseif i>last
        Reach(i).stim=2;
    end
end



