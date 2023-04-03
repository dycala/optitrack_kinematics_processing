function [mark] = MocapOrg(dta)


%set up marker naming convention
mark_names = 'm%d';

%loop through the length of dta to assign each marker a fieldname inside
%structure 'mark'
for num = 1:length(dta)
    
    %get marker name
    mark_name = sprintf(mark_names,num);
    
    %get data where x not equal to zero (missed time points)
    mark.(mark_name) = dta{num}(dta{num}(:,2)~=0,:);
    
end

    