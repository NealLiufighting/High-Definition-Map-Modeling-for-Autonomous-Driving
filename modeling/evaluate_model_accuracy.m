%% 
%
%
%
clear all
% include
addpath('.\functions\');
addpath('..\roadModelGenerator\');
% geometric functions
addpath('D:\workspace\geom3d\geom3d\');
%
T = 0.2;
spheroid = referenceEllipsoid('wgs84');
% set directories
result_dir = '..\data\model_stage2\';
gt_dir = '..\model_Evaluation\Integration_set2\';
% load mapping
mapping = csvread('..\model_Evaluation\model_stage2_mapping.csv');
% 
dist_list = [];
%
geometry_level_performance = [];
%
n_gt_line = 0;
n_true_detect = 0;
n_result_line = 0;
% 
for i = 1:size(mapping,1)
    current_performance = 0;
    % load gt
    gt = csvread(strcat(gt_dir,'Chunk_', num2str(mapping(i,1)),'.csv'));
    % load result
    try
        result = csvread(strcat(result_dir, num2str(mapping(i,1)),'.line'));
        % set elevation in gt = 0
        gt(:,3) = 0;
        gt(:,6) = 0;
        %
        inchunk_dist_list = [];
        % loop for each line
        for j = 2:length(mapping(i,:))
            if mapping(i,j)~=0
                % line from gt
                line_gt = reshape(gt(j-1,1:6),[3 2])';
                % line from result
                line_result = reshape(result(mapping(i,j),1:6),[3 2])';
                % calculate distance
                [~, ~, dist, ~] = line2line(line_gt, line_result, 1);
                lnr = leftOrRight(line_gt, line_result(1,:), spheroid);
                
                if dist > T
                    continue;
                else
                    % merge to list
                    dist_list = cat(1, dist_list, dist*lnr);
                    inchunk_dist_list = cat(1, inchunk_dist_list, dist*lnr);
                    %
                    n_true_detect = n_true_detect + 1;
                end
            else
                
            end
        end%endfor j
        %
        current_performance = 1 - std(inchunk_dist_list)/...
                            std(cat(1, T*ones(floor(length(inchunk_dist_list)/2),1),...
                                    -1*T*ones(ceil(length(inchunk_dist_list)/2),1)));
        if isnan(current_performance)
            i
        end
        %
        n_result_line = n_result_line + size(result,1);
    catch
        continue;
    end%endtry
    %
    n_gt_line = n_gt_line + size(gt,1);
    geometry_level_performance = cat(1, geometry_level_performance, current_performance);
end%endfor i

function_level_precision = n_true_detect/n_gt_line;
function_level_recall = n_true_detect/n_result_line;
%
disp(strcat('Function level precision: ', num2str(function_level_precision*100),'%'));
disp(strcat('Function level recall: ', num2str(function_level_recall*100),'%'));
disp(strcat('Shift: ',num2str(median(dist_list)),'m'));
disp(strcat('Geometry performance: ',num2str(median(geometry_level_performance(~isnan(geometry_level_performance))))));
disp(strcat('Median error: ',num2str(median(abs(dist_list))),'m'));