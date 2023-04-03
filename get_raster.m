function [Spikes] = get_raster(Spikes)

    % Make raster
    raster=Spikes.SS_Bin1(Spikes.SS_Bin1(:,2)~=0);
    if raster(1,1) ~= Spikes.SS_Bin1(1,1)
        raster = vertcat(Spikes.SS_Bin1(1,1),raster);
    end
    if raster(end,1) ~= Spikes.SS_Bin1(end,1)
        raster = vertcat(raster,Spikes.SS_Bin1(end,1));
    end
    
    %Get ISIs
    for i = 2:length(raster)
        raster(i,2) = raster(i,1)-raster(i-1,1);
    end

    Spikes.SS_Raster = raster;
    
end