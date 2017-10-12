%%
%
%
%
%
%
function [points] = pixel2lla(pixelXY, corners, image_size)
%
if pixelXY(1) > 0 && pixelXY(1) <= image_size(1) &&...
   pixelXY(2) > 0 && pixelXY(2) <= image_size(2)
    %
    points = zeros(size(pixelXY,1),2);
    %
    for i = 1:size(pixelXY,1)
        %
        x_ratio = pixelXY(i,1)/image_size(1);
        y_ratio = pixelXY(i,2)/image_size(2);
        %
        x = corners(1,1) - (corners(1,1) - corners(2,1))*x_ratio;
        y = corners(1,2) + (corners(3,2) - corners(1,2))*y_ratio;
        %
        points(i,:) = [x y];
    end
else
    disp('Pixel location out of bound.');
end
end