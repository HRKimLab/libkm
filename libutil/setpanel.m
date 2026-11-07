function [p fid] = setpanel(h, v, sTitle, bColumnFirst, parent_panel, orient_flag)
% SETPANEL a wrapper function of panel_ext for easy layout
%   It is an advanced version of setfig(). This allows you to use panel()
%   class, which is an advaced version of subplot(). 
%   (See https://kr.mathworks.com/matlabcentral/fileexchange/20003-panel for detail)
%
%   For example, you can organzie in a hierarchical manner and set margins 
%   in detail (e.g., top, bottom, left, right separately). I added the
%   following functions to the panel, mimicing setfig() and gna().
%  
%   p.gna: get next axis in the panel object. (similar to gna for setfig)
%   p.pnp: get next panel object.
% 
% gP.orient = 0 : letter, landscape. 
% gP.orient = 1 : letter, portrait.
% gP.orient = 2 : based on # of rows and columns of square panels.
% 
% Examples:
% This creates 5 * 2 square panels with very little margin.
% p = setpanel(5, 2, 'test1', 0, [], 2);
% p.margin = 8; % you can change the margins later
% p.gna;
%
% See also SETFIG
%
% 2015 HRK

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

