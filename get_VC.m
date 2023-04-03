function [VC] = get_VC(ReachS,interval)

tails = 240; % 2s
mid = ceil(length(ReachS(1).filt_kin)/2);
for i = 1:length(ReachS)
    new_t = [ReachS(i).filt_kin(mid,1)-2:interval:ReachS(i).filt_kin(mid,1)+2]';
    t = ReachS(i).filt_kin(mid-tails:mid+tails,1);
    %interpolate
    pos = interp1(t,ReachS(i).filt_kin(mid-tails:mid+tails,2:4),new_t);
    vel = interp1(t,ReachS(i).filt_kin(mid-tails:mid+tails,5:8),new_t);
    ReachS(i).velcurve = [new_t pos vel];

end

for ii = 2:8
    a=1;b=1;c=1;
    for i = 1:length(ReachS)
        if ReachS(i).exclude == 0
            if ReachS(i).stim == 0
                VC.prestim(ii-1).kin(:,a) = ReachS(i).velcurve(:,ii);
                a=a+1;
            elseif ReachS(i).stim == 1
                VC.stim(ii-1).kin(:,b) = ReachS(i).velcurve(:,ii);
                b=b+1;
            elseif ReachS(i).stim == 2    
                VC.poststim(ii-1).kin(:,c) = ReachS(i).velcurve(:,ii);
                c=c+1;
            end
        end
    end
end


