function tb = print_psths_info(stPSTH)
% PRINT_PSTHS_INFO print verbose information about struct of psths
% 
% 2019 HRK

% construct a table containing psth meta information
fn = fieldnames(stPSTH);
c_grp_label = struct2cell( structfun(@get_grp_label, stPSTH, 'un', false) );
assert(numel(fn) == numel(c_grp_label) );
tb = array2table([structfun(@(x) min(x.x), stPSTH) structfun(@(x) max(x.x), stPSTH) ...
    structfun(@(x) diff(x.x(1:2)), stPSTH) structfun(@(x) size(x.mean, 1), stPSTH)], ...
    'VariableNames', {'x1','x2','dx', 'n_grp'}, 'RowNames', fn );
% assign group label if exists
tb{:, 'GrpLabel'} = c_grp_label;

% print out the metadata table
disp(tb);

function grp_label = get_grp_label(x)

grp_label = '';
if isfield(x, 'ginfo') && ~isempty(x.ginfo) && isfield(x.ginfo, 'grp_label')
%     grp_label = x.ginfo.grp_label;
    grp_label = sprintf('%s ', x.ginfo.grp_label{:} );
end