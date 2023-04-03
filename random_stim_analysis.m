

function random_results = random_stim_analysis(mouse_directory_path,analysis_window,kin)
    
    %% Kinematic quantification for random stim experiments
    % input is the directory that contains the files of processed
    % kinematics files for each mouse
    %mouse_directory_path = "\\data.ucdenver.pvt\dept\SOM\PHYS\PHYS\PersonLabIsilon\Dylan\Paper Data\Random Stim\Results"
    mouse_directory = dir(mouse_directory_path);
    mouse_directory = mouse_directory(3:end);
    mouse_directory(5:30) = [];
    
    % will clip data with 100 point flanks around stimulated point so stim will be from 101 to 105, 50 ms after is 106:110
    mid = 202;
    indices = 106:110;
    flank = 100;

    for mouse = 1:length(mouse_directory)
        clearvars -except random_results mid flank indices mouse_directory mouse_directory_path mouse kin...
            ts_stimearly ts_stimmid ts_stimend ts_postearly ts_postmid ts_postlate...
            window_stimearly window_stimmid window_stimlate window_postearly window_postmid window_postlate   
        
        % get files
        pathloc = mouse_directory_path + "\" + mouse_directory(mouse).name;
        cd(pathloc)
        directory = dir('*.mat'); 
    
        % load sessions for each mouse
        for i = 1:length(directory)
           load(directory(i).name);
           VT(i).VC = VC;
        end
        
        session_baseline = [];
        % analyze all sessions in each mouse
        for i = 1:length(VT)
            
            % get baseline reaches   
            session_baseline = [session_baseline, nanmean(VT(i).VC.prestim(kin).kin(:,end-4:end),2)];
            pOut = nanmean(VT(i).VC.prestim(1).kin(:,end-4:end),2);
            vOut = nanmean(VT(i).VC.prestim(5).kin(:,end-4:end),2);
            vUp = nanmean(VT(i).VC.prestim(6).kin(:,end-4:end),2);
                    
            % find indices for mid5 reaches
            idxs = floor(size(VT(i).VC.stim(kin).kin,2)/2);% was floor
            idxp = floor(size(VT(i).VC.poststim(kin).kin,2)/2);% was floor
            
            % get values for stim'd reaches    
            stimSubEarly = []; stimSubMid = []; stimSubLate = []; 
            for trial_num = 1:size(VT(i).VC.stim(kin).kin,2)
               
                % search 200 ms in outreach for stim location (50ms before then
                % thereshold + 140 (150))
                st_pos =  VT(i).VC.stimThresh(trial_num); 
                start = mid-5; 
                stop = mid+14; 
                
                % find reach alignment to stimulated point  
                pOut2 = nanmean(VT(i).VC.stim(1).kin(:,trial_num),2);
                reach = pOut2(start:stop);
                [~,idx2] = min(abs(reach-st_pos));
                if reach(idx2)<st_pos
                    idx2 = idx2 +1;
                end
                idx2 = start+idx2-1;
                stalign = VT(i).VC.stim(kin).kin(idx2-flank:idx2+flank,trial_num);
                            
                % find baseline average to stimulated point
                reach = pOut(start:stop);
                [~,idx] = min(abs(reach-st_pos));
                if reach(idx)<st_pos
                    idx = idx +1;
                end
                alig = idx+start-1;
                bsalign = session_baseline(alig-flank:alig+flank,i);
                                
                % get reach difference
                subreach = stalign-bsalign;
                    
                % collect early reaches
                if trial_num==1
                    stimSubEarly = subreach;
                end
                % collect middle reaches
                if trial_num >= idxs-2 && trial_num<= idxs+2
                    stimSubMid = [stimSubMid,subreach];
                end
                % collect late reaches
                if trial_num >= size(VT(i).VC.stim(kin).kin,2)-4 && trial_num<= size(VT(i).VC.stim(kin).kin,2)
                    stimSubLate = [stimSubLate,subreach];
                end
            end
    
            % get washout reaches, here just align to midpoint 
            postSubEarly = []; postSubMid = []; postSubLate = []; 
            for trial_num = 1:size(VT(i).VC.poststim(kin).kin,2)
                            
                % collect early reaches
                if trial_num == 1
                    postSubEarly = [postSubEarly,VT(i).VC.poststim(kin).kin(mid-flank:mid+flank,trial_num)-session_baseline(mid-flank:mid+flank,i)];
                end

                % collect middle reaches
                if trial_num >= idxp-2 && trial_num<= idxp+2
                    postSubMid = [postSubMid,VT(i).VC.poststim(kin).kin(mid-flank:mid+flank,trial_num)-session_baseline(mid-flank:mid+flank,i)];
                end

                % collect late reaches
                if trial_num >= size(VT(i).VC.poststim(kin).kin,2)-4 && trial_num<= size(VT(i).VC.poststim(kin).kin,2)
                    postSubLate = [postSubLate,VT(i).VC.poststim(kin).kin(mid-flank:mid+flank,trial_num)-session_baseline(mid-flank:mid+flank,i)];
                end
            end
            
            % average stimed reaches for each session in an animal
            ts_session_stimSubEarly(:,i) = nanmean(stimSubEarly,2);
            ts_session_stimSubMid(:,i) = nanmean(stimSubMid,2);
            ts_session_stimSubLate(:,i) = nanmean(stimSubLate,2);
            ts_session_postSubEarly(:,i) = nanmean(postSubEarly,2);
            ts_session_postSubMid(:,i) = nanmean(postSubMid,2);
            ts_session_postSubLate(:,i) = nanmean(postSubLate,2);

            
            window_session_stimSubEarly(i) = nanmean(nanmean(stimSubEarly(indices,:),1),2);
            window_session_stimSubMid(i) = nanmean(nanmean(stimSubMid(indices,:),1),2);
            window_session_stimSubLate(i) = nanmean(nanmean(stimSubLate(indices,:),1),2);
            window_session_postSubEarly(i) = nanmean(nanmean(postSubEarly(indices,:),1),2);
            window_session_postSubMid(i) = nanmean(nanmean(postSubMid(indices,:),1),2);
            window_session_postSubLate(i) = nanmean(nanmean(postSubLate(indices,:),1),2);
                        
    
        end

        % average all sessions for individual animals for timeseries data            
        ts_stimearly(:,mouse) = nanmean(ts_session_stimSubEarly,2);
        ts_stimmid(:,mouse) = nanmean(ts_session_stimSubMid,2);
        ts_stimend(:,mouse) = nanmean(ts_session_stimSubLate,2);
        ts_postearly(:,mouse) = nanmean(ts_session_postSubEarly,2);
        ts_postmid(:,mouse) = nanmean(ts_session_stimSubMid,2);
        ts_postlate(:,mouse) = nanmean(ts_session_stimSubLate,2);

        % average all sessions for individual animals for analysis window data          
        window_stimearly(mouse) = mean(window_session_stimSubEarly);
        window_stimmid(mouse) = mean(window_session_stimSubMid);
        window_stimlate(mouse) = mean(window_session_stimSubLate);
        window_postearly(mouse) = mean(window_session_postSubEarly);
        window_postmid(mouse) = mean(window_session_postSubMid);   
        window_postlate(mouse) = mean(window_session_postSubLate);    
    
    end

    random_results.window(:,1) = window_stimearly';
    random_results.window(:,2) = window_stimmid';
    random_results.window(:,3) = window_stimlate';
    random_results.window(:,4) = window_postearly';
    random_results.window(:,5) = window_postmid';
    random_results.window(:,6) = window_postlate';
    
    random_results.ts.stimearly = ts_stimearly;
    random_results.ts.stimmid = ts_stimmid;
    random_results.ts.stimlate = ts_stimend;
    random_results.ts.postearly = ts_postearly;
    random_results.ts.postmid = ts_postmid;
    random_results.ts.postlate = ts_postlate;

end
