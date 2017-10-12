%% This function is used to sort LLA points
%   INPUT:
%       points: N by 3, in LLA
%   OUTPUT:
%       sorted_points: N by 3, in LLA
%
function [sorted_points] = lineSortLLA(points)
% convert points to ecef
points_ecef = lla2ecef(points);
% check first point
if norm(points_ecef(1,:) - points_ecef(3,:)) > norm(points_ecef(2,:) - points_ecef(3,:))
    %   first point is the first one
    sorted_points = points_ecef(1,:);
    %
    current_point = points_ecef(1,:);
    points_ecef(1,:) = [];
elseif norm(points_ecef(1,:) - points_ecef(3,:)) < norm(points_ecef(2,:) - points_ecef(3,:))
    %  
    sorted_points = points_ecef(2,:);
    %
    current_point = points_ecef(2,:);
    points_ecef(2,:) = [];
else
    disp('Cannot find first point.');
    return
end
% sort
for i = 2:size(points,1)
    % calculate distance between current point to all rest points
    [idx, ~] = closest(current_point, points_ecef, 1);
    % update current point
    current_point = points_ecef(idx,:);
    % merge close point
    sorted_points = cat(1, sorted_points, current_point);
    % remove this point
    points_ecef(idx,:) = [];
end
% conver points back to LLA
sorted_points = ecef2lla(sorted_points);
end%endfunction