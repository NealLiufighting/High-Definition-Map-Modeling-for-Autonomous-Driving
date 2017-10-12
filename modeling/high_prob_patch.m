%% This function is the test function if high probability patches.
%
%
%
%
%
%
%
clear all;
%
addpath('..\patchGenerator\');
%
prob_dir = '..\data\solution2_prob\';
save_dir = '..\data\test\';
image_names = dir(strcat(prob_dir,'*.png'));
%
AREA_THRESHOLD = 40;
INTENSITY_THRESHOLD = 0.3;
%
for j = 1:length(image_names);
    test_image = imread(strcat(prob_dir,image_names(j).name));
    %
    test_image = double(test_image)/255;
    % Ostu threshold
    level = graythresh(test_image);
    % 
    region_image = im2bw(test_image,level);
    %
    L = bwlabel(region_image,4);
    %
    s = regionprops(L,'all');
    %
    image = zeros(size(test_image));
    % check each one
    for i = 1:length(s)
        if s(i).Area >= AREA_THRESHOLD
            % get pixel list
            xmin = min(s(i).PixelList(:,2));
            xmax = max(s(i).PixelList(:,2));
            ymin = min(s(i).PixelList(:,1));
            ymax = max(s(i).PixelList(:,1));
            %
            for k = ymin:ymax
                [poi,~] = max(test_image(xmin:xmax,k));
                loc = floor(mean(find((test_image(xmin:xmax,k) == poi)==1)));
                if poi >= INTENSITY_THRESHOLD
                    image(loc-1+xmin,k) = 1;
                end
            end%endfor k
        else
            continue;
        end%endif
    end%endfor i
    imshow(image);
    imwrite(image,strcat(save_dir, image_names(j).name));
%     imwrite(heatmap/max(max(heatmap)),strcat(save_dir2, image_names(j).name));
end