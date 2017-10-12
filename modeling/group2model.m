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
%
line_group = cell(1, 27);
line_length = zeros(1,27);
road_length = zeros(1,27);

for i = 1:length(lines)
    idx = lines{i}.ext;
    line = lines{i}.candidate;
    for k = 1:size(lines{i}.candidate,1)
        line_group{idx(k)} = cat(1, line_group{idx(k)},...
                                [line(k,1:2) 0], [line(k,3:4) 0]);
        line_length(idx(k)) = line_length(idx(k)) + lines{i}.length(k);
        road_length(idx(k)) = road_length(idx(k)) + 12;
    end%endfor k
end%endfor k

length_ratio = line_length./road_length;

save_dir = '..\data\model\';
for i = 1:length(lines)
    fid = fopen(strcat(save_dir,num2str(lines{i}.id),'.line'),'w');
    for j = 4:-1:1
        idx = find(lines{i}.ext==j);
        if j == 4 || j == 1
            label = 2;
        else
            label = 3;
        end
        if ~isempty(idx)
            fprintf(fid, '%.8f, %.8f, 0, %.8f, %.8f, 0, %d\n',...
                    lines{i}.candidate(idx(1),1:2), lines{i}.candidate(idx(1),3:4), label);
        end
    end
    fclose(fid);
end