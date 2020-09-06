function dn = repo_dataname2dataname(rd)
% take out first repo
% 2020 HRK
assert(iscell(rd), 'x should be cell array of string');
% check if all elements have '_' which connects repoid and dataname
assert(all( cellfun(@(x) ~isempty(findstr(x, '_')), rd)  ), 'some do not have _ separator');

dn = cellfun(@(x) x(findstr(x, '_')+1:end), rd, 'un', false)