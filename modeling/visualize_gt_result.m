%% 
%
%
%
%
%
clear all;
% add all paths
addpath('../satelliteImgRetriever/');
addpath('../roadModelGenerator/');
addpath('../patchGenerator/');
% target directory
pose_dir = '..\data\pose\';
road_dir = '..\data\model_stage2\';
gt_dir = '..\model_Evaluation\Integration_set2\';
%
start_chunk_id = 880;
end_chunk_id = 1079;
%
search_range = 12;
load_range = 3;
% test chunk
i = 992;
% load pose
pose = [];
for j = i-load_range:i+load_range
    cpose = dlmread(strcat(pose_dir,'chunk_',num2str(j),'_pose.fuse'));
    pose = cat(1, pose, cpose);
end%endfor j
pose = pose(1:20:end,:);
% load road model
gt = [];
for j = i-load_range:i+load_range
    cgt = csvread(strcat(gt_dir, 'Chunk_', num2str(j), '.csv'));
    cgt(:,3) = 0;
    cgt(:,6) = 0;
    gt = cat(2, gt, cgt(:,1:6));
end%endfor j
% load result
result = [];
for j = i-load_range:i+load_range
    cresult = csvread(strcat(road_dir, num2str(j), '.line'));
    result = cat(2, result, cresult(:,1:6));
end%endfor j

% initialize 
tileXYlist = [];
tileImagelist = [];
quadList =[];
%
for k = 1:size(pose,1)
    % query satellite tile
    [satelliteimg, windowcornersLLA, resolution, tileXYquadkey, tileXY] = lla2tile(pose(k,1:3), 20);
    % find if this tile has been processed
    tileIdx = findstr2idx(quadList, tileXYquadkey);
    if isempty(tileIdx)
        % save quad key to list
        quadList = cat(1, quadList, {tileXYquadkey});
        % save tileXY to list
        tileXYlist = cat(1, tileXYlist, tileXY);
    end
end%endfor k
% initialize canvas
M = max(tileXYlist(:,2)) - min(tileXYlist(:,2)) + 1 + 2;
N = max(tileXYlist(:,1)) - min(tileXYlist(:,1)) + 1 + 2;
aerialImg = zeros(M*256, N*256, 3);
% loop for each tile
for m = min(tileXYlist(:,2))-1:max(tileXYlist(:,2))+1
    for n = min(tileXYlist(:,1))-1:max(tileXYlist(:,1))+1
        % query aerial image again
        [satelliteimg, ~, ~, ~] = tileXY2tile([n m], 20);
        % merge to canvas
        xrangeStart = (M + (m - max(tileXYlist(:,2))-1-1))*256+1;
        xrangeEnd = (M + (m - max(tileXYlist(:,2))-1))*256;
        yrangeStart = (N + (n - max(tileXYlist(:,1))-1-1))*256+1;
        yrangeEnd = (N + (n - max(tileXYlist(:,1))-1))*256; 
        aerialImg(xrangeStart:xrangeEnd, yrangeStart:yrangeEnd, :) = double(satelliteimg)/255;
    end%endfor n
end%endfor m       
%
m = median(tileXYlist(:,2));
n = median(tileXYlist(:,1));
% query aerial image again
[~, windowcornersLLA, resolution, tileXYquadkey] = tileXY2tile([n m], 20);
%
% initialize ground truth mask
roadmodelmask = zeros(size(aerialImg,1), size(aerialImg,2));
gtmodelmask = zeros(size(aerialImg,1), size(aerialImg,2));
%
% aerialImg = aerialImg/2;
figure;
imshow(aerialImg);
hold on;
% project lines
for j = 1:4
    polyline = gt(j,:);
    polyline = reshape(polyline, [3 length(polyline)/3])';
    % sort it
    polyline = lineSortLLA(polyline);
    % project this polyline to image
    [pixelList, cmask] = line2tile(polyline, windowcornersLLA, [256 256]);
    % new locations
    pixelList(:,1)  = pixelList(:,1) + (M + (m - max(tileXYlist(:,2))-1-1))*256-1;
    pixelList(:,2)  = pixelList(:,2) + (N + (n - max(tileXYlist(:,1))-1-1))*256-1;
        % 
    plot(pixelList(:,2), pixelList(:,1),'r');
    % draw line
    for l = 1:size(pixelList,1)-1
        % get two control points
        p1 = pixelList(l,:);
        p2 = pixelList(l+1,:);
        % find the line
        [~, cmask] = line2pixel(p1, p2, [size(roadmodelmask,1) size(roadmodelmask,2)]);
        %
        gtmodelmask = gtmodelmask + cmask;
    end%endfor l
    %
    polyline = result(j,:);
    polyline = reshape(polyline, [3 length(polyline)/3])';
    % sort it
    polyline = lineSortLLA(polyline);
    % project this polyline to image
    [pixelList, cmask] = line2tile(polyline, windowcornersLLA, [256 256]);
    % new locations
    pixelList(:,1)  = pixelList(:,1) + (M + (m - max(tileXYlist(:,2))-1-1))*256-1;
    pixelList(:,2)  = pixelList(:,2) + (N + (n - max(tileXYlist(:,1))-1-1))*256-1;
        % 
    plot(pixelList(:,2), pixelList(:,1),'g');
    % draw line
    for l = 1:size(pixelList,1)-1
        % get two control points
        p1 = pixelList(l,:);
        p2 = pixelList(l+1,:);
        % find the line
        [~, cmask] = line2pixel(p1, p2, [size(roadmodelmask,1) size(roadmodelmask,2)]);
        %
        roadmodelmask = roadmodelmask + cmask;
    end%endfor l
end%endfor j
%==============================
% project pose
[posePixelList, poseMask] = line2tile(pose, windowcornersLLA, [256 256]);   
posePixelList(:,1)  = posePixelList(:,1) + (M + (m - max(tileXYlist(:,2))-1-1))*256;
posePixelList(:,2)  = posePixelList(:,2) + (N + (n - max(tileXYlist(:,1))-1-1))*256;
plot(posePixelList(:,2), posePixelList(:,1), 'y*');

for l = 1:size(posePixelList,1)-1
    plist = [];
    % get two control points
    p1 = posePixelList(l,:);
    p2 = posePixelList(l+1,:);
    % find the line
    [cpointList, cmask] = line2pixel(p1, p2, [256 256]);
    % find the perpendicular line
    [p1r, p1l, p2r, p2l] = line2pixel90(p1, p2, [256 256], search_range/min(resolution));
    %
    plot(p1r(:,2), p1r(:,1), 'b.');
    plot(p1l(:,2), p1l(:,1), 'b.');
    plot(p2r(:,2), p2r(:,1), 'b.');
    plot(p2l(:,2), p2l(:,1), 'b.');
    % 
    plist = [p1r;p1l;p2l;p2r;p1r];
    %
    plot(plist(:,2), plist(:,1), 'b--');
end%endfor l

F = getframe(gca);
hold off;
imwrite(F.cdata,...
    strcat(num2str(i),'.png'));