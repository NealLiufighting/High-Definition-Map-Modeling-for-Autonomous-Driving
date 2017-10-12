%% This function moves entire pose/trajectory by given shift
%
%
%
%
%
%
%
function [] = moveTrajectory(trajectory, dist)
% test args
% clear all
spheroid = referenceEllipsoid('wgs84');
% trajectory = dlmread('D:\Dropbox\geospatial\mcode\final_project_data\trajectory.fuse');
% trajectory = trajectory(:,1:3);
% dist = -20;
% initialize new trajectory
newtrajectory = [];
% check each point
for i = 1:size(trajectory,1)
    % initialize new trajectory pose(s)
%     newpose = [];
    if i == 1
        p1 = trajectory(1,:);
        p2 = trajectory(2,:);
        % move single point
        newpose = moveSinglePoint(p1, [p1;p2], p1, dist, spheroid);
    elseif i == size(trajectory,1)
        p1 = trajectory(i-1,:);
        p2 = trajectory(i,:);
        % move single point
        newpose = moveSinglePoint(p1, [p1;p2], p2, dist, spheroid);       
    else
        p1 = trajectory(i-1,:);
        p2 = trajectory(i,:);
        p3 = trajectory(i+1,:);
        % move point twice
        newpose1 = moveSinglePoint(p2, [p1;p2], p2, dist, spheroid);
        newpose2 = moveSinglePoint(p2, [p2;p3], p2, dist, spheroid);
        % find next line segment is left turn or right turn
        lor = leftOrRight([p1;p2], p3, spheroid);
        %?swap?
        if dist*lor < 0 % opposite side
            newpose = [newpose1; newpose2];
        elseif dist*lor > 0 % same side
            newpose = [newpose2; newpose1];
        else % straight line
            % just pick one
            newpose = newpose1;
        end%endif
    end%endif
    % push new pose(s) to new trajectory
    newtrajectory = cat(1, newtrajectory, newpose);
end%endfor i
% end%endfunction
% % test write
% fid = fopen('test.fuse','w');
% for i = 1:length(newtrajectory)
%     fprintf(fid,'%.10f %.10f %.10f 255\n',newtrajectory(i,:));
% end%
% fclose(fid)
