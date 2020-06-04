function opendata(monkid, col_idx)
% opendata(monkid, col_idx)

MonkOfInterest = evalin('caller','MonkOfInterest');
iM = find(MonkOfInterest == monkid);
% retrieve column to result index information
pcd_col2res = evalin('caller','pcd_col2res');

iR = pcd_col2res(col_idx)

res_summary = evalin('caller',['ResultsSummary{' num2str(iR) '}']);

if isstr(res_summary)
    open(res_summary);
elseif iscell(res_summary) && length(res_summary) == 1
    open(res_summary{1});
elseif iscell(res_summary) && isdir(res_summary{1})
    error('Cannot open individual data for each neuron yet. need to code up later');
elseif iscell(res_summary)
    open(res_summary{iM});
end