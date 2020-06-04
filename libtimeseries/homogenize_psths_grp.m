function [stPSTH b_valid] = homogenize_psths_grp(stPSTH, varargin)
% make uniform x and groups to combine different psths
% 2019 HRK

grp = [];
grp_mode = 'intersect'; % 'union', 'manual', 'max'
debug = 0;

process_varargin(varargin);

%% homogenize x
% TODO: this routine may not work correctly when x is distance
% convert it to milisecond because floating point is erroneous and unpredictable
psth_ids = fieldnames(stPSTH);
nPSTH = numel(psth_ids);
b_valid = true(nPSTH, 1);

% gather information about x for each psth
[x_bin x_min x_max] = structfun(@get_psth_x_info, stPSTH);

if debug, print_psth_info(stPSTH); end;
    
if nunique(x_bin) == 1
    x_bin = unique(x_bin);
else
%     warning('x bin is mroe than one: %s', num2str(unique(x_bin)));
    error('x bins of PSTHs are mroe than one: %s', num2str(unique(x_bin)));
end

% get the range of x including manual x
switch(x_mode)
    case 'intersect'
        xl(1) = max([x_min; min(x)]);
        xl(2) = min([x_max; max(x)]);
    case 'union'
        xl(1) = min([x_min; min(x)]);
        xl(2) = max([x_max; max(x)]);
    case 'manual'
        assert(~isempty(x), 'x should not be empty');
        xl = minmax(x);
    otherwise
        error('Unknown x_mode: %s', x_mode);
end

% get target x
x = xl(1):x_bin:xl(2);    
% target ms and ms limit
ms = round(1000 * x);
msl = minmax(ms);
% debug info
fprintf(1, 'target x: %.2f:%.2f:%.2f\n', xl(1), x_bin, xl(2) );

% iterate each psth and modify psth fields
for iP = 1:nPSTH
   psth = stPSTH.(psth_ids{iP});

   % save psth.x here since it will change below
    psth_ms = round(1000*psth.x);
    psth_msl = minmax(psth_ms);
    
    % x perfectly matches. do nothing
    if size(ms, 2) == size(psth_ms,2) && all(ms == psth_ms)
        assert(all(ms == psth_ms));
        continue;
    end

    % iterate psth fields
    cF = fieldnames(psth);
    nF = numel(cF);
    switch(x_mode)
        case 'intersect' % ms is always a subset of psth_ms
            bVSrc = ismember(psth_ms, ms);
            % reduce the source psth size
            for iFD = 1:nF
                if size( psth.(cF{iFD}), 2) == size(psth_ms, 2)
                    psth.(cF{iFD})(:, ~bVSrc) = [];
                end
            end
            % double check that the size of psth.x matches to the target
            assert(all(size(psth.x) == size(x)));
            psth.x = x;
    
        case 'union' % psth_ms is always as subset of x
            bVDst = ismember(ms, psth_ms);
            % reduce the source psth size
            for iFD = 1:nF
                if size( psth.(cF{iFD}), 2) == size(psth_ms, 2)
                    tmp = psth.(cF{iFD});
                    psth.(cF{iFD}) = NaN(size(tmp, 1), size(ms, 2) );
                    psth.(cF{iFD})(:, bVDst) = tmp;
                end
            end
            % double check that the size of psth.x matches to the target
            assert(all(size(psth.x) == size(x)));
            psth.x = x;
        case 'manual' % this can replace the upper two. just leave them for speed
            bVSrc = ismember(psth_ms, ms);
            bVDst = ismember(ms, psth_ms);
            % reduce the source psth size
            for iFD = 1:nF
                if size( psth.(cF{iFD}), 2) == size(psth_ms, 2)
                    tmp = psth.(cF{iFD})(:, bVSrc);
                    psth.(cF{iFD}) = NaN(size(tmp, 1), size(ms, 2) );
                    psth.(cF{iFD})(:, bVDst) = tmp;
                end
            end
            % double check that the size of psth.x matches to the target
            assert(all(size(psth.x) == size(x)));
            psth.x = x;
    end
    
    % assign the modified psth back to the structure
    stPSTH.(psth_ids{iP}) = psth;
end

% double check that psth Xs are homogenized
[x_bin x_min x_max] = structfun(@get_psth_x_info, stPSTH);
assert(size(unique([x_bin x_min x_max], 'rows'), 1) == 1);

return;


function [a, b, c, d] = get_psth_grp_info(psth)
a = numel(psth.n_grp);