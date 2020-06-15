function [p fid] = setpanel(h, v, sTitle, bColumnFirst, parent_panel, orient_flag)
% wrapper function of panel_ext for easy layout
% 2015 HRK
% gP.orient = 0 : letter, landscape 
% gP.orient = 1 : letter, portrait
% gP.orient = 2 : based on figures (to make figures square)
global gP % for gnp function to auto-generate the next figure
if ~is_arg('bColumnFirst'), bColumnFirst = 0; end;
if ~is_arg('sTitle'), sTitle = ''; end;

if ~is_arg('orient_flag') && isstruct(gP) && isfield(gP, 'orient')
    orient_flag = gP.orient;
elseif ~is_arg('orient_flag')
    orient_flag = 0;
end

if ~is_arg('h') && ~is_arg('v')
    fid = create_figure(sTitle,orient_flag, h,v);
     p = panel_ext();
    return;
end

if ~is_arg('v')
    [h v] = get_panel_layout(orient_flag, h);
end


fid = create_figure(sTitle,orient_flag, h,v);
if isfield(gP, 'visible')
    set(fid, 'visible', gP.visible);
end
% create panel
if is_arg('parent_panel')
    p = parent_panel;
else
    p = panel_ext();
end
% set margins
p.marginleft = 13; p.marginright = 5; p.margintop = 13; p.marginbottom = 10;
% and some properties
p.fontsize = 10;
if bColumnFirst
   p.row_first = 0; 
end

% layout a variety of sub-panels
p.pack(h, v);
p.row_n = h;
p.col_n = v;

% register current configuraion for gnp() (automatic generation of figures)
% see gnp.m for more information
% using info from previous panel (e.g., p_new.row_n = p_prev.row_n) somehow did not
% work. just put things in the global structure
gP.panelinfo.row_first = p.row_first;
gP.panelinfo.row_n = h;
gP.panelinfo.col_n = v;
gP.panelinfo.fig_order = 1;
gP.panelinfo.title = sTitle;
gP.panelinfo.panel = {}; gP.panelinfo.panel{1} = p;

