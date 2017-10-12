%
%
%
%
%
clear all;
%
addpath('..\patchGenerator\');
% load classifier
load 8_rectified_hog_rf.mat
%
image_dir = '..\data\solution2_satellite\';
save_dir = '..\data\solution2_heat\';
save_dir2 = '..\data\solution2_prob\';
image_names = dir(strcat(image_dir,'*.png'));
%
PATCH_SIZE = 8;
STEP = PATCH_SIZE/2;
%
for j = 1:length(image_names);
    test_image = imread(strcat(image_dir,image_names(j).name));
    %
    test_image = double(test_image)/255;
    % crop it
    [patch, idx] = decompose(test_image, PATCH_SIZE, STEP,...
                    [1 size(test_image,1) 1 size(test_image,2)]);
    % heatmap
    heatmap = zeros(size(test_image,1), size(test_image,2));
    % visit each patch
    for i = 1:size(idx,1)
        % convert patch to hog feature
        patch_hog = extractHOGFeatures(patch(:,:,i),'Cellsize',[4 4]);
        % predict
        [result, score] = predict(b, patch_hog);
        %
        heatmap(idx(i,1):idx(i,1)+PATCH_SIZE-1,idx(i,2):idx(i,2)+PATCH_SIZE-1) = ...
                    score(2) + heatmap(idx(i,1):idx(i,1)+PATCH_SIZE-1,idx(i,2):idx(i,2)+PATCH_SIZE-1);
    end%endfor i

%     imshow(myheatmap(heatmap));
    imwrite(myheatmap(heatmap),strcat(save_dir, image_names(j).name));
    imwrite(heatmap/max(max(heatmap)),strcat(save_dir2, image_names(j).name));
end