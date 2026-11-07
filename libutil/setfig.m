function fid = setfig(h, v, sTitle, orient_f)
% SETFIG Create figure for easy creation of panels
%   setfig(h, v, sTitle) creates a figure with sTitle. It fixes the layout 
%     of panels at the time of figure creation. You call gna to obtain an axis.
%     when you frequently add/remove panels in a figure, you will see setfig()
%     is more convenient thant subplot().
%     h: # of panels in row
%     v: # of panels in column
%     sTitle: title of the figures
%
%   setfig(h, v, sTitle, orient_f) specify the orientation of the
%     figure. 0 (landsacpe), 1 (portrait), 2 (dependent on subplots). 
%     If 2 is given, it makes the shape of the figure proportional to the # of rows 
%     and columns of the square panels. It's useful if you make many figures.
%     
%   If you want to pack more panels into a figure, check out setpanel. it uses panel
%   class and enables you to adjust layout and margins in detail.
%
% See also GNA, SETPANEL
%
% HRK

global gP
% figinfo.h  : # of horizontal axis
% figinfo.v  : # of vertical axis
% figinfo.iP : current axis
% figinfo.hP : axis handles
if isstruct(gP) && isfield(gP, 'orient')
    orient_flag = gP.orient;
else
    orient_flag = 0;
end
if is_arg('orient_f'), orient_flag = orient_f; end;

if ~is_arg('sTitle'), sTitle = ''; end;

if ~is_arg('v')
    [h v] = get_panel_layout(orient_flag, h);
%     if orient_flag % old config for portrait layout
%         if h <= 6, h=3; v=2;
%         elseif h <= 8, h=4; v=2;
%         elseif h <= 12, h=4; v=3;
%         elseif h <= 15, h=5; v=3;
%         elseif h <= 20, h=5; v=4;
%         elseif h <= 24, h=6; v=4;
%         elseif h <= 28, h=7; v=4;
%         elseif h <= 32, h=8; v=4;
%         end
%     else % new config for landscape layout
%         if h <= 3, h=h; v=1;
%         elseif h == 4, h=2; v=2;
%         elseif h <= 6, h=2; v=3;
%         elseif h <= 8, h=2; v=4;
%         elseif h <= 12, h=3; v=4;
%         elseif h <= 15, h=3; v=5;
%         elseif h <= 20, h=4; v=5;
%         elseif h <= 24, h=4; v=6;
%         elseif h <= 28, h=4; v=7;
%         elseif h <= 32, h=4; v=8;
%         end
%     end
end
srcsz = get(0, 'screenSize');

% fid=figure;
fid = create_figure(sTitle, orient_flag, h, v);

% evalin('caller', ['figinfo.h = ' num2str(h) ';']);
% evalin('caller', ['figinfo.v = ' num2str(v) ';']);
% evalin('caller', ['figinfo.iP = 1;']);
% evalin('caller', ['figinfo.hP = [];']);

gP.figinfo.h = h;
gP.figinfo.v = v;
gP.figinfo.iP = 1;
gP.figinfo.hP = [];