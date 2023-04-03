

function [reaches,mean_drop] = qm_exclude(reaches,qm_thresh,frame_rate)


%% Get quality metric and exclude low quality reaches
for i = 1:length(reaches)
    
    % get timepoints during outreach
    time = round(reaches(i).out(end,1)-reaches(i).out(1,1),3);
    
    %calculate number of frames that should have been recorded given
    %framerate
    steps = round(time/(1/frame_rate));
    
    % calculate % dropped
    reaches(i).qm = (size(reaches(i).out,1)-1)/steps;

    % mark as excluded if necessary 
    if reaches(i).qm < qm_thresh 
        reaches(i).exclude = 1;
    elseif isnan(reaches(i).qm)
        reaches(i).exclude = 1;
    else
        reaches(i).exclude = 0;
    end

end

mean_drop = (1-nanmean([reaches(:).qm]));

         
