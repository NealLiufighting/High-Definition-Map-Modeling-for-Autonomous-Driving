%Input: Path of groundtruth file
%       Path of prediction file
%       CSV name you want
%Output:CSV file with matched lines
function evaluation=model_input(groundtruth_path,model_path,csv_filename)
groundtruth=dir(strcat(groundtruth_path,'/*.csv'));
prediction=dir(strcat(model_path,'/*.line'));
%there are several chunks not valid beacause lack of solid lines
valid_filelist=check_validation(groundtruth,groundtruth_path);
count=1;
evaluation=cell(size(prediction,1),7);
for i=1:size(valid_filelist,1)
    name=valid_filelist(i);
    name=name{1,1};
    name_check=extract_num(name);%just compare the number
        for j=1:size(prediction,1)
            name_test=prediction(j).name;
            match_name=extract_num(name_test);   
          %if they are the same chunk,evaluate the two models      
            if  isequal(match_name,name_check) %if they are the same chunk
                s=dir(strcat(model_path,'/',name_test)); 
                if s.bytes ~= 0 %check if the csv is empty
                patch_match=model_evaluation2(name,groundtruth_path,name_test,model_path);
                sizes=size(patch_match,2);
                evaluation{count,1}=name_check;
                for q=1:sizes
                    evaluation{count,q+1}=patch_match(q);
                end
                    
                count=count+1;
                else
                    evaluation{count,1}=name_check;
                    M1=csvread(name);
                    len=size(M1,1);
                    for t=1:len
                        evaluation{count,t+1}=0;
                    end
                    count=count+1;
                end
            end
        end
end
%evaluation=evaluation(~cellfun('isempty',evaluation))
index=0;
for i=1:size(evaluation,1)
    if isempty(evaluation{i})
        index=i;
        break;
    end
end

cell2csv(csv_filename, evaluation(1:index-1,:), ',', '2017','.');
                
             
                
                
                
                
                
                
                
                
                
                
                
                
                