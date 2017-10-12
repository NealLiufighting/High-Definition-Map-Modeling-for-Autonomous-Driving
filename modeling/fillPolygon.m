%% This function fill with white with given polygon
%
%
%
%
%
function [mask] = fillPolygon(canvas, polygon)
for i = 1:size(canvas,1)
    for j = 1:size(canvas,2)
        if isInPolygon([i,j], polygon)
            canvas(i, j) = 1;
        else
            continue;
        end
    end%endfor j
end%endfor i
mask = canvas;
end%endfunction

function [tof] = isInPolygon(point, polygon)
% Initialize tof
tof = true;
%
for i = 1:length(size(polygon,1))
    % Solve line equation
    if i ~= length(size(polygon,1))
        [A, B, C] = solveLineEquation(polygon(i,:), polygon(i+1,:));
    else
        [A, B, C] = solveLineEquation(polygon(i,:), polygon(1,:));
    end%endif
    %
    if [point(1) point(2) 1]*[A B C]' < 0
        continue;
    else
        tof = false;
        break;
    end
end%endfor 
end%endfunction