%%
%
%
%
%
%
% function [] = group2model()
clear all
% load lines
load lines.mat
% load lines_set2.mat
%
% N = 33;
N = 27;
%
group = cell(N,1);
group_length = zeros(1,N);
%
for i = 1:length(lines)
    idx = lines{i}.ext;
    line = lines{i}.candidate;
    for k = 1:size(lines{i}.candidate,1)
        group_length(idx(k)) = group_length(idx(k)) + lines{i}.length(k);
    end%endfor k
    %
    idx = unique(idx);
    %
    for k = 1:length(idx)
        group{idx(k)} = cat(1, group{idx(k)}, i);
    end%endfor k
end%endfor i
% range of each one
group_range = zeros(N,2);
for i = 1:N
    group_range(i,1) = min(group{i});
    group_range(i,2) = max(group{i});
end
group_total_length = (group_range(:,2) - group_range(:,1)+1)*12;

group_length_ratio = group_length./group_total_length';
%%%%
ids = lines{1}.id;
ide = lines{end}.id;
% load pose
pose_dir = '..\data\pose\';
pose = zeros(ids-ide,6);
for i = ids:ide
    current_pose = dlmread(strcat(pose_dir,'chunk_',num2str(i),'_pose.fuse'));
    pose(i-ids+1,1:2) = current_pose(2,1:2);
    pose(i-ids+1,4:5) = current_pose(end-1,1:2);
end
% load lines to mat
line = zeros(ids-ide,6,4);
hit = zeros(ids-ide,4);
for i = 1:length(lines)
    idx = lines{i}.ext;
    cline = lines{i}.candidate;
    for j = 1:4
        cidx = find(idx==j);
        if ~isempty(cidx)
            cidx = cidx(1);
            line(i,1:2,j) = cline(cidx,1:2);
            line(i,4:5,j) = cline(cidx,3:4);
            hit(i,j) = 1;
        end
    end%endfor j
end
% interpolate stage
for i = 1:size(hit,1)
    for j = 1:size(hit,2)
        if hit(i,j) == 0
            point1 = line(i-1,4:6,j);
            point2 = line(i+1,1:3,j);
            newpoint = mean([point1;point2]);
            newpoint1 = mean([point1;newpoint]);
            newpoint2 = mean([newpoint;point2]);
            line(i,:,j) = [newpoint1 newpoint2];
        end
    end
end
% write result to line
%
save_dir = '..\data\model_stage2\';
% for i = 1:size(hit,1)
%     fid = fopen(strcat(save_dir,num2str(lines{i}.id),'.line'),'w');
%     for j = 4:-1:1
%         if j == 4 || j == 1
%             label = 2;
%         else
%             label = 3;
%         end
%         fprintf(fid, '%.8f, %.8f, 0, %.8f, %.8f, 0, %d\n',...
%                 line(i,1:2,j), line(i,4:5,j), label);
%     end
%     fclose(fid);
% end
% write to fuse
for i = 1:4
    points = line(:,:,i);
    points = reshape(points', [3 2*size(points,1)])';
    cp_spline = llaPolylineInterpolation(points, 3);
    fid = fopen(strcat(save_dir,num2str(i),'.fuse'),'w');
    
    for j = 1:size(cp_spline,1)
        fprintf(fid, '%.8f %.8f %.8f 255\n',cp_spline(j,:));
    end
    fclose(fid);
end













