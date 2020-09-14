function formatfig(fig_list, font_size, bReposition)
% format figure for presentation or paper
% 2016 HRK
% before: formatfig(font_size, fig_list, bReposition)
global gP
if isfield(gP, 'show_label') gShowLabel = gP.show_label; 
else, gShowLabel = 1; end;
if ~is_arg('font_size'), font_size = 11; end;
if ~is_arg('fig_list')
    fig_list = gcf;
end
if strcmp(fig_list, 'all')
    fig_list = sort(fig2num( get(0, 'child') ))';
end
if ~is_arg('bReposition')
    bReposition = 0;
end

font_unit = 'points';

if bReposition
    % undock figure
    set(fig_list, 'WindowStyle','normal');
    pos = get(fig_list, 'position');
    for iF=1:size(pos,1)
        set(fig_list(iF), 'position', [pos(iF,1) pos(iF, 2) 400 400]);
    end
end

% iterate figures
for fid = fig_list
    % set font size
    set(findobj(fid,'type','text'),'fontsize',font_size,'fontunits', font_unit);
    % for p value text, decrease a bit
    set(findobj(fid,'type','text','tag','pval'),'fontsize',font_size*0.8,'fontunits', font_unit);
    % tick label
    set(findobj(fid,'type','axes'),'fontsize',font_size,'fontunits', font_unit);
    
    % reference line
    set(findobj(fid,'type','line','tag','ref'),'linewidth', 1);
    % do not use ':' for now. PDF converted shape is ugly
%     set(findobj(fid,'type','line','tag','ref','linestyle',':'),'linewidth', 3);
    
    % axis label
    for hA = findobj(fid, 'type','axes')'
%         hA
        switch( get(hA, 'tag') )
            case 'Colorbar' 
                % set tick direction outward
                set(hA,'tickdir','out');
                % increase tick length a bit
                set(hA, 'ticklength', [0.01 0.025]);
                % erase box outline
                box(hA, 'off')
                
            case 'legend'
                if gShowLabel
                 set(hA, 'fontsize', font_size * 0.8, 'fontunits', font_unit);
                else
                    delete(hA); continue;
                end
            otherwise
                set(hA, 'linewidth', 1);
                % set tick direction outward
                set(hA,'tickdir','out');
                % increase tick length a bit
                set(hA, 'ticklength', [0.015 0.025]);
                % erase box outline
                box(hA, 'off')
                % reduce # of ticks if necessary
                reduce_axis_tick(hA);
                
                hX = get(hA,'xlabel');
                hY = get(hA,'ylabel');
                if gShowLabel
                    set(hX, 'fontsize', font_size,'fontunits', font_unit);
                    set(hY, 'fontsize', font_size,'fontunits', font_unit);
                else
                    delete(hX); delete(hY);
                end
                
                % title
                if isfield(gP, 'show_title') && gP.show_title
                    
                else
                    title(hA, '');
                end
                    
                % re-adjust pval texts
                hP = findobj(hA, 'tag','pval');
                yl = get(hA, 'ylim');
                for iT = 1:length(hP)
                    pos = get(hP(iT), 'Position');
                    set(hP(iT), 'Position', [pos(1) yl(2) 0]);
                end
                
        end
        
        set(hA, 'XTickMode','manual', 'XTickLabelMode','manual', ...
            'YTickMode','manual', 'YTickLabelMode','manual', 'ZTickMode','manual', 'ZTickLabelMode','manual');
        
        if isfield(gP, 'editor') && strcmp(gP.editor, 'Illustrator')
            set(hA, 'color','none');
        end
    end
end

% set ticks
xrange = range(xlim);
%xrange/3
yrange = range(ylim);

% if fig_list has only one element, copy the figure to clipboard
% if length(fig_list) == 1
%    print -dmeta  -noui 
% end