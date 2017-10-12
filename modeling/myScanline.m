%% This function is used to fill polygon on canvas by scanline algo
% aZ
function [canvas] = myScanline(canvas, polygon, color)
% Scan in colomn
for i = 1:size(canvas,1)
    % Scan in row
    for j = 1:size(canvas,2)
        if isInPolygon([i,j], polygon)
            canvas(i, j, :) = color;
        else
            continue;
        end
    end%endfor
end%endfor
end%endfunction