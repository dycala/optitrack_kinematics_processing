function [] = meanSEMplot(ts,X,color,varargin)

default_sd = 1:100;
default_num = 0;
default_type = "sem";

% parse varargin
validNumInput = @(x) isvector(x);
p = inputParser;
addParameter(p,'sd',default_sd,validNumInput);
addParameter(p,'num',default_num,validNumInput);
addParameter(p,'type',default_type,@isstring);

parse(p,varargin{:});
type = p.Results.type;


    if size(X,2) > 1
    
        X(isnan(X))=0;
        
        m = nanmean(X,2);
        sd = std(X,0,2);
        num = size(X,2);
            
    else 
    
        sd = p.Results.sd;
        num = p.Results.num;
        m = reshape(X,[length(X),1]);
        sd = reshape(sd,[length(sd),1]); 

    end

% calculate bounds
if type == "sem"
    bounds = sd/sqrt(num);
elseif type == "sd"
    bounds = sd;
end
    
a = [1:length(m),length(m):-1:1]+ts(1)-1;
b = [m+bounds;flipud(m-bounds)]';

% plot
hold on 
patch(a,b,color,'FaceAlpha',.2, 'EdgeAlpha', 0.0)
plot(ts,m,color, 'LineWidth', 1.0)

end
