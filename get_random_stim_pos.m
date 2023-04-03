
function VC = get_random_stim_pos(VC,ided,ReachS,interval)
    % find index of mid position of reach, stim index position, and stim
    % threshold 

    whichStim = round([ReachS(:).stimtime],3)';
    stimThresh = ided.m1(ided.m1(:,5) == 1,1:6);
    tk_thresh = sum(whichStim'==round(stimThresh(:,1),3),2);
    stimThresh = stimThresh(tk_thresh == 1,6);
    stim_location = [ReachS(:).stimtloc];

    % for each reach
    n=1;
    b=1;
    for ii = 1:length(ReachS)
        if ReachS(ii).stim == 1
            if ReachS(ii).exclude == 0 
                idxmid = 602;
                [~,idx] = min(abs(ReachS(ii).real_kin(:,1)-ReachS(ii).stimtime));
               
                VC.stimidxmid(n) = floor((ReachS(ii).real_kin(idx,1)-ReachS(ii).real_kin(idxmid,1))/interval);
                VC.stimidxpos(n) = stim_location(n);
                VC.stimThresh(n) = stimThresh(b)*10; % optitrack units
                n=n+1;
                b=b+1;
            else
                b=b+1;
            end
            
        end
    end

end