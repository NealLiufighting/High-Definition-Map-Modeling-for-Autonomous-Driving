%% This function generate line models with given prob map 
%
%
%
%
clear all
%
image_dir = '..\data\set2\';
% 
PROB_THRESHOLD = 120;
ANGLE_THRESHOLD = 10;
AREA_THRESHOLD = 40;
%
i = 971
% for i = 500:731
% for i = 810:1071 
    % load data
    satellite = imread(strcat(image_dir,num2str(i),'_satellite.png'));
    prob = imread(strcat(image_dir,num2str(i),'_prob.png'));
    mask = imread(strcat(image_dir,num2str(i),'_chunkmask.png'));
    traj = imread(strcat(image_dir,num2str(i),'_posemask.png'));
    corners = dlmread(strcat(image_dir,num2str(i),'.corners'));
    %
    satellite_grey = double(rgb2gray(satellite));
    %
    [m,n] = size(mask);
    % calculate traj
    pose = dlmread(strcat('..\data\pose\','chunk_',num2str(i),'_pose.fuse'));
    pose = pose(:,1:2);
    pose_pixel = lla2pixel(pose, corners, [m n]);
    % estimate traj orientation
    traj_direction = -atand((pose_pixel(end,1) - pose_pixel(1,1))/...
                           (pose_pixel(end,2) - pose_pixel(1,2)));
    % merge with mask
%     line_mask = double(mask>0).*double(prob>PROB_THRESHOLD);
    line_mask = double(prob>PROB_THRESHOLD);
    % find each region candidate
    L = bwlabel(line_mask);
    stats = regionprops(L, 'all');
    %
    line_candidate_mask = zeros(m,n);
    point_candidate_mask = zeros(m,n);
    temp_line = zeros(m,n);
    %
%     figure;
%     imshow(satellite)
%     hold on;
    % open file
%     fid = fopen(strcat(image_dir,num2str(i),'.line'),'w+');
    %
    for j = 1:length(stats)
        % 
        temp_mask = zeros(m,n);
        % filter out candidates
        if abs(stats(j).Orientation - traj_direction) <= ANGLE_THRESHOLD &&...
                stats(j).Area > AREA_THRESHOLD
            % 
            intensity_list = [];
            %
            for k = 1:length(stats(j).PixelList)
                line_candidate_mask(stats(j).PixelList(k,2), stats(j).PixelList(k,1)) = 1;
                temp_mask(stats(j).PixelList(k,2), stats(j).PixelList(k,1)) = 1;
                intensity_list = cat(1, intensity_list, satellite_grey(stats(j).PixelList(k,2), stats(j).PixelList(k,1)));
            end
            % find top X values threshold
            intensity_list_sorted = sort(intensity_list,'descend');
            intensity_threshold = intensity_list_sorted(round(stats(j).MajorAxisLength/2));
            %
            point_candidate_mask = point_candidate_mask +...
                                   double(satellite_grey.*temp_mask>intensity_threshold);
            % fit line
            [x, y] = find(double(satellite_grey.*temp_mask>intensity_threshold)==1);
            [p,S] = polyfit(x,y,1);
            % check angle
            if atand(p(1))+90 - traj_direction < 10
                % draw line
                minX = min(x);
                maxX = max(x);
                minY = min(y);
                maxY = max(y);
                x1 = [minX:1:maxX];
                y1 = polyval(p,x1);
                for k = 1:length(x1)
                    if x1(k) && round(y1(k))>=minY && x1(k)<=m && round(y1(k))<=maxY
                        temp_line(x1(k), round(y1(k))) = 1;
                    end
                end%endfor k
                % conver to lla
                x1 = [minX, maxX];
                y1 = polyval(p,x1);
                p1 = pixel2lla([x1(1) y1(1)], corners, [m, n]);
                p2 = pixel2lla([x1(2) y1(2)], corners, [m, n]);
%                 fprintf(fid,'%.8f, %.8f, %.8f, %.8f\n',p1, p2);
            end%endif
%             plot(y1, x1, 'r');
        end
    end%endfor j
    satellite = double(satellite)/255;
    vis = cat(3,temp_line*2 + satellite(:,:,1),...
                  (line_candidate_mask + satellite(:,:,2)).*~temp_line,...
                  zeros(m,n) + satellite(:,:,3).*~temp_line);
    vis = vis(257:2*256,:,:);
    imwrite(vis, strcat(num2str(i),'_lineregion.png'));
%     fclose(fid);
    disp(i)
% end%endfor i