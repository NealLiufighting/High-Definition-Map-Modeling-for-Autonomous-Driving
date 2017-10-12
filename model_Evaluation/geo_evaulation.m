%input: mapping file
%output:a csv for geo difference
function geo_evaulation(filename)
addpath('Integration_set2');
addpath('model_stage1');
Model=dlmread(filename);
geo_evaluation=cell(size(Model,1),7);
for i=1:size(Model,1)
    name=Model(i,1);
    geo_evaluation{i,1}=name;
    groundtruth=csvread(strcat('Chunk_',num2str(name),'.csv'));
    groundtruth(:,3)=0;
    groundtruth(:,6)=0;
    s=dir(['model_stage1/',strcat(num2str(name),'.line')]);
    if s.bytes ==0
        for k=1:size(groundtruth,1)
        geo_evaluation{i,k+1}='NAN';
        end
    else
    prediction=csvread(strcat(num2str(name), '.line'));
    M1_ecef=zeros(size(groundtruth,1),size(groundtruth,2));  
    M2_ecef=zeros(size(prediction,1),size(prediction,2));
    
    for m=1:size(groundtruth,1)
    M1_ecef(m,1:3)=lla2ecef(groundtruth(m,1:3));
    M1_ecef(m,4:6)=lla2ecef(groundtruth(m,4:6));
    M1_ecef(m,7)=groundtruth(m,7);
    end
    
    for n=1:size(prediction,1)
    M2_ecef(n,1:3)=lla2ecef(prediction(n,1:3));
    M2_ecef(n,4:6)=lla2ecef(prediction(n,4:6));
    M2_ecef(n,7)=prediction(n,7);
    end

    for j=2:size(Model,2)
        if Model(i,j)==0
            geo_evaluation{i,j}='NAN';
        else
            d1=point_to_line(M2_ecef(Model(i,j),1:3),M1_ecef(j-1,1:3),M1_ecef(j-1,4:6));          
            d2=point_to_line(M2_ecef(Model(i,j),4:6),M1_ecef(j-1,1:3),M1_ecef(j-1,4:6));
            d=(d1+d2)/2;
            geo_evaluation{i,j}=d;
        end
    end
    end
end
cell2csv2(['geo_evaluation.csv'], geo_evaluation, ',', '2017','.');

    