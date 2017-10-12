%% This function loads road model json files and return
%  polylines
%
%
%
%
%
function [] = json2function(jsonfiles)
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
    chunk = loadjson([fullpath jsonfiles(i+2).name]);
    % load lines
    lines = chunk.bundle{1}.lines;
   count=0;
 %check the number of solid line and dashlines
    for q=1:length(lines)
        line=lines{q};
        if strcmp(line.id, '-1')
            
        else
            
        if isfield(line.attributes{1},'function')
              check_function=line.attributes{1}.function
          else
              check_function=line.attributes{2}.function
          end%end for check exist
              
            if check_function==1
                
            else
                count=count+1;
            end
        end
    end
    content=cell(count,1);
    count_valid=0;
    for j = 1:length(lines)
        % load line
        line = lines{j};
        % only parse non-pose line (id~=-1)
        if ~strcmp(line.id, '-1')
            
        %only parse solid line and dash line, check function is in
        %attribute1 or 2 first
          if isfield(line.attributes{1},'function')
              check_function=line.attributes{1}.function;
          else
              check_function=line.attributes{2}.function;
          end%end for check exist
              
            if check_function==1
                
            else
                count_valid=count_valid+1;            
                content{count_valid,1}=check_function;
      
          
            end     %end for function check
        else

        end %end for if id
    end%endfor j
 name=jsonfiles(i+2).name;
 name=[name(1:9) '.function'];
 cell2csv(['D:\Runsheng\Matlab\Mapreader\roadModelGenerator\Function_set1\' name ], content, ',', '2017','.')
end%endfor i
