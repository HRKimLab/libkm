function st = var2struct(cF)
% VAR2STRUCT create structure from a list of variables
% name_value__name_value
% see also STRUCT2VAR
%
% 2020 HRK
st = struct();
for iF = 1:numel(cF)
    st.(cF{iF}) = evalin('caller', cF{iF});
end