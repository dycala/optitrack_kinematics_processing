%assign_identity finds all timepoints where two markers were detected and
%uses a nearest neighbor analysis to match the data to the original marker
%or the 'noise' marker as necessary.
%Since the optitrack system doesn't intrinsically 'know' which marker is
%the true marker on the paw, we might be tracking noise by mistake.

function [ided] = assign_identity3(Expt)



if length(fieldnames(Expt)) == 1
    ided.m1 = Expt.m1;
else
    m1 = Expt.m1;
    m2 = Expt.m2;
    
    m2diff = [1 ; diff(m2(:,1))];
    
    todelete = (0);
    
    sw = 0;  %switch = 0
    
    
    for num = 1 : length(m2(:,1))
        
        
        m1diff = [1 ; diff(m1(:,1))];
        
        %get index of point in m1 that corresponds to this time in m2
        inx = find(m1(:,1) == m2(num,1));
        
        if inx == 1
            continue
        end
        
        
        %check for no current m1pt
        if isempty(inx)
            
            %check for prev m2pt
            if m2diff(num) <= .013
                if sw == 0
                else
                    %%% switch code here
                    m1 = sortrows([m1; m2(num,:)]);
                    
                end

            else 
                %%%do nothing. continue and leave point as an m2 without an
                %%%m1 pair or previous m2 point.
                continue
            end
            
        else   %there is current m1pt
            
            %check if prev m1pt 
            if m1diff(inx) <= .013
                %%%compare current m2 and m1 with previous m1.  align to closer
                %%%pt
                m1prev = m1(inx-1,2:4);
                m1curr = m1(inx,2:4);
                m2curr = m2(num,2:4);
                
                %get vector between two point sets
                m1v = abs(m1curr - m1prev);
                m2v = abs(m2curr - m1prev);
                
                
                
                if inx == todelete(end)+1;  % m1prev is actually like m2prev
                    if dot(m1v,m1v) >= dot(m2v,m2v)
                        sw = 0;
                    else
                        pt1 = m1(inx,:);
                        pt2 = m2(num,:);

                        m1(inx,:) = pt2;
                        m2(num,:) = pt1;

                        sw = 1;
                        
                    end
                    
                else                        %do things normally
                    if dot(m1v,m1v) <= dot(m2v,m2v)
                        sw = 0;
                    else
                        pt1 = m1(inx,:);
                        pt2 = m2(num,:);

                        m1(inx,:) = pt2;
                        m2(num,:) = pt1;

                        sw = 1;
                    end
                end
       
                
                
                
                
            else
                %%%do nothing. continue because it doesnt
                %%%matter anymore
            end
        end
        
        %check if next m1pt 
        if (inx+1) > length(m1diff)
            continue
        end
        
        
        if m1diff(inx+1) <= .013
            
            %if there is an m2 point,  above algo will handle it
            if any(m2(:,1) == m1(inx+1,1))
                continue
            end
            
            
            %if no m2 point, find next m1 skip 
            inx_skip = find(m1diff(inx:end) >= .013,1);
            if inx_skip + inx > size(m1,1)          %end condition
                inx_skip = size(m1,1);
            end
            
            %next m2 (in m1 coordinates)
            if num == size(m2,1)                    %end condition
                inx_next = size(m1,1) + 1;
            else
                inx_next = find(m1(:,1) >= m2(num+1,1),1);
            end
            
            
            inx_end = min((inx_skip+inx),inx_next);
            
            
            %%% compare next m1 with current m1 and m2. switch until
            %%% inx_end if switch necessary

                m1next = m1(inx+1,2:4);
                m1curr = m1(inx,2:4);
                m2curr = m2(num,2:4);
                
                %get vector between two point sets
                m1v = abs(m1curr - m1next);
                m2v = abs(m2curr - m1next);
                
                if dot(m1v,m1v) <= dot(m2v,m2v)
                else
                    todelete = [todelete; ((inx+1):(inx_end-1))'];
                    
                    
                    
                    
%                     m1 = [m1(1:(inx),:) ; m1(inx_end:end,:)];
                end
                
                
        end
    end
    
    new_inx = setdiff((1:size(m1,1)),todelete);
    m1 = m1(new_inx,:);
    ided.m1 = m1;
    
end
    
                
                
                