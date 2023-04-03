
function format_reach_exp_positional(path_name,save_name)
    %path_name = 'C:\Users\dylan\Downloads\Dylan_201211_fChR6_Stim.mat'; % data location
    %save_name = ''; % save location
    interval = 0.01; % in seconds
    qm_thresh = 0.75; % percent tracked points
    threshold = 1.0; % reach crossing threshold
    framerate = 120;
    
    load(path_name)
    
    % consolidate markers into single data stream
    mark = MocapOrg(dta);
    ided = assign_identity3(mark);
    
    %filter data and pull out reaches
    Startpoint = ided.m1(1,1);
    Endpoint = ided.m1(end,1);
    if exist('r_act_time') % detect whether reach button press was used
        [ReachS] = get_reaches(ided.m1, 0, threshold, Startpoint, Endpoint,r_act_time);
    else
        [ReachS] = get_reaches(ided.m1, 0, threshold, Startpoint, Endpoint);
    end
    
    % get stimtime
    [stimtime] = get_stim_time(ided.m1);
    
    %% exclude poorly tracked reaches
    [ReachS] = qm_exclude(ReachS,qm_thresh,framerate);
    
    [ReachS] = add_stim(ReachS,stimtime);
    
    % exclude stim'd reaches that were 2 mm past threshold crossing
    [ReachS] = exclude_far_stim(ReachS,1.2);
    
    % velocity curve
    [VC] = get_VC(ReachS,interval);
    [success_quant] = get_success(fail,sucs,sucd,ReachS);
    
    save(save_name,'VC','success_quant')

end