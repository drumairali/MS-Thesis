function [GaborFilters]=gaussian_bank(Size,centerPointsX,centerPointsY,sigma)
s=0;
gb_centers(1,:)=[0 0];
for i=1:length(centerPointsX)
    for j=1:length(centerPointsY)
        s=s+1;
        gb=gabor2D_fnc(centerPointsY(j),centerPointsX(i),Size,sigma,0,0,1); 
        gb_centers(s,:)=[centerPointsX(i) centerPointsY(j)];
        GaborFilters{s}=gb;
    end
end

