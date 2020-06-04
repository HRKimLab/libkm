function varargout = withingrpfun(x,y,statsfunc, grpvar,iter_grp,sgrpvar,iter_sgrp)
% make subgroups using descrete variables and compute stats for each group
% [# of grp * # of subgrp]. grp: subjects, subgrp: conditions

% if we don't have subgroup, set it all to one
if nargin < 5, sgrpvar = ones(size(x)); iter_sgrp = 1; end;

nG = length(iter_grp); nSG = length(iter_sgrp);
for iG=1:nG % row
    for iSG=1:nSG % col
        % select rows include in current group
       bM = ismember(grpvar,iter_grp(iG)) & ismember(sgrpvar,iter_sgrp(iSG)) ;
       %[a1(iG,iSG) a2(iG,iSG)] = corr(x(bM),y(bM),'type','Spearman','rows','pairwise');
       [varargout{1}(iG,iSG) varargout{2}(iG,iSG) varargout{3}(iG,iSG) varargout{4}(iG,iSG)] = stat_func(x(bM),y(bM),statsfunc);
    end
    bM = ismember(grpvar,iter_grp(iG));
    %[a1(iG,nSG+1) a2(iG,nSG+1) a3(iG,iSG+1) a4(iG,iSG)] = stat_func(x(bM),y(bM),statsfunc);
    [varargout{1}(iG,nSG+1) varargout{2}(iG,nSG+1) varargout{3}(iG,nSG+1) varargout{4}(iG,nSG+1)] = stat_func(x(bM),y(bM),statsfunc);
end
for iSG=1:nSG
    bM = ismember(sgrpvar,iter_sgrp(iSG)) ;
    %[a1(nG+1,iSG) a2(nG+1,iSG) a3(iG,iSG) a4(iG,iSG)] = stat_func(x(bM),y(bM),statsfunc);
    [varargout{1}(nG+1,iSG) varargout{2}(nG+1,iSG) varargout{3}(nG+1,iSG) varargout{4}(nG+1,iSG)] = stat_func(x(bM),y(bM),statsfunc);
end

%[a1(nG+1,nSG+1) a2(nG+1,nSG+1) a3(iG,iSG) a4(iG,iSG)] = stat_func(x(bM),y(bM),statsfunc);
[varargout{1}(nG+1,nSG+1) varargout{2}(nG+1,nSG+1) varargout{3}(nG+1,nSG+1) varargout{4}(nG+1,nSG+1)] = stat_func(x,y,statsfunc);

return;

function varargout = stat_func(x,y,functype)
switch(functype)
    case 'scorr'
        [r p] = corr(x,y,'type','Spearman','rows','pairwise');
        varargout{1} = r; varargout{2} = p; varargout{3} = NaN; varargout{4} = NaN; 
    case 'pcorr'
        [r p] = corr(x,y,'type','Pearson','rows','pairwise');
        varargout{1} = r; varargout{2} = p; varargout{3} = NaN; varargout{4} = NaN; 
    case {'regress2ci', 'reg2ci'}
        bV = all(~isnan([x(:) y(:)]),2);
        [slope, intercept, bint, aint, r, p]=regress_perp(x(bV),y(bV),0.05,1)
        varargout{1} = slope; varargout{2} = intercept; varargout{3} = {bint}; varargout{4} = {aint}; 
    case {'regress2', 'reg2'}
        bV = all(~isnan([x(:) y(:)]),2);
        [slope, intercept]=regress_perp(x(bV),y(bV),0.05,1)
        varargout{1} = slope; varargout{2} = intercept; varargout{3} = {[NaN NaN]}; varargout{4} = {[NaN NaN]}; 
    case {'regress2zeroitc', 'reg2zeroitc'}
        bV = all(~isnan([x(:) y(:)]),2);
        [slope, intercept]=regress_perp(x(bV),y(bV),0.05,2)
        varargout{1} = slope; varargout{2} = intercept; varargout{3} = {[NaN NaN]}; varargout{4} = {[NaN NaN]}; 
    case {'reg2ci_zeroitc'}
        bV = all(~isnan([x(:) y(:)]),2);
        [slope, intercept, bint, aint, r, p]=regress_perp(x(bV),y(bV),0.05,2)
        varargout{1} = slope; varargout{2} = intercept; varargout{3} = {bint}; varargout{4} = {aint}; 
    case 'N'
        bV = all(~isnan([x(:) y(:)]),2);
        varargout{1} = nnz(bV); varargout{2} = NaN; varargout{3} = NaN; varargout{4} = NaN; 
end
return;
