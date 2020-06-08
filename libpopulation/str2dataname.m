function datanames = str2dataname(cU, varargin)
% take out electrode # and uint #
% cU can be cell array or string
% 2019 HRK

keep_structure = 0;
process_varargin(varargin);

if ischar(cU)
    cU = {cU};
end
% eliminate empty entity
bV = cellfun(@(x) ~isempty(x), cU);
cU = cU(bV);
% convert to unitkey5
uk = str2unitkey5(cU);
if numel(uk) > 3 % in case cU is ''
    uk(:, 4:5) = [];
end
datanames = unitkey2str(uk);
% datanames can be redundant if there are multiple neurons
if iscell(datanames)
    datanames = unique(datanames);
end