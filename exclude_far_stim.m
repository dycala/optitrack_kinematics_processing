function [Reach_reg] = exclude_far_stim(Reach_reg,loc)

%% 
for i = 1:length(Reach_reg)
    if Reach_reg(i).stim == 1
        if Reach_reg(i).stimtloc > loc 
            Reach_reg(i).exclude = 1;
        end
    end
end