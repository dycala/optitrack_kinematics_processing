function format_reach_exp_random(path_name,save_name)

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
   
    % velocity curve
    [VC] = get_VC(ReachS,interval);
    [success_quant] = get_success(fail,sucs,sucd,ReachS);

    % get stim positions and thresholds
    VC = get_random_stim_pos(VC,ided,ReachS,interval);

    save(save_name,'VC','success_quant')

end