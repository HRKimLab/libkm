function [cStPSTHs grp_names] = grp_psth_structs(stPSTHs, group_type, name_format)
% group structured PSTH based on group type (e.g., subject, session, run)
% 2018 HRK
cStPSTHs = {};
grp_names = {};

if ~is_arg('group_type'), error('group_type should be given'); end
if ~is_arg('name_format'), name_format = 'unitkey5'; end;

cUnitname = fieldnames(stPSTHs);

% group names based on format
switch(name_format)
    case 'unitkey5'
        cKeys = cellfun( @str2unitkey5, cUnitname, 'un', false);
        keys = cat(1, cKeys{:});
        
        switch (group_type)
            case 'subject'
                grp_mask = [1 NaN NaN NaN NaN];
            case 'session'
                grp_mask = [1 1 NaN NaN NaN];
            case 'sessiononly'
                grp_mask = [NaN 1 NaN NaN NaN];
            case 'run'
                grp_mask = [1 1 1 NaN NaN];
            otherwise
                grp_mask = [1 1 1 1 1];
        end
        
        keys_for_grp = bsxfun(@times, keys, grp_mask);
        keys_for_grp(isnan(keys_for_grp)) = -999.998;
        % get unique keys for each group
        unq_keys = munique(keys_for_grp);
        % sort unique keys
        unq_keys = sortrows(unq_keys);
        % make group names
        grp_names = unitkey2str( bsxfun(@times, unq_keys, grp_mask));
    otherwise
        error('Unknown name format: %s', name_format');
end

nG = size(unq_keys, 1);
cStPSTHs = {}; % cell array of structured PSTHs
for iG = 1:nG
    bV = all( bsxfun(@minus, keys_for_grp, unq_keys(iG, :)) == 0, 2);
    % copy psths from souce to the current iterating group
    for iV = find(bV');
        unitname = cUnitname{iV};
        cStPSTHs{iG}.(unitname) = stPSTHs.(unitname);
    end
end

% sort each group
for iG = 1:nG
    [~,~,cStPSTHs{iG}] = sort_psth_structs(cStPSTHs{iG}, name_format);
end