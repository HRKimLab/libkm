function ginfo = params2grp(params, bVT)
% params2grp(): convert experimental conditions from candidate variables.
% 2017 HRK

cP = fieldnames(params);
nP = length(cP);
DynParams = [];
DynArray = [];
if ~is_arg('bVT');
    bVT = true(size(params.(cP{1})));
end
nTrial = length(bVT);

% detect paramsters that vary across trials
for iP = 1:nP    
    % # of trials should be same
    assert( length(params.(cP{iP})) == nTrial, '# of trials should be same across params');
    % add to dynamic params if # of non-NAN values are greater than one
    if nunique(params.(cP{iP})(bVT) ) > 1
        DynParams = [DynParams cP(iP)];
        DynArray = [DynArray params.(cP{iP})];
    end
end

if isempty(DynArray) && all(bVT == false) % no valid trials
    ginfo.grp = NaN(size(bVT)); ginfo.grp_idx = NaN(size(bVT));
    ginfo.grp_label = {};
    ginfo.unq_grp = [];
    ginfo.unq_grp_label = {};
    ginfo.unq_grp_n = 0;
    return;
elseif isempty(DynArray)
    DynArray = ones(size(params.(cP{1})));
    DynArray(~bVT) = NaN;
    DynParams = {'Same'};
end

% make the trial invalid if all params are NaN
bVT = bVT & ~all(isnan(DynArray), 2);
% get unique conditions
[unq_grp n_cond] = munique(DynArray(bVT,:));
% noticed that the order of unq_grp is not constant.
[~, iS] = sortrows(unq_grp);
unq_grp = unq_grp(iS,:);
n_cond = n_cond(iS, :);

if size(unq_grp, 1) > 20
    disp('# of experimental variables >= 20');
    keyboard
end

% get grp_idx and unique group label
unq_grp_label = {};
grp_idx = NaN(size(DynArray,1), 1);
for iR = find(bVT);
   [a grp_idx(iR,1)] = ismember(DynArray(iR, :), unq_grp, 'rows');
end
for iR = 1:size(unq_grp, 1)
    unq_grp_label{iR, 1} = [];
    % generate group labels
    for iC = 1:size(DynArray,2)
        unq_grp_label{iR, 1} = [unq_grp_label{iR, 1} sprintf('%s=%s ', var2abbr(DynParams{iC}), num2str_short( unq_grp(iR,iC) ) )];
    end
    % eliminate last ' '
    unq_grp_label{iR, 1} = unq_grp_label{iR, 1}(1:end-1);
end

cP = cellfun(@var2abbr, DynParams,'un',false);
sParams = sprintf('%s ', cP{:});

% assign results to ginfo
ginfo.grp = DynArray;
ginfo.grp_idx = grp_idx;
ginfo.grp_label = DynParams;
ginfo.unq_grp = unq_grp;
ginfo.unq_grp_label = unq_grp_label;
ginfo.unq_grp_n = n_cond;
ginfo.sParams = sParams;

return