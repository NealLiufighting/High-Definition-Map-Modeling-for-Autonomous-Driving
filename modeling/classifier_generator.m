clear all
%
load('..\data\8_rectified.mat');
%
feature_vector = [];
for i = 1:300000%size(feature,3)
    % get patch
    patch = feature(:,:,i);
    % convert patch to hog feature
    patch_hog = extractHOGFeatures(patch,'Cellsize',[4 4]);
    % merge to feature vector
    feature_vector = cat(1, feature_vector, patch_hog);
end%endfor i
label = label(1:size(feature_vector),4);


b = TreeBagger(10, feature_vector, label,'Method','classification'); 

save('8_rectified_hog_rf.mat','b');