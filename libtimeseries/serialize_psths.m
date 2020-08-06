function [st sBorder] = serialize_psths(st, start_win, end_win)
% serialize psths with possbly more than one groups.
% 2018 HRK
if isstruct(st) && ~isfield(st, 'x')  % population psth
   cF = fieldnames(st);
   nF = numel(cF);
   for iF = 1:nF
       [st.(cF{iF}) sBorder] = serialize_single_psth(st.(cF{iF}), start_win, end_win);
   end
elseif isstruct(st) && isfield(st, 'x') % single psth
    [st sBorder] = serialize_single_psth(st, start_win, end_win);
elseif iscell(st)
    nF = numel(st);
    for iF = 1:nF
       [st{iF} sBorder] = serialize_single_psth(st{iF}, start_win, end_win);
    end
end

return;