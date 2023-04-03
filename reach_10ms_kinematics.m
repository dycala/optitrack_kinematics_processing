function [ReachS] = reach_10ms_kinematics(ReachS,filter_data)

    for ii = 1:length(ReachS)
        t = ReachS(ii).real_kin(:,1);
        st_pt=round(ReachS(ii).real_kin(1,1),3);
        end_pt=round(ReachS(ii).real_kin(end,1),3);
        new_t = st_pt:0.010:end_pt;
        new_t = new_t';
        %interp it (also convert to optitrack units)
        x = interp1(t,ReachS(ii).real_kin(:,2),new_t);
        y = interp1(t,ReachS(ii).real_kin(:,3),new_t);
        z = interp1(t,ReachS(ii).real_kin(:,4),new_t);
        Intrp = [new_t  x  y  z];
        %% get the velocity then acceleration
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
        
%         xa = gradient(Intrp(:,6))./t;
%         ya = gradient(Intrp(:,7))./t;
%         za = gradient(Intrp(:,8))./t;
%         acomps = [xa ya za];
%         a = sqrt(sum(acomps.^2,2));
%         Intrp(:,13) = a;
%         Intrp(:,14) = xa;
%         Intrp(:,15) = ya;
%         Intrp(:,16) = za;
        
        % exclude first and last nans
        Intrp(1:4,:) = [];
        Intrp(end-3:end,:) = [];
        %% filter the data
        %Set up filter. 10Hz cutoff (10/(100/2)) % Note diff sampling rate due to
        %downsample
        if filter_data == 1
            [f1,f2] = butter(1,.2);
            filtered = [Intrp(:,1) filtfilt(f1,f2,Intrp(:,2:12))];
            [~,mid] = min(abs(filtered(:,1)-ReachS(ii).real_kin(602,1)));
            ReachS(ii).kin_10ms = filtered(mid-400:mid+400,:);
        else
            [~,mid] = min(abs(Intrp(:,1)-ReachS(ii).real_kin(602,1)));
            if mid-400<0 || mid+400>length(Intrp)
                Intrp = [nan(size(Intrp));Intrp;nan(size(Intrp))];
                mid = mid+(size(Intrp,1)/3);
            end
            ReachS(ii).kin_10ms = Intrp(mid-400:mid+400,:);
        end
    end
    
end