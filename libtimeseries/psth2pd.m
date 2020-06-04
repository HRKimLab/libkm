function psth2pd(stPSTH, sWin, entry, func)
% calculate mean response from stPSTH in the given time window
% [# of psths X 1]
% 2018 HRK
assert(isstruct(stPSTH));
% for now, sWin should be 1X2 vector
assert(size(sWin,1) == 1 && size(sWin,2) == 2);
if ~is_arg('func'), func = @(x) nanmean(x, 2); end;

nWin = size(sWin, 1);
assert(nWin == 1);

aPD = evalin('base', 'aPD');

vals = NaN(size(aPD,1), 1);

% stPSTH is structure of psths
if ~isfield(stPSTH, 'x')
    cF = fieldnames(stPSTH);
    nF = numel(cF);
    % use the most frequent group #
    for iF = 1:nF
        if ~( isfield(stPSTH.(cF{iF}), 'x') && ~isempty(stPSTH.(cF{iF}).x) )
            warning('psth %s.x is empty', cF{iF});
            avggrp_rate = NaN;
        else
            
            psth = stPSTH.(cF{iF});
            bV = sWin(1, 1) <= psth.x & psth.x < sWin(1, 2);
            rate = func( psth.mean(:, bV) );
            assert(size(rate, 2) == 1); % use 1 sWin for now
            
            % compute weighted average of rates across group
            avggrp_rate = sum( bsxfun( @times, rate, psth.n_grp/sum(psth.n_grp) ) );
        end
        % find match in PD
        nkey = str2unitkey5( cF{iF} );
        bMatch = ismember(aPD(:, 1:5), nkey, 'rows');
        if nnz(bMatch) == 1
            vals(bMatch) = avggrp_rate;
        elseif nnz(bMatch)> 1
            error('More than one match found: %s', cF{iF});
        else
            warning('No match found: %s', cF{iF});
        end
    end
    
    % register value to PD
    add_pcd_col({entry}, vals);
    return;
end
