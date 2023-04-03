function [success_quant] = get_success(fail,sucs,sucd,ReachS)
%%
for i = 1:length(ReachS)
    if ReachS(i).stim == 1
        stimstart = ReachS(i).stimtime ;
        break
    end
end

for i = 1:length(ReachS)
    if ReachS(i).stim == 2
        poststart = ReachS(i).real_kin(602,1) ;
        break
    end
end


t1 = fail(fail<stimstart);
t1(:,2) = 0;
t2 = sucs(sucs<stimstart);
t2(:,2) = 1;
t3 = sucd(sucd<stimstart);
t3(:,2) = 2;
temp = [t1;t2;t3];
success_quant.prestim = sortrows(temp,1);
clear t1 t2 t3 temp

t1 = fail(logical([fail>stimstart] .* [fail<poststart]));
t1(:,2) = 0;
t2 = sucs(logical([sucs>stimstart] .* [sucs<poststart]));
t2(:,2) = 1;
t3 = sucd(logical([sucd>stimstart] .* [sucd<poststart]));
t3(:,2) = 2;
temp = [t1;t2;t3];
success_quant.stim = sortrows(temp,1);
clear t1 t2 t3 temp

t1 = fail(fail>poststart);
t1(:,2) = 0;
t2 = sucs(sucs>poststart);
t2(:,2) = 1;
t3 = sucd(sucd>poststart);
t3(:,2) = 2;
temp = [t1;t2;t3];
success_quant.poststim = sortrows(temp,1);
clear t1 t2 t3 temp

