%% This function is used to find if a point is inside given polygon
% aZ
function [tof] = isInPolygon(point, polygon)
% Initialize tof
tof = true;
%
for i = 1:length(polygon.vert)
    % Solve line equation
    if i ~= length(polygon.vert)
        [A, B, C] = solveLineEquation(polygon.vert(i,:), polygon.vert(i+1,:));
    else
        [A, B, C] = solveLineEquation(polygon.vert(i,:), polygon.vert(1,:));
    end%endif
    %
    if [point(1) point(2) 1]*[A B C]' > 0
        continue;
    else
        tof = false;
        break;
    end
end%endfor 
end%endfunction