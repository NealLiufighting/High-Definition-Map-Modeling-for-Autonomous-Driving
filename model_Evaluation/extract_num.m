%Input: File name with .line or .csv
%Output: File name with just number
function name_number=extract_num(name_full)
 if name_full(end)=='v'
    index1=find(name_full=='_');
    index2=find(name_full=='.');
    name_number=name_full(index1+1:index2-1);
 else
     index=find(name_full=='.');
     name_number=name_full(1:index-1);
 end