function p = gnp()
% get next panel and generate new panel if necessary
% 2017 HRK
global gP
p = [];
if isempty(gP) || ~isfield(gP, 'panelinfo')
    error('gP.panelinfo does not exist');
end

% use try-catch to detect error
bNew = 0;
try
    p = gP.panelinfo.panel{end}.gnp;
catch ME
    bNew = 1;
end

% generate new panel
if bNew
    gP.panelinfo.fig_order = gP.panelinfo.fig_order + 1;
    create_figure([gP.panelinfo.title ': ' num2str( gP.panelinfo.fig_order )], 0);
    gP.panelinfo.panel{end+1} = panel_ext();
    
    gP.panelinfo.panel{end}.row_first = gP.panelinfo.row_first;

    gP.panelinfo.panel{end}.pack(gP.panelinfo.row_n, gP.panelinfo.col_n);
    gP.panelinfo.panel{end}.row_n = gP.panelinfo.row_n;
    gP.panelinfo.panel{end}.col_n = gP.panelinfo.col_n;
    
    gP.panelinfo.panel{end}.margintop = 10;
    p = gP.panelinfo.panel{end}.gnp;
end