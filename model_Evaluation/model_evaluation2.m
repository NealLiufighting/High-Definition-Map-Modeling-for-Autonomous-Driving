%%the specific case that number of lines can match for each function 
function pair_match=model_evaluation2(groundtruth,groundtruth_path,prediction,model_path)
addpath('Integration_set2');
addpath('model');
%now for testing purpose, change the file structure later
M1=csvread(strcat(groundtruth_path,'/',groundtruth));
M2=csvread(strcat(model_path,'/',prediction));
M1(:,3)=0;
M1(:,6)=0;
%add some error manually for evaluation,creat a fake testing model
%M2=M1;
%M2(:,3)=0;
%M2(:,6)=0;
%evaluate the number of lines mismacth
num_match=0;
%Save the matched pairs
pair_match=zeros(1,size(M1,1));
if size(M2,1)==0
    return
end
%transfer lla 2 ecef
M1_ecef=zeros(size(M1,1),size(M1,2));
M2_ecef=zeros(size(M2,1),size(M2,2));
num_match=size(M2,1)-size(M1,1);
for i=1:size(M1,1)
    M1_ecef(i,1:3)=lla2ecef(M1(i,1:3));
    M1_ecef(i,4:6)=lla2ecef(M1(i,4:6));
    M1_ecef(i,7)=M1(i,7);
end

for i=1:size(M2,1)
    M2_ecef(i,1:3)=lla2ecef(M2(i,1:3));
    M2_ecef(i,4:6)=lla2ecef(M2(i,4:6));
    M2_ecef(i,7)=M2(i,7);
end

%visualize the two models
X=[M1_ecef(:,1) M1_ecef(:,4);M2_ecef(:,1) M2_ecef(:,4)]' ;
Y=[M1_ecef(:,2) M1_ecef(:,5);M2_ecef(:,2) M2_ecef(:,5)]';
Z=[M1_ecef(:,3) M1_ecef(:,6);M2_ecef(:,3) M2_ecef(:,6)]';
%plot3(X,Y,Z)
%check if there is a miss in solid line



if M2_ecef(1,end)==2 & M2_ecef(end,end)==2
    if size(M2_ecef,1)==1%if there is only one solid line in the whole image
        M1_solid1=M1_ecef(1,:);
        M1_solid2=M1_ecef(end,:);
        M2_solid1=M2_ecef(1,:);
        d1=point_to_line(M2_solid1(1:3),M1_solid1(1:3),M1_solid1(4:6));
        d2=point_to_line(M2_solid1(1:3),M1_solid2(1:3),M1_solid2(4:6));
        if d1>d2
             pair_match(1,end)=1;
        else 
             pair_match(1,1)=1;
        end
        return 
    end
        
        
%calculate the road width of the ground truth first
M1_solid1=M1_ecef(1,:);
M1_solid2=M1_ecef(end,:);
d1=point_to_line(M1_solid2(1:3),M1_solid1(1:3),M1_solid1(4:6));
d2=point_to_line(M1_solid2(4:6),M1_solid1(1:3),M1_solid1(4:6));
M1_width=(d1+d2)/2;
%Now find the road width of test model
M2_solid1=M2_ecef(1,:);
M2_solid2=M2_ecef(end,:);
d1=point_to_line(M2_solid2(1:3),M2_solid1(1:3),M2_solid1(4:6));
d2=point_to_line(M2_solid2(4:6),M2_solid1(1:3),M2_solid1(4:6));
M2_width=(d1+d2)/2;
%Now we match the solid  line,save in a 14*2 matrix

d1=point_to_line(M1_solid1(1:3),M2_solid1(1:3),M2_solid1(4:6));
d2=point_to_line(M1_solid1(1:3),M2_solid2(1:3),M2_solid2(4:6));
if d1>d2 %M2 solid line2 macth M1 solid line 1
    solid_match(1,:)=[M1_solid1 M2_solid2];
    pair_match(1,1)=size(M2_ecef,1);
    solid_match(2,:)=[M1_solid2 M2_solid1];
    pair_match(1,end)=1;
else %else solid1 match solid1
    solid_match(1,:)=[M1_solid1 M2_solid1];
     pair_match(1,1)=1;
    solid_match(2,:)=[M1_solid2 M2_solid2];
    pair_match(1,end)=size(M2_ecef,1);
end
%if there are only two solid lines
if size(M2_ecef,1)==2
    
else

    %next we match the dash line
    M1_dashlines=M1_ecef(2:end-1,:);
    M2_dashlines=M2_ecef(2:end-1,:);
    %save the match pair of dashlines
    dash_match=zeros(size(M1_dashlines,1),14);
    %save the lines that there is no match
    no_match=0;
    for i=1:size(M1_dashlines,1)
        d11=point_to_line(M1_dashlines(i,1:3),solid_match(1,1:3),solid_match(1,4:6));
        d12=point_to_line(M1_dashlines(i,4:6),solid_match(1,1:3),solid_match(1,4:6));
        d1=(d11+d12)/2;
        %normalize the distance for scale problem
        normalized_d1=d1/M1_width;
        t=0.2;%every distance difference beyond this value will be regarded as a considerable match
        dmin=1000000;%this is set for avoiding multiple match in one dash line
        for j=1:size(M2_dashlines,1)
            %check the normalized distance between M2 dashlines and M2 solid
            %lines
            d21=point_to_line(M2_dashlines(j,1:3),solid_match(1,8:10),solid_match(1,11:13));
            d22=point_to_line(M2_dashlines(j,4:6),solid_match(1,8:10),solid_match(1,11:13));
            d2=(d22+d21)/2;
            normalized_d2=d2/M2_width;
            %check whether the two dashline match by compare the difference of
            %the distance
            if abs(normalized_d1-normalized_d2)<t && abs(d1-d2)<dmin
                dmin=abs(d1-d2);%%this is for avoiding multiple lines in matching area
                dash_match(i,:)=[M1_dashlines(i,:),M2_dashlines(j,:)];  
                pair_match(1,i+1)=j+1;
            end
        end
        %if there is no match for this dashline,then record it


    end
end

else
    if M2_ecef(1,end)==2
        %if the last solid line is missing, then the road width will be
        %solid line and dash line, but we need to match solid line first
        M2_solid=M2_ecef(1,:);
        M2_dashbouandry=M2_ecef(end,:);
        d1=point_to_line(M2_dashbouandry(1:3),M2_solid(1:3),M2_solid(4:6));
        d2=point_to_line(M2_dashbouandry(4:6),M2_solid(1:3),M2_solid(4:6));
        M2_width=(d1+d2)/2;
        %match solid line first
        M1_solid1=M1_ecef(1,:);
        M1_solid2=M1_ecef(end,:);
        d1=point_to_line(M1_solid1(1:3),M2_solid(1:3),M2_solid(4:6));
        d2=point_to_line(M1_solid2(1:3),M2_solid(1:3),M2_solid(4:6));
        if d1>d2 %means M2 solid 2 match with M1 solid
            pair_match(1,end)=1;
            solid_match=size(M1,1);
        else
            pair_match(1,1)=1;
            solid_match=1;
            
        end 
        %next match the dash boundary
        M1_dashlines=M1_ecef(2:end-1,:);
        dmin=10000;
        match=0;%record which line match with the dashline boundary
        for k=1:size(M1_dashlines,1)
            dash=M1_dashlines(k,:);
            d1=point_to_line(dash(1:3),M2_dashbouandry(1:3),M2_dashbouandry(4:6));
            d2=point_to_line(dash(4:6),M2_dashbouandry(1:3),M2_dashbouandry(4:6));
            d=(d1+d2)/2;
            if dmin>d
                dmin=d;
                match=k+1;
            else
            end
        end
        %calculate the road width of M1
        pair_match(1,match)=size(M2_ecef,1);
        M1_dashboundary=M1_ecef(match,:);
        M1_solidboundary=M1_ecef(solid_match,:);
        d1=point_to_line(M1_dashboundary(1:3),M1_solidboundary(1:3),M1_solidboundary(4:6));
        d2=point_to_line(M1_dashboundary(4:6),M1_solidboundary(1:3),M1_solidboundary(4:6));
        M1_width=(d1+d2)/2;
        %now we get the road width of two models
        if size(M2_ecef,1)==2 %if model just has one solid line and one dash line,then return
            return
        end
        %retrive M2 rest dashlines
        M2_dashlines=M2_ecef(2:end-1,:);
        %compare each dash line in M1 with M2
        for i=1:size(M1_dashlines,1)
        d11=point_to_line(M1_dashlines(i,1:3),M1_solidboundary(1,1:3),M1_solidboundary(1,4:6));
        d12=point_to_line(M1_dashlines(i,4:6),M1_solidboundary(1,1:3),M1_solidboundary(1,4:6));
        d1=(d11+d12)/2;
        %normalize the distance for scale problem
        normalized_d1=d1/M1_width;
        t=0.1;%every distance difference beyond this value will be regarded as a considerable match
        dmin=1000000;%this is set for avoiding multiple match in one dash line
        for j=1:size(M2_dashlines,1)
            %check the normalized distance between M2 dashlines and M2 solid
            %lines
            d21=point_to_line(M2_dashlines(j,1:3),M2_solid(1,1:3),M2_solid(1,4:6));
            d22=point_to_line(M2_dashlines(j,4:6),M2_solid(1,1:3),M2_solid(1,4:6));
            d2=(d22+d21)/2;
            normalized_d2=d2/M2_width;
            %check whether the two dashline match by compare the difference of
            %the distance
            if abs(normalized_d1-normalized_d2)<t && abs(d1-d2)<dmin
                dmin=abs(d1-d2);%%this is for avoiding multiple lines in matching are
                pair_match(1,i+1)=j+1;
            end
        end
        %if there is no match for this dashline,then record it
        end% end size(M1,1) for
        
    elseif M2_ecef(end,end)==2
           %if the last solid line is missing, then the road width will be
        %solid line and dash line, but we need to match solid line first
        M2_solid=M2_ecef(end,:);
        M2_dashbouandry=M2_ecef(1,:);
        d1=point_to_line(M2_dashbouandry(1:3),M2_solid(1:3),M2_solid(4:6));
        d2=point_to_line(M2_dashbouandry(4:6),M2_solid(1:3),M2_solid(4:6));
        M2_width=(d1+d2)/2;
        %match solid line first
        M1_solid1=M1_ecef(1,:);
        M1_solid2=M1_ecef(end,:);
        d1=point_to_line(M1_solid1(1:3),M2_solid(1:3),M2_solid(4:6));
        d2=point_to_line(M1_solid2(1:3),M2_solid(1:3),M2_solid(4:6));
        if d1>d2 %means M2 solid 2 match with M1 solid
            pair_match(1,end)=size(M2,1);
            solid_match=size(M1,1);
        else
            pair_match(1,1)=size(M2,1);
            solid_match=1;
            
        end 
        %next match the dash boundary
        M1_dashlines=M1_ecef(2:end-1,:);
        dmin=10000;
        match=0;%record which line match with the dashline boundary
        for k=1:size(M1_dashlines,1)
            dash=M1_dashlines(k,:);
            d1=point_to_line(dash(1:3),M2_dashbouandry(1:3),M2_dashbouandry(4:6));
            d2=point_to_line(dash(4:6),M2_dashbouandry(1:3),M2_dashbouandry(4:6));
            d=(d1+d2)/2;
            if dmin>d
                dmin=d;
                match=k+1;
            else
            end
        end
        %calculate the road width of M1
        pair_match(1,match)=1;
        M1_dashboundary=M1_ecef(match,:);
        M1_solidboundary=M1_ecef(solid_match,:);
        d1=point_to_line(M1_dashboundary(1:3),M1_solidboundary(1:3),M1_solidboundary(4:6));
        d2=point_to_line(M1_dashboundary(4:6),M1_solidboundary(1:3),M1_solidboundary(4:6));
        M1_width=(d1+d2)/2;
        %now we get the road width of two models
        if size(M2_ecef,1)==2 %if model just has one solid line and one dash line,then return
            return
        end
        %retrive M2 rest dashlines
        M2_dashlines=M2_ecef(2:end-1,:);
        %compare each dash line in M1 with M2
        for i=1:size(M1_dashlines,1)
        d11=point_to_line(M1_dashlines(i,1:3),M1_solidboundary(1,1:3),M1_solidboundary(1,4:6));
        d12=point_to_line(M1_dashlines(i,4:6),M1_solidboundary(1,1:3),M1_solidboundary(1,4:6));
        d1=(d11+d12)/2;
        %normalize the distance for scale problem
        normalized_d1=d1/M1_width;
        t=0.1;%every distance difference beyond this value will be regarded as a considerable match
        dmin=1000000;%this is set for avoiding multiple match in one dash line
        for j=1:size(M2_dashlines,1)
            %check the normalized distance between M2 dashlines and M2 solid
            %lines
            d21=point_to_line(M2_dashlines(j,1:3),M2_solid(1,1:3),M2_solid(1,4:6));
            d22=point_to_line(M2_dashlines(j,4:6),M2_solid(1,1:3),M2_solid(1,4:6));
            d2=(d22+d21)/2;
            normalized_d2=d2/M2_width;
            %check whether the two dashline match by compare the difference of
            %the distance
            if abs(normalized_d1-normalized_d2)<t && abs(d1-d2)<dmin
                dmin=abs(d1-d2);%%this is for avoiding multiple lines in matching are
                pair_match(1,i+1)=j+1;
            end
        end
        %if there is no match for this dashline,then record it
        end% end size(M1,1) for
    else %in this case, there is no solid lines, maybe one dashlines or two or three
        for i=1:size(M2_ecef,1)
            dash=M2_ecef(i);
            M1_dashlines=M1_ecef(2:end-1,:);
            dmin=10000;
            match=0;
            for k=1:size(M1_dashlines,1)
            M1_dash=M1_dashlines(k);
            d1=point_to_line(dash(1:3),M1_dash(1:3),M1_dash(4:6));
            d2=point_to_line(dash(4:6),M1_dash(1:3),M1_dash(4:6));
            d=(d1+d2)/2;
            if dmin>d
                dmin=d;
                match=k+1;
            else
            end
            end
            pair_match(1,match)=i;
        end
    end
end

        
            




    
