function [grpidx u_grp cL] = mgrp2idx(grp)
% werid. grpstats works with group argument being array, 
% but a simpler function, grp2idx, doesn't work.
% don't use num2str of gname because it is desn't have floating-point
% accuracy.

if ~isnumeric(grp)
    error('mgrp2idx only works for numeric array.');
end
u_grp = munique(grp);
% munique doesn't sort rows. so it have to be sorted to be matched with
% grpstats
u_grp = sortrows(u_grp);
% 
[tmp grpidx] = ismember(grp, u_grp, 'rows');
% legend

for iR = 1:size(u_grp, 1)
    cL{iR} = sprintf('%.2f  ', u_grp(iR,:));
    cL{iR}(end-1:end) = [];
end
