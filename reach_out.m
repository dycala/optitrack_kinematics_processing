function [ReachS] = reach_out(ReachS)

   % get outward component of reach
    mid = ceil(length(ReachS(1).real_kin)/2);
    for num = 1:length(ReachS)

        for ii = mid:length(ReachS(num).real_kin)
            if ReachS(num).real_kin(ii,6)<0
                stop = ii;
                break
            end
        end

        %walk back from threshold to find when reach started
        for ii =mid:-1:mid-100 % 1:100 
            if ReachS(num).real_kin(ii,6)<2  && ReachS(num).real_kin(ii,7)<2  && ReachS(num).real_kin(ii,2)<0.5 
                start = ii;
                break
            else
                start = ii;
            end
        end

        % find reach start (100 ms to threshold)
        ReachS(num).out = ReachS(num).real_kin(start:stop,:);

    end

    % remove any threshold crosses that were outside reach zone 
    too_high = 2.5; %in cm on y axis
    too_far = 3.0;
    toDel = false(length(ReachS),1);
    for i=1:length(ReachS)
        for ii=1:size(ReachS(i).out,1)
            if ReachS(i).out(ii,3) > too_high || ReachS(i).out(ii,2) > too_far 
                toDel(i) = true;
                break
            end            
        end
    end
    ReachS = ReachS(toDel == false);

    %remove blips 
    toDel = false(length(ReachS),1);
    for i=1:length(ReachS)
            if size(ReachS(i).out,1)<5
                toDel(i) = true;
            end            
    end
    ReachS = ReachS(toDel == false);
    
end