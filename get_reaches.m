
function [ReachS] = get_reaches(Expt, dtaoffset, threshold, Startpoint, Endpoint,r_act_time)
    
    %% Get Reaches
    
    new_ts = [];
    t = Expt(:,1);
    dt = diff(t);
    
    %loop through diff times and calculate new times for interped data
    for num = 1:length(dt)
        tspace = dt(num)/.0083;
        intgr = floor(tspace);
        if intgr < 2
            continue
        end
        newt = linspace(t(num),t(num+1),intgr);
        new_ts = [new_ts newt];
    end
    new_t = union(t,new_ts);
    
    %interp it and convert from optitrack units to cm
    x = interp1(t,Expt(:,2),new_t)*10;
    y = interp1(t,Expt(:,3),new_t)*10;
    z = interp1(t,Expt(:,4),new_t)*10;
    Intrp = [new_t  x  y  z];
    
    % get the velocity and acceleration
    times = Intrp(:,1);
    t = gradient(times);
    
    xv = gradient(Intrp(:,2))./t;
    yv = gradient(Intrp(:,3))./t;
    zv = gradient(Intrp(:,4))./t;
    vcomps = [xv yv zv];
    v = sqrt(sum(vcomps.^2,2));
    
    Intrp(:,5) = v;
    Intrp(:,6) = xv;
    Intrp(:,7) = yv;
    Intrp(:,8) = zv;
    
    xa = gradient(Intrp(:,6))./t;
    ya = gradient(Intrp(:,7))./t;
    za = gradient(Intrp(:,8))./t;
    acomps = [xa ya za];
    a = sqrt(sum(acomps.^2,2));
    
    Intrp(:,9) = a;
    Intrp(:,10) = xa;
    Intrp(:,11) = ya;
    Intrp(:,12) = za;
    
    % filter data with a lowpass butterworth filter. 10Hz cutoff (10/(120/2)) (cutoff / 0.5*camera sampling frequency)
    [f1,f2] = butter(2,.1667);
    filtered = [Intrp(:,1) filtfilt(f1,f2,Intrp(:,2:8))];
    
    % only keep data at real points
    Expt2 = filtered(ismember(filtered(:,1),Expt(:,1)),:);
    
    % offset data by some interval to align to neural data timebase
    Expt2(:,1) = Expt2(:,1) + dtaoffset;
    filtered(:,1) = filtered(:,1) + dtaoffset;
    if nargin>5
        r_act_time = r_act_time + dtaoffset;
    end
    
    %% Find threshold crosses
    
    %Find points where paw passes x positional threshold and was behind
    %threshold 25 points previously (not re-reach)
    cross_x = [];
    for pt = 26:length(Expt2)-1
        if Expt2(pt,2)>=threshold  && Expt2(pt-1,2)<threshold && Expt2(pt+1,2)>=threshold && Expt2(pt-25,2)<threshold
            cross_x = [cross_x;pt-1];
        end
    end
     
    % if reach key press was not used remove any rereaches within 5 seconds of
    % previous
    if nargin<=5
        
        temp = ones(length(cross_x),1);
        for i=1:length(cross_x)-1
            if Expt2(cross_x(i+1),1)-Expt2(cross_x(i),1)<5
                temp(i+1,1)=0;
            end
        end
        cross_x = cross_x(temp ~= 0);
    
    % if reach key press was used just use that to find first reaches 
    elseif nargin>5
        
        kp = false(length(cross_x),1);
        for i= 1:length(r_act_time)
    
            for ii =  1:length(cross_x)
    
                % find if cross point was within 5 seconds of keypress 
                if Expt2(cross_x(ii),1) <= r_act_time(i)+5 && Expt2(cross_x(ii),1) > r_act_time(i)
                    kp(ii) = true;
                    break  
                end
                
            end
    
        end
        cross_x = cross_x(kp == true);  
    
    end
      
    %% clip out reaches
    
    % remove reaches that don't have tails of 5s for clipping
    cross_x = cross_x((cross_x+600)<length(Expt2));
    cross_x = cross_x((cross_x-600)>0);
    
    % clip reaches
    for num=1:length(cross_x)
        
        % only original points
        ReachS(num).real_kin = Expt2(cross_x(num)-600:cross_x(num)+600,:);
    
        % filted points
        [~,idx] = min(abs(filtered(:,1) - Expt2(cross_x(num),1)));
        ReachS(num).filt_kin=filtered(idx-600:idx+600,:);
        
    end
    
    
    % get outward component of reach
    mid = ceil(length(ReachS(1).real_kin)/2);
    for num = 1:length(ReachS)
        
        for ii = mid:length(ReachS(num).real_kin)
            if ReachS(num).real_kin(ii,6)<0
                stop = ii;
                break
            end
        end
    
        %walk back from threshold to find when reach started (under 
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
       
    
    % remove any clips where tracked points were outside possible reach zone. 
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

