%%

function [] = prob2pixel(prob_image, threshold1)
% Ostu threshold
level = graythresh(prob_image);
% 
region_image = im2bw(prob_image,level);
%
L = bwlabel(region_image,4);
%
s = regionprops(L,'all');
%
image = zeros(size(test_image));
% check each one
for i = 1:length(s)
    if s(i).Area >= AREA_THRESHOLD
        % get pixel list
        xmin = min(s(i).PixelList(:,2));
        xmax = max(s(i).PixelList(:,2));
        ymin = min(s(i).PixelList(:,1));
        ymax = max(s(i).PixelList(:,1));
        image(xmin:xmax,ymin:ymax) = 1;
    else
        continue;
    end%endif
end%endfor i
end