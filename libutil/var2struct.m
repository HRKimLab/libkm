function st = var2struct(cF)
% create structure from a list of variables
% name_value__name_value
% see struct2var for opposite operation
% 2020 HRK
st = struct();
for iF = 1:numel(cF)
    st.(cF{iF}) = evalin('caller', cF{iF});
end