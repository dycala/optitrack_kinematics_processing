
function position_results = position_stim_analysis(mouse_directory_path,analysis_window,kin)
    %% Kin quantification for indices
    
    mouse_directory = dir(mouse_directory_path);
    mouse_directory = mouse_directory(3:end);
    
    % stim starts at 202 and goes to 206( 50 ms after)
    if analysis_window == 'after_stim'
        indices = 207:211; % 50 ms after stim ends
    elseif  analysis_window == 'during_stim'
        indices = 201:206; % during stim window
    elseif analysis_window == 'before_stim'
        indices = 197:201; % 50 ms before
    end
    
    for mouse = 1:length(mouse_directory)
        clearvars -except mouse_directory mouse_directory_path mouse kin indices notlong stimSubEarly stimSubMid stimSubLate postSubEarly postSubMid postSubLate ts_stimSubEarly ts_stimSubMid ts_stimSubLate ts_postSubEarly ts_postSubMid ts_postSubLate
        % get files
        pathloc = mouse_directory_path + "\" + mouse_directory(mouse).name;
        cd(pathloc)
        directory = dir('*.mat'); 
    
        % load 
        for i = 1:length(directory)
           cd(pathloc)
           load(directory(i).name);
           VT(i).VC = VC;
           clear VC 
        end
         
        % find difference with stim and post stim reaches relative to baseline
        % in analysis window or between timeseries
        num = 1;
        for i = 1:length(VT)

            % find midpoint of block for stim and post stim
            idxs = floor(size(VT(i).VC.stim(kin).kin,2)/2);
            idxp = floor(size(VT(i).VC.poststim(kin).kin,2)/2);
    
            if size(VT(i).VC.stim(kin).kin,2)>=6 && size(VT(i).VC.poststim(kin).kin,2)>=6 && size(VT(i).VC.prestim(kin).kin,2)>=6
    
                % for difference from baseline in kinematic window
                window_baseline(num) = nanmean(nanmean(VT(i).VC.prestim(kin).kin(indices,end-4:end),1),2);
                window_stimsubearly(:,num) = nanmean(nanmean(VT(i).VC.stim(kin).kin(indices,1),1),2) - window_baseline(num);
                window_stimsubmid(:,num) = nanmean(nanmean(VT(i).VC.stim(kin).kin(indices,idxs-2:idxs+2),1),2) - window_baseline(num);
                window_stimsublate(:,num) = nanmean(nanmean(VT(i).VC.stim(kin).kin(indices,end-4:end),1),2) - window_baseline(num);
                window_postsubearly(:,num) = nanmean(nanmean(VT(i).VC.poststim(kin).kin(indices,1),1),2) - window_baseline(num);
                window_postsubmid(:,num) = nanmean(nanmean(VT(i).VC.poststim(kin).kin(indices,idxp-2:idxp+2),1),2) - window_baseline(num);
                window_postsublate(:,num) = nanmean(nanmean(VT(i).VC.poststim(kin).kin(indices,end-4:end),1),2) - window_baseline(num);
                    
                % for difference from baseline in kinematic timeseries
                ts_trial_baseline(:,num) = nanmean(VT(i).VC.prestim(kin).kin(:,end-4:end),2);
                ts_trial_stimsubearly(:,num) = nanmean(VT(i).VC.stim(kin).kin(:,1),2) - ts_trial_baseline(:,num);
                ts_trial_stimsubmid(:,num) = nanmean(VT(i).VC.stim(kin).kin(:,idxs-2:idxs+2),2) - ts_trial_baseline(:,num);
                ts_trial_stimsublate(:,num) = nanmean(VT(i).VC.stim(kin).kin(:,end-4:end),2) - ts_trial_baseline(:,num);
                ts_trial_postsubearly(:,num) = nanmean(VT(i).VC.poststim(kin).kin(:,1),2) - ts_trial_baseline(:,num);
                ts_trial_postsubmid(:,num) = nanmean(VT(i).VC.poststim(kin).kin(:,idxp-2:idxp+2),2) - ts_trial_baseline(:,num);
                ts_trial_postsublate(:,num) = nanmean(VT(i).VC.poststim(kin).kin(:,end-4:end),2) - ts_trial_baseline(:,num);
    
                num = num+1;
            end
        end
        
        % window avg
        
        
        stimSubEarly(:,mouse) = nanmean(window_stimsubearly,2);
        stimSubMid(:,mouse) = nanmean(window_stimsubmid,2);
        stimSubLate(:,mouse) = nanmean(window_stimsublate,2);
        postSubEarly(:,mouse) = nanmean(window_postsubearly,2);
        postSubMid(:,mouse) = nanmean(window_postsubmid,2);
        postSubLate(:,mouse) = nanmean(window_postsublate,2);
    
        % timeseries avg
        ts_stimSubEarly(:,mouse) = nanmean(ts_trial_stimsubearly,2);
        ts_stimSubMid(:,mouse) = nanmean(ts_trial_stimsubmid,2);
        ts_stimSubLate(:,mouse) = nanmean(ts_trial_stimsublate,2);
        ts_postSubEarly(:,mouse) = nanmean(ts_trial_postsubearly,2);
        ts_postSubMid(:,mouse) = nanmean(ts_trial_postsubmid,2);
        ts_postSubLate(:,mouse) = nanmean(ts_trial_postsublate,2);
        
    end
    
    position_results.window(:,1) = stimSubEarly';
    position_results.window(:,2) = stimSubMid';
    position_results.window(:,3) = stimSubLate';
    position_results.window(:,4) = postSubEarly';
    position_results.window(:,5) = postSubMid';
    position_results.window(:,6) = postSubLate';
    
    position_results.ts.stimearly = ts_stimSubEarly;
    position_results.ts.stimmid = ts_stimSubMid;
    position_results.ts.stimlate = ts_stimSubLate;
    position_results.ts.postearly = ts_postSubEarly;
    position_results.ts.postmid = ts_postSubMid;
    position_results.ts.postlate = ts_postSubLate;

end

