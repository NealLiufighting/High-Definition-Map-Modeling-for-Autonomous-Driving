%%
%
%
%
%
%
function [heatmap] = myheatmap(img)
%
if size(img,3)~=1
    disp('Must be single channel image.')
    return
end%endif
% initialize heatmap
heatmap = zeros(size(img,1), size(img,2), 3);
%
minvalue = min(min(img));
maxvalue = max(max(img));
myrange = maxvalue - minvalue;
%
for i = 1:size(img,1)
    for j = 1:size(img,2)
        %
        intensity = maxvalue - img(i,j);
        % normalize
        normalized_intensity = (intensity)/myrange*240/360;
        % convert to hsv color
        hsvcolor = ones(length(intensity),1,3);
        hsvcolor(:,1,1) = normalized_intensity;
        % convert to rgb color
        rgbcolor = hsv2rgb(hsvcolor);
        %
        heatmap(i,j,1) = rgbcolor(1);
        heatmap(i,j,2) = rgbcolor(2);
        heatmap(i,j,3) = rgbcolor(3);
    end%endfor j
end%endfor i
end%endfunction