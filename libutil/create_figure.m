function fid = create_figure(sTitle, orient_flag, h, v, size_mult)
% create figure for analysis. separated from setpanel
% orient_flag : 0: landscape 1: portrait 2: depends on the subplots
% 5/30/2018 HRK
global gP

if ~isfield(gP, 'remote')
    gP.remote = 0;
end

if ~is_arg('size_mult')
    size_mult = 1;
end

fid = figure;

% get screen size
% srcsz = get(0, 'screenSize'); not good. screen size when started
ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment;
gd = ge.getDefaultScreenDevice;
srcsz = [1 1 gd.getDisplayMode.getWidth gd.getDisplayMode.getHeight];

% if gP.remote == 1 % local monitor
    figsz = [735 560];
% else                % remote desktop
    
%      figsz = [840 640];    
%     figsz = [1050 800];
%     figsz = [945 720];
% end

% orient portrait
papersize = [11 8.5];

if orient_flag == 0 % 0: landscape 

elseif orient_flag == 1 % % 1: portrait 
    papersize = fliplr(papersize);
    figsz = fliplr(figsz);
elseif orient_flag == 2  % 2: depends on the subplots
    if is_arg('h') && is_arg('v')
        % I need to invert h and v
        papersize = [v h] * 2.75;
        figsz = [v h] * 200;
    else
         warning('h and v shoud be given for orient_flag = 2. use 0 instead')
         orient_flag = 0;
    end
end

figsz = figsz * size_mult;

set(fid,'papersize', papersize);
% set(fid,'paperposition',[.25 .25 papersize(1)-0.5 papersize(2)-0.5]);
set(fid,'paperposition',[0 0 papersize(1) papersize(2)]);
set(fid,'PaperPositionMode','auto'); % don't resize figure for printing.
set(fid, 'renderer', 'zbuffer', 'renderermode', 'manual');

% if srcsz(4) > 1000
curpos = get(fid, 'position');
% Assuming that defult figure position is resonable, keep the left side and top side of
% the current figure. By that, we can keep the title bar still on screen even if 
% remote desktop mess it up.
set(fid, 'Position', [curpos(1) curpos(2)+curpos(4)-figsz(2) size_mult * figsz]);

if is_arg('sTitle')
    fig_title(sTitle);
end