function ginfo = table2ginfo(param_tb, bVT)
% TABLE2GINFO convert table to ginfo
% 2020 HRK
% create group info

nonzero_params = struct();
for iC = 1:size(param_tb, 2)
    nonzero_params.(param_tb.Properties.VariableNames{iC}) = param_tb{:, iC};
end
ginfo = params2grp(nonzero_params, bVT);