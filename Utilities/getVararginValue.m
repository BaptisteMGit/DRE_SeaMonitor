function value = getVararginValue(Varargin, VarName, DefaultValue)
% var = Varargin{:};
idx  = find(strcmp(VarName,  Varargin));
if ~isempty(idx)
    idx = idx(1); % Get first argument in case several exist 
    value = Varargin{idx+1};
else
    value = DefaultValue;
end
end