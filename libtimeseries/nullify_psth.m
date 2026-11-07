function ret_psth = nullify_psth(psth, bVT, n_grp)
% NULLIFY_PSTH make a psth whos size is same as psth but variables are NaNs
% nullify_psth(psth, psth.x < -2);
%
% 2020 HRK

ret_psth = psth;
if isempty(psth)
    warning('nullify_psth: psth is empty');
    return;
end

assert(strcmp(class(psth), 'struct'), 'psth should be struct');

if ~is_arg('bVT')
   bVT = true(size(psth.x)); 
end
if ~is_arg('n_grp')
    n_grp = size(psth.mean, 1);
end

assert(all(size(bVT) == size(psth.x)), 'bVT should be the same size as x');

cF = fieldnames(psth);
for iF = 1:numel(cF)
    switch(cF{iF})
        % do not nullify these meta information.
        case {'x','numel','gname','grp','idx_sorted_by_num','gnumel','n_grp'}
        otherwise % nullify data fields.
            if size(psth.(cF{iF}), 2) == size(bVT, 2) % timecourse data
                ret_psth.(cF{iF})(:, bVT) = NaN;
            else
                 ret_psth.(cF{iF}) = NaN(size(psth.(cF{iF})));
            end
    end
end