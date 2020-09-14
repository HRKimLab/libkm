function psths = eval_psths(psths, expr)
% loop a struct composed of psths and evaluate expression for individual psths
% eval_psths(ft_neuron, 'psth.event.TELEPORT_CD(3) = psth.event.TELEPORT_CD(2)');
%
% 2020 HRK

% iterate psths
if ~isfield(psths, 'x')
    psths = structfun(@(x) eval_psths(x, expr), psths, 'un', false);
    return;
%     % iterate fields
%     cF = fieldnames(psths);
%     nF = numel(cF);
%     % use the most frequent group #
%     for iF = 1:nF
%         assert( isfield(psths.(cF{iF}), 'x') );
%         psths.(cF{iF}) = eval_psths(psths.(cF{iF}), expr);
%     end
%     return;
end

% here, psth is single psth structure
psth = psths;
assert(~isempty(findstr(expr, 'psth.')), 'expr should have psth.');
% add ';' if not exist
if isempty(findstr(expr, ';'))
    expr = [expr ';'];
end
% evaluate psth assuming that the variable name is 'psth'
eval(expr);
psths = psth;