function set_param(param, val)
params = getParameterSelection();

keys = cell(rows(params), 1);
for k=1:length(keys)
	keys(k,1) = params(k,1);
end

values = zeros(rows(params), 1);
for k=1:length(values)
	values(k,1) = cell2mat(params(k,2));
end

