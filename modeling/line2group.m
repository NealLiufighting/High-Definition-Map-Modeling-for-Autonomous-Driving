%% This function returns line groups
%
%
%
%
% function [group] = line2group()
clear all
%
addpath('.\functions\');
addpath('..\roadModelGenerator\');
% geometric functions
addpath('D:\workspace\geom3d\geom3d\');
%
% line_dir = '..\data\set1\';
line_dir = '..\data\set2\';
pose_dir = '..\data\pose\';
%
spheroid = referenceEllipsoid('wgs84');
% parameters
INCHUNK_LINE_TO_LINE_DIST = 0.4;
% 
% start_line_id = 606;
% end_line_id = 704;
start_line_id = 880;
end_line_id = 1079;
% load lines
lines = cell(1, end_line_id - start_line_id + 1);
for i = start_line_id:end_line_id
    id = i - start_line_id + 1;
    try
        candidate = dlmread(strcat(line_dir,num2str(i),'.line'));
        if isempty(candidate)
            lines{id}.candidate = [];
            lines{id}.length = dist;
            lines{id}.id = i;
        else
            lines{id}.candidate = candidate;
            %
            dist = zeros(size(candidate,1),1);
            for j = 1:size(candidate,1)
                p1 = [candidate(j,1:2) 0];
                p2 = [candidate(j,3:4) 0];
                p1_ecef = lla2ecef(p1);
                p2_ecef = lla2ecef(p2);
                %
                dist(j) = norm(p1_ecef - p2_ecef);
            end%endfor j
            lines{id}.length = dist;
            lines{id}.id = i;
        end
    catch
        lines{id}.candidate = [];
        lines{id}.length = [];
        lines{id}.id = i;
    end%endtry
    % load pose
    pose = dlmread(strcat(pose_dir,'chunk_',num2str(i),'_pose.fuse'));
    %
    lines{id}.pose = cat(2, pose(:,1:2), zeros(size(pose,1),1));
end%endfor 
%%%%%%% group it self
for i = 1:length(lines)
    inchunk_group_index = [1: size(lines{i}.candidate,1)];
    line_traj_distance = zeros(size(lines{i}.candidate,1),1);
    pose = lines{i}.pose;
    for j = 1:size(lines{i}.candidate,1)
        p11 = [lines{i}.candidate(j,1:2) 0];
        p12 = [lines{i}.candidate(j,3:4) 0];
        %
        p1 = [p11; p12];
        %
        lnr1 = leftOrRight([pose(1,:);pose(end,:)], p11, spheroid);
        lnr2 = leftOrRight([pose(1,:);pose(end,:)], p12, spheroid);
        if lnr1*lnr2 < 0
            disp('i');
        end
        [~, ~, dist_traj, ~] = line2line(p1, pose, 1);
        line_traj_distance(j) = dist_traj*lnr1;
    end%endfor j
    % backward
%     for j = size(lines{i}.candidate,1):-1:2
%         for k = j-1:-1:1
%             if (line_traj_distance(j) - line_traj_distance(k))<INCHUNK_LINE_TO_LINE_DIST
%                 %
%                 lines{i}.length(k) = lines{i}.length(k) + lines{i}.length(j);
%                 % remove this line
%                 lines{i}.length(j) = [];
%                 line_traj_distance(j) = [];
%                 inchunk_group_index(j) = [];
%                 lines{i}.candidate(j,:) = [];
%                 break;
%             end
%         end
%     end
    lines{i}.to_traj = line_traj_distance;
    lines{i}.int = inchunk_group_index;
end%endfor i
%%%%%%% group all
% number of previous chunks
NUMBER_OF_PREVIOUS_CHUNKS = 2;
NUMBER_OF_PREVIOUS_CHUNKS_TRAJ = 4;
% 
TRAJ_LINE_DISTANCE = 0.5;
LINE_LINE_DISTANCE = 0.3;
%
%
group_index_pointer = 1;
%
for i = 1:length(lines)
    if true%i > NUMBER_OF_PREVIOUS_CHUNKS
        exchunk_group_index = zeros(size(lines{i}.candidate,1),1);
        % loop for each line in current chunk
        for k = 1:size(lines{i}.candidate,1)
            %
            p11 = [lines{i}.candidate(k,1:2) 0];
            p12 = [lines{i}.candidate(k,3:4) 0];
            %
            p1 = [p11; p12]; 
            %%%%%% match to line
            match_flag = 0;
            % loop in current chunk
            for m = k-1:-1:1
                if m < 1 || k == 1
                    break;
                else
                    if abs(lines{i}.to_traj(m) - lines{i}.to_traj(k)) < LINE_LINE_DISTANCE
                        exchunk_group_index(k) = exchunk_group_index(m);
                        match_flag = 1;
                        break;
                    end
                end
            end
            % loop for each previous chunk
            for j = i-1:-1:i-NUMBER_OF_PREVIOUS_CHUNKS
                if match_flag == 1 || j < 1
                    break;
                end
                % loop for each line in chunk j
                for l = 1:size(lines{j}.candidate,1)
                    p21 = [lines{j}.candidate(l,1:2) 0];
                    p22 = [lines{j}.candidate(l,3:4) 0];
                    %
                    p2 = [p21; p22];
                    % calculate line to line distance
                    [~, ~, dist, theta] = line2line(p1, p2, 1);
                    %
                    if dist <= LINE_LINE_DISTANCE
                        exchunk_group_index(k) = lines{j}.ext(l);
                        % used
                        match_flag = 1;
                        break;
                    else
                        continue;
                    end
                    %
                end%endfor l
            end%endfor j
            %%%%%% match to trajectory
            if match_flag == 0
                for j = i-1:-1:i-NUMBER_OF_PREVIOUS_CHUNKS_TRAJ
                    if match_flag == 1 || j < 1
                        break;
                    end
                    % loop for each line in chunk j
                    for l = 1:size(lines{j}.candidate,1)
                        to_traj_dist = abs(lines{j}.to_traj(l) - lines{i}.to_traj(k));
                        if to_traj_dist <= TRAJ_LINE_DISTANCE
                            exchunk_group_index(k) = lines{j}.ext(l);
                            % used
                            match_flag = 1;
                            break;
                        else
                            continue;
                        end
                        %
                    end%endfor l
                end%endfor j
            end
            % is this a new group?
            if match_flag == 0
                exchunk_group_index(k) = group_index_pointer;
                group_index_pointer = group_index_pointer + 1;
            end
            if exchunk_group_index(k) == 0
                aaa
            end
        end%endfor k
        if sum(exchunk_group_index==0)>0
            aa
        end
        lines{i}.ext = exchunk_group_index;
    else
%         % new incoming chunk
%         exchunk_group_index = zeros(size(lines{i}.candidate,1),1);
%         for k = 1:size(lines{i}.candidate,1)
%             exchunk_group_index(k) = group_index_pointer;
%             group_index_pointer = group_index_pointer + 1;
%         end%endfor k
%         lines{i}.ext = exchunk_group_index;
    end%endif
end%endfor i


%%%% write group to files
num_of_groups = max(lines{end}.ext);

line_group = cell(1, group_index_pointer-1);

for i = 1:length(lines)
    idx = lines{i}.ext;
    line = lines{i}.candidate;
    for k = 1:size(lines{i}.candidate,1)
        line_group{idx(k)} = cat(1, line_group{idx(k)},...
                                [line(k,1:2) 0], [line(k,3:4) 0]);
    end%endfor k
end%endfor k

for i = 1:length(line_group)
    line = line_group{i};
    fid = fopen(strcat('..\data\groups\',num2str(i),'.fuse'),'w');
    for j = 1:size(line,1)
        fprintf(fid, '%.8f %.8f %.8f 255\n',line(j,:));
    end
    fclose(fid);
end

save lines.mat lines










