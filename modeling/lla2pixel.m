%%
%
%
%
%
%
function [pixelXY] = lla2pixel(points, corners, image_size)
%
pixelXY = zeros(size(points,1),2);
%
for i = 1:size(points,1)
    %
    x_ratio = (corners(1,1) - points(i,1))/(corners(1,1) - corners(2,1));
    y_ratio = (points(i,2) - corners(1,2))/(corners(3,2) - corners(1,2));
    %
    x = floor(x_ratio*image_size(1))+1;
    y = floor(y_ratio*image_size(2))+1;
    %
    pixelXY(i,:) = [x y];
end