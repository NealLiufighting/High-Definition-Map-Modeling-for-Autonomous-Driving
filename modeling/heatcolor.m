%%  This function is used to colorize intensities
%   Andi Zang
%   07/26/2015
function [rgb_list] = heatcolor(intensity)
%   check intensity
if size(intensity,2)~=1
    rgb_list = [];
    warnning('Please check input array');
    return
end%end if
%   initialize rgb and hsv
rgb = zeros(length(intensity),1,3);
hsv = ones(length(intensity),1,3);
rgb_list = zeros(length(intensity),3);
%   reverse
intensity = max(intensity) - intensity;
%
normalized_intensity = (intensity - min(intensity))/(max(intensity) - min(intensity))*240/360;
%
hsv(:,1,1) = normalized_intensity;
%
rgb = hsv2rgb(hsv);
%
rgb_list = reshape(rgb, length(intensity), 3);
end%end function