function [psth bMatch] = adjust_psth_range(x, psth, adjust_anyway)
% adjust psth range to combine different x (time) range
% 2018 HRK
bMatch = 0;

if ~is_arg('bAllowNarrower'), bAllowNarrower = 0; end;

% do it in milisecond because floating point is erroneous and unpredictable
x = round(1000*x);
xl = minmax(x);

% save psth.x here since it will change below
psth_x = round(1000*psth.x);
psth_xl = minmax(psth_x);

% x perfectly matches
if size(x, 2) == size(psth_x,2) && all(x == round(1000*psth.x)) 
    assert(all(x == psth_x));
    bMatch = 1;
    return;
end
% 
% removing it arbitrary is not good. This routine may be made before 
% I have intersect routine. Now common x should be subset of all PSTHs. So
% skip this routine. Feb 2020. 
% % psth.x has one less element
% if size(x, 2) - 1 == size(psth_x, 2)
%     % add NaN to the last ones
%     fn = fieldnames(psth);
%     for iFD = 1:length(fn)
%         if size(x, 2) - 1 == size( psth.(fn{iFD}), 2)
%             psth.(fn{iFD})(:, end+1) = NaN;
%         end
%     end
%     if all(x == round(1000*psth.x))
%         bMatch = 1;
%         return;
%     end
% end
% 
% % psth.x has one more element
% if size(x, 2) + 1 == size(psth_x, 2)
%     % trim the last ones
%     fn = fieldnames(psth);
%     for iFD = 1:length(fn)
%         if size(x, 2) + 1 == size( psth.(fn{iFD}), 2)
%             psth.(fn{iFD})(:, end) = [];
%         end
%     end
%     if (all(x == round(1000*psth.x)) );
%         bMatch = 1;
%         return;
%     end
% end

% if psth_x range is larger than x, pick a subset that matches to given x
if xl(1) >= psth_xl(1) && xl(2) <= psth_xl(2)
    [bV, b] = ismember(psth_x, x);
    fn = fieldnames(psth);
    for iFD = 1:length(fn)
        if size( psth.(fn{iFD}), 2) == size(psth_x, 2)
            psth.(fn{iFD})(:, ~bV) = [];
        end
    end
    if numel(x) == numel(psth.x) && all(x == round(1000*psth.x))
        bMatch = 1;
        return;
    end
end

% if not subset, not match. return here if we don't 'adjust anyway' flag.
if ~adjust_anyway
    fprintf(1, 'PSTH size differs (x: [%.3f %.3f] != psth.x [%.3f %.3f])\n', xl(1), xl(2), psth_xl(1), psth_xl(2) );
    return
end

% adjust anyway even if psth is not the subset of target x. Fill with NaNs
psth = modify_psth(psth, 'adjust_x', 0, [-inf inf], x);
bMatch = 1;
return;