function ginfo = ginfo2ginfo(ginfo, bVT)
% params2grp(): convert experimental conditions from candidate variables.
% 2017 HRK

params = struct()

for iP = 1:numel(ginfo.grp_label)
   params.(ginfo.grp_label{iP}) = ginfo.grp(:, iP);
end

ginfo = params2grp(params, bVT);