%   This function is used to calculate line point cloud to line 
%   point cloud to line point cloud distance
%   Andi Zang
%   08/28
%   INPUT:
%       points_in1, points_in2:  N by 3 matrix, all the points in 
%       lat lon alt coordinate.
%       mode:
%               1 ->
%   OUPUT:
%       dist: line to line distance.
%       line1, line2: 1 by 6 matrix in ecef (meter)
%                       [x0 y0 z0 dx dy dz]
%       theta: line to line angle.
%   
function [line1, line2, dist, theta] = line2line(points_in1, points_in2, w)
%   test input:
% points_in1 = dlmread('\\3dtpdiskstation01\GeneralShare\Lidar_Drives\LaneMarking_chucai\chunk_1090_0_1_solid_leftb_3D.fuse');
% points_in2 = dlmread('\\3dtpdiskstation01\GeneralShare\Lidar_Drives\LaneMarking_chucai\chunk_1090_0_3_solid_rightb_3D.fuse');
% points_in1 = points_in1(:,1:3);
% points_in2 = points_in2(:,1:3);
%
%   check input
if size(points_in1, 2)~=3 || size(points_in2, 2)~=3
    disp('Please check your input points: N by 3.');
    return;
end
if size(points_in1, 1)<2 || size(points_in2, 1)<2
    disp('Input line points must >= 2.');
    return;
end
%   convert points from lla to ecef
ecef1 = lla2ecef(points_in1);
ecef2 = lla2ecef(points_in2);
%   fit line
% center1 = mean(ecef1,1);
% centeredLine1 = bsxfun(@minus,ecef1,center1);
% [~,~,V] = svd(centeredLine1);
% direction = V(:,1);
line1 = fitLine3d(ecef1);
line2 = fitLine3d(ecef2);
%   calculate theta
theta = vectorAngle3d(line1(4:6), line2(4:6));
%   calculate distance
dist11 = distancePointLine3d(line1(1:3)+w*line1(4:6), line2);
dist12 = distancePointLine3d(line1(1:3)-w*line1(4:6), line2);
dist21 = distancePointLine3d(line2(1:3)+w*line2(4:6), line1);
dist22 = distancePointLine3d(line2(1:3)-w*line2(4:6), line1);
dist = mean([dist11 dist12 dist21 dist22]);
end%endfunction
