function [stimtime] = get_stim_time(Expt)

%%
a=1;
for i=1:length(Expt)
    if Expt(i,5) == 1
        stimtime(a,1) = Expt(i,1);
        stimtime(a,2) = Expt(i,2);
        a=a+1;
    end
end
