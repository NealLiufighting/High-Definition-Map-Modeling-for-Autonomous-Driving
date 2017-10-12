%% This function generates rectified patches (solution 2)
%
%
clear all;
% add all paths
addpath('../satelliteImgRetriever/');
addpath('../roadModelGenerator/');
addpath('../jsonlab/');
addpath('../patchGenerator/');
% target directory
save_dir = 'G:\SatelliteImageRoadModelling\testing_result\set3\';
% pose directory
pose_dir = 'G:\SatelliteImageRoadModelling\pose\';
% find quad list
% try 
%     load quadList.mat
% catch
%     disp('Quad key list file does not exist. Initialize new quad key list file');
%     quadList = [];
% end
%
% start_chunk_id = 500;
% end_chunk_id = 731;

start_chunk_id = 810;

end_chunk_id = 1079;

load_range = 1;
search_range = 15;
samplerate = 4;
% test chunk
% i = 230;
for i = start_chunk_id:end_chunk_id
    % load pose
    pose2 = cat(1, dlmread(strcat(pose_dir,'chunk_',num2str(i),'_pose.fuse')),...
                   dlmread(strcat(pose_dir,'chunk_',num2str(i+1),'_pose.fuse')));
    % downsample pose
    pose = pose2([1,end],:);
    % initialize 
    tileXYlist = [];
    tileImagelist = [];
    % check which tile to visit
    for k = 1:size(pose,1)
        % query satellite tile
        [~, ~, ~, ~, tileXY] = lla2tile(pose(k,1:3), 20);
        % find if this tile has been processed
%         tileIdx = findstr2idx(quadList, tileXYquadkey);
%         if isempty(tileIdx)
            % save quad key to list
%             quadList = cat(1, quadList, {tileXYquadkey});
            % save tileXY to list
            tileXYlist = cat(1, tileXYlist, tileXY);
%         end
    end%endfor k
    % initialize canvas
    M = max(tileXYlist(:,2)) - min(tileXYlist(:,2)) + 1 + 2;
    N = max(tileXYlist(:,1)) - min(tileXYlist(:,1)) + 1 + 2;
    aerialImg = zeros(M*256, N*256, 3);
    % initialize corners list
    regioncorners = zeros(4,2);
    % loop for each tile
    for m = min(tileXYlist(:,2))-1:max(tileXYlist(:,2))+1
        for n = min(tileXYlist(:,1))-1:max(tileXYlist(:,1))+1
            % query aerial image again
            [satelliteimg, windowcornersLLA, ~, ~] = tileXY2tile([n m], 20);
            % merge to canvas
            xrangeStart = (M + (m - max(tileXYlist(:,2))-1-1))*256+1;
            xrangeEnd = (M + (m - max(tileXYlist(:,2))-1))*256;
            yrangeStart = (N + (n - max(tileXYlist(:,1))-1-1))*256+1;
            yrangeEnd = (N + (n - max(tileXYlist(:,1))-1))*256; 
            aerialImg(xrangeStart:xrangeEnd, yrangeStart:yrangeEnd, :) = double(satelliteimg)/255;
            % assign corner
            % UL->BL->UR->BR
            if m == min(tileXYlist(:,2)) - 1 && n == min(tileXYlist(:,1)) - 1 % upper left corner
                regioncorners(1, :) = windowcornersLLA(1, :);  
            elseif m == max(tileXYlist(:,2)) + 1 && n == min(tileXYlist(:,1)) - 1 % bottom left corner
                regioncorners(2, :) = windowcornersLLA(2, :);  
            elseif m == min(tileXYlist(:,2)) - 1 && n == max(tileXYlist(:,1))+ 1 % upper right corner
                regioncorners(3, :) = windowcornersLLA(3, :);  
            elseif m == max(tileXYlist(:,2)) + 1 && n == max(tileXYlist(:,1))+ 1 % bottom right corner
                regioncorners(4, :) = windowcornersLLA(4, :); 
            else
                continue;
            end
        end%endfor n
    end%endfor m       
    %
    m = median(tileXYlist(:,2));
    n = median(tileXYlist(:,1));
    % query aerial image again
    [~, windowcornersLLA, resolution, tileXYquadkey] = tileXY2tile([n m], 20);
    % initialize ground truth mask
    roadmodelmask = zeros(size(aerialImg,1), size(aerialImg,2));
    %
%     figure;
%     imshow(aerialImg);
%     hold on;
    %==============================
    % project entire pose
    [~, pose_mask] = line2tile(pose2, regioncorners, [M*256 N*256]);  
    % project pose
    [posePixelList, ~] = line2tile(pose, windowcornersLLA, [256 256]);   
    posePixelList(:,1)  = posePixelList(:,1) + (M + (m - max(tileXYlist(:,2))-1-1))*256+1;
    posePixelList(:,2)  = posePixelList(:,2) + (N + (n - max(tileXYlist(:,1))-1-1))*256+1;
%     plot(posePixelList(:,2), posePixelList(:,1), 'y*');
    % get corners of chunk
    % get two control points
    p1 = posePixelList(1,:);
    p2 = posePixelList(2,:);
    % find the line
    [cpointList, cmask] = line2pixel(p1, p2, [256 256]);
    % find the perpendicular line
    [p1r, p1l, p2r, p2l] = line2pixel90(p1, p2, [256 256], search_range/min(resolution));
    %
%     plot(p1r(:,2), p1r(:,1), 'b.');
%     plot(p1l(:,2), p1l(:,1), 'b.');
%     plot(p2r(:,2), p2r(:,1), 'b.');
%     plot(p2l(:,2), p2l(:,1), 'b.');
    % 
    plist = [p1r;p1l;p2l;p2r];
    %
%     plot(plist(:,2), plist(:,1), 'g-');
% 
%     F = getframe(gca);
%     hold off;
    % fill up chunk mask
    chunk_mask = zeros(size(aerialImg,1), size(aerialImg,2));
    polygon.vert = plist;
    chunk_mask = myScanline(chunk_mask, polygon, 1);
    %==================================================
    % write to files
    % write chunk mask
    imwrite(chunk_mask, strcat(save_dir, num2str(i), '_chunkmask.png'));
    % write pose mask
    imwrite(pose_mask, strcat(save_dir, num2str(i), '_posemask.png'));
    % write satellite image
    imwrite(aerialImg, strcat(save_dir, num2str(i), '_satellite.png'));
    % write corners
    dlmwrite(strcat(save_dir, num2str(i), '.corners'),...
            regioncorners,...
            'precision', '%.10f');
%     newimage = [];
%     newgtimage = [];
% 
%     for l = 1:size(posePixelList,1)-1
%         plist = [];
%         % get two pose points from lla
%         p1_lla = pose(l,1:3);
%         p2_lla = pose(l+1,1:3);
%         % calculate p1 to p2 distance
%         p1_ecef = lla2ecef(p1_lla);
%         p2_ecef = lla2ecef(p2_lla);
%         p1_p2_dist = norm(p1_ecef - p2_ecef);
%         % get two control points
%         p1 = posePixelList(l,:);
%         p2 = posePixelList(l+1,:);
%         % find the line
%         [cpointList, cmask] = line2pixel(p1, p2, [256 256]);
%         % find the perpendicular line
%         [p1r, p1l, p2r, p2l] = line2pixel90(p1, p2, [256 256], search_range/mean(resolution));
%         % rectify this small patch
%         imr = rectify(aerialImg, [p1l;p2l;p2r;p1r], [p1_p2_dist/mean(resolution) search_range*2/mean(resolution)]);
%         % merge image
%         newimage = cat(2, newimage, imr);
%         % rectify his small patch
%         gtimr = rectify(double(roadmodelmask>0), [p1l;p2l;p2r;p1r], [p1_p2_dist/mean(resolution) search_range*2/mean(resolution)]);    
%         % merge to gt image
%         newgtimage = cat(2, newgtimage, gtimr);
%     end%endfor l
% 
% %     aerialImg2 = double(newimage)/255; 
%     aerialImg2 = newimage;
%     visualfig2 = cat(3, (aerialImg2(:,:,1)+newgtimage),...
%                 aerialImg2(:,:,2).*~newgtimage, (aerialImg2(:,:,3).*~newgtimage));
%     aerialImg2 = aerialImg;
%     visualfig = cat(3, (aerialImg2(:,:,1)+roadmodelmask),...
%                 aerialImg2(:,:,2).*~roadmodelmask, (aerialImg2(:,:,3).*~roadmodelmask));
%     % save road model mask
%     imwrite(newgtimage, strcat(target_mask_dir, num2str(i),'.png'));
%     imwrite(newimage, strcat(target_satellite_dir, num2str(i),'.png'));
%     imwrite(F.cdata(2:end-1,:,:), strcat(target_check_dir, num2str(i),'.png'));
% %     imwrite(visualfig, strcat(target_check_dir, num2str(i),'_fuse.png'));
%     imwrite(visualfig2, strcat(target_image_dir, num2str(i),'.png'));
%     %
%     close all;
end%endfor i