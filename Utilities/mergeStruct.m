function merged_s = mergeStruct(structA, structB)
%MERGESTRUCT Merge 2 struct 
%   

    merged_s = structB;
    f = fieldnames(structA);
    for i = 1:length(f)
    merged_s.(f{i}) = structA.(f{i});
    end
    
end

