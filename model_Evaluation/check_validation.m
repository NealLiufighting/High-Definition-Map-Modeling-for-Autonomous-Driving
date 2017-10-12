%Input: filename lists,file path
%Output:Valid filename lists(delete the chunks with missing lines)
function valid_filelist=check_validation(files,groundtruth_path)
addpath('Integration_set2')
count=1;
for i=1:length(files)
   
    name=files(i).name;
    M=csvread(strcat(groundtruth_path,'/',name));
    if M(1,end)~=2 || M(end,end)~=2;
    else
        valid_filelist{count,:}=name;
        count=count+1;
    end
end
valid_filelist