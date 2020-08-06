function abbr = var2abbr(v)
% find abbrivated variable names to save legend space
% g_exp.const.dynamic_var_names contains original variable name
% g_exp.const.dynamic_abbr_names contains abbreviated names with the same
% order.
%
% 2017 HRK
global g_exp
if isempty(g_exp)
    abbr = v;
    return;
end
orig_names  = g_exp.const.dynamic_var_names;
abbr_names = g_exp.const.dynamic_abbr_names;

% add REW_DURATION
orig_names{end+1} = 'REW_DURATION';
abbr_names {end+1} = 'Rew';

if isempty(g_exp), abbr = v; return; end;

bMatch = cellfun(@(x) strcmp(v, x),  orig_names );
if ~any(bMatch), abbr = v; return; end;

abbr = abbr_names{bMatch};
