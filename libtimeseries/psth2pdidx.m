function [b_psth idx_pd] = psth2pdidx(stPSTH)
% PSTH2PDIDX determine if psth is the member of aPD, and get the row indice of 
%   aPD corresponding to the valid psths.
%
% This does very similar job to the Matlab's ismember() function.
% This makes it easy to transfer quantified values from psths to aPD.

% RETURN VALUES:
% b_psth: [n_psth * 1] logical vector. ith value is true if the ith psth 
%    has a single corresponding row in aPD.
% idx_pd: [nnz(b_psth) * 1] nonzero indice. ith value is the index of the
%    row in aPD corresponding to the ith path.
% 
% Example:
%   % qunatify psths using the time window
%   psth_val = mpsths2rate(stPSTH, 0, sWin, func);
%   % get indices
%   [b_psth idx_pd] = psth2pdidx(stPSTH);
%   % assign the values to the corresponding rows of the prepared columns
%   pd_vals(idx_pd,:) = psth_val(b_psth,:);
%
% See also psth2pdcol
%
% 2024 HRK

assert(isstruct(stPSTH));

aPD = evalin('base', 'aPD');

cF = fieldnames(stPSTH);
nF = numel(cF);

b_psth = false(nF, 1);
n_match = 0;

for iF = 1:nF
    if ~( isfield(stPSTH.(cF{iF}), 'x') && ~isempty(stPSTH.(cF{iF}).x) )
        warning('psth %s.x is empty', cF{iF});
        continue;
    end
    
    % find match in PD
    nkey = str2unitkey5( cF{iF} );
    bMatch = ismember(aPD(:, 1:5), nkey, 'rows');
    if nnz(bMatch) == 1
        n_match = n_match  + 1;
        b_psth(iF) = true;
        idx_pd(n_match) = find(bMatch);
    elseif nnz(bMatch)> 1
        error('More than one match found: %s', cF{iF});
    else
        b_psth(iF) = false;
        warning('No unitkey found(%s) in aPD.', cF{iF});
    end
end

if ~all(b_psth)
    warning('not all psths have corresponding unitkeys in aPD. Be careful!');
end

return;

