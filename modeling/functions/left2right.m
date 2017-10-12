%%  This function is used to reorder the lines from left to right
%   (driving direction)
%   INPUT:
%       lines: N by 6 matrix which records N lines, each line contains
%               [start endpoint lat lon alt and end endpoint lat lon alt]
%       traj:  M by P (P>=3) matrix which records the poses in current
%       chunk.
%   OUTPUT:
%       newlines:
%   Andi Zang
%   09/16/2015
function [newlines, dist, I] = left2right(lines, traj, spheroid)
%
newlines = lines;
%   check input
if size(lines,2) ~= 6 || size(traj,2)<3 || size(traj,1)<2
    disp('Please check your input.');
    newlines  = [];
end%endif check
%   prepare traj
traj = lla2ecef(traj(:,1:3));
traj = [mean(traj(:,1:3)) traj(end,1:3)-mean(traj(:,1:3))];
%   reference point
%
%   find left or right
dist = zeros(size(lines,1),1);
%
for i = 1:size(lines,1)
    %   convert line from lla to ecef
    startP = lla2ecef(lines(i,1:3));
    endP = lla2ecef(lines(i,4:6));
    lnr1 = lor(traj, startP, spheroid);
    lnr2 = lor(traj, endP, spheroid);
    dist1 = distancePointLine3d(startP, traj);
    dist2 = distancePointLine3d(endP, traj);
    % 
    dist(i) = (lnr1*dist1 + lnr2*dist2)/2;
end%endfor i
%   sort pose
[C, I] = sort(dist,'descend');
%   reorder
for i = 1:length(I)
    newlines(i,:) = lines(I(i),:);
end%endfor i
dist = C;
end%endfunction