%% This function loads road model json files and return
%  polylines
%
%
%
%
%
function [] = json2lines(jsonfiles)
% test data
clear all;

%addpath('..\jsonlab\');
jsonfolder = '../testing/testing_set1';
jsonfiles=dir(jsonfolder);
fullpath=[jsonfolder '/'];
%==========================
% structure of map
% map
%   line
%       id
%       point
%           lat
%           lon
%           alt
%       type: [left, right]
%       function: [solid, dashed, boundary]
%       parentId: 
%   mapVersion: Bing Tile Server version
%   imageLevel: level of satellite imagery when coded
%   lineList: list of line ids
%==========================
% search all files
for i = 1:length(jsonfiles)
    % load chunk json
    if i==length(jsonfiles)-2
        break
    end
        
    chunk = loadjson([fullpath jsonfiles(i+2).name]);
    % load lines
    lines = chunk.bundle{1}.lines;
    count=0;
 %check the number of solid line and dashlines
    for q=1:length(lines)
        line=lines{q};
        if strcmp(line.id, '-1')
            
        else
        %if it hass a structure field, means it is boudary,which we don't want    
        if isfield(line.attributes{1},'structure')
              
        elseif isfield(line.attributes{2},'structure')
            
        else
              count=count+1;
          end%end for check exist
       
        end
    end
    %record every line's geo points and functions
    content=cell(count,7);
    count_valid=0;
    for j = 1:length(lines)
        % load line
        line = lines{j};
        % only parse non-pose line (id~=-1)
        if ~strcmp(line.id, '-1')
            
        %only parse solid line and dash line, so check 
        %wheher there is a strucutre first
          if isfield(line.attributes{1},'structure')
              
          elseif isfield(line.attributes{2},'structure')
            
                
            else
            %convert the poly points to ecef and save them
                count_valid=count_valid+1;
                polypoint_ecef=zeros(length(line.polyPoints),3);
                 for k = 1:length(line.polyPoints)
                    lat = line.polyPoints{k}.geoPoint.latitude_deg;
                    lon = line.polyPoints{k}.geoPoint.longitude_deg;
                    alt = line.polyPoints{k}.geoPoint.altitude_m;
                    tarPolyPoints = [lat lon alt];
                    ecef_coordinate=lla2ecef(tarPolyPoints);
                    polypoint_ecef(k,:)=ecef_coordinate;
                    
                end%endfor k
                % We need to extract X,Y as input Z as output for linear
                % regression
                X=polypoint_ecef(:,1:2);
                Target=polypoint_ecef(:,3);
                %attach 1 for bias term
                X=[ones(size(X,1),1) X];
                %get the weight for linear regression
                weight=regress(Target,X);
                %fit the line
                pT=X*weight;
                %save the start and end point
                startpoint=ecef2lla([X(1,2) X(1,3) pT(1,:)]);
                endpoint=ecef2lla([X(end,2) X(end,3) pT(end,:)]);
                content{count_valid,1}=startpoint(1);
                content{count_valid,2}=startpoint(2);
                content{count_valid,3}=startpoint(3);
                content{count_valid,4}=endpoint(1);
                content{count_valid,5}=endpoint(2);
                content{count_valid,6}=endpoint(3);
                %add function to matrix
                if isfield(line.attributes{1},'function')
                       check_function=line.attributes{1}.function;
                else
                     check_function=line.attributes{2}.function;
                end
                
                if check_function==3
                    content{count_valid,7}=3;
                else
                    content{count_valid,7}=2;
                end %end for add function to matrix
          
            end     %end for function check
        else

        end %end for if id
    end%endfor j
 name=jsonfiles(i+2).name;
 if length(name)==15
     name=[name(1:10) '.csv'];
 else
    name=[name(1:9) '.csv'];
 end
 if content{1,end}~=2 || content{end,end}~=2
     name1{i,1}=name;
 end
 cell2csv(['D:\Runsheng\Matlab\Mapreader\roadModelGenerator\Integration_set1\'  name], content, ',', '2017','.')
end%endfor i
name1