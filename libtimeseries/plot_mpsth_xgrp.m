function [p, ax, gnames, cPSTH] = plot_mpsth_xgrp(stPSTH, varargin)
% Plot averaged PSTHs across groups, which is defined by group_type
% 2018 HRK
parent_panel = [];
parent_ax = [];
% new: generate new axis and arrange vertically,
% add: add plots to existing axis. can be used when scaling is similar
% attach: generate new axis and superimpose it to the existing axis
% axis_type = 'new';
errbar_type = 'none';
cmap = [];              % color map
xl = [];                % fixed xlim
smooth_win = [];        % re-smooth origianl mean if necessary (too much jiter to show in a small axis)
group_type = 'session';
name_format = 'unitkey5';
axis_type = 'new';
plot_type = 'line';     % line or image
individual_psths = 0;
gnames = {};

process_varargin(varargin);

ax = [];
set_lim = 1;
p = [];
assert(isstruct(stPSTH) || iscell(stPSTH));

if isstruct(stPSTH)
    % group structured PSTHs based on criterion
    [cStPSTH gnames] = grp_psth_structs(stPSTH, group_type, name_format);
elseif iscell(stPSTH)
    cStPSTH = stPSTH;
end

% get number of groups
nG = length(cStPSTH);

% set gnames unless assigned
if isempty(gnames)
    gnames = arrayfun(@(x) sprintf('G%d', x), 1:nG, 'un',false);
end
% load running history from m_all.m
load_history();

% create a panel unless specified
if isempty(parent_ax)
    p = setpanel(nG, [], sprintf('PSTHs gb %s', group_type) );
    p.margin = 12;
    for iG = 1:nG
        ax(iG, 1) = p.gna;
    end
else % parent_ax is given
    nCol = size(parent_ax, 2);
    for iG = 1:nG
        % find axis with the dataname
%         dataname = regexprep( gnames{iG}, 'e[0-9]*u[0-9]*','');
        dataname = gnames{iG};
        hA = findobj(parent_ax,'tag', dataname);
        assert(numel(hA) == 1); % for now, let's think about only 1. but it could be more.
        
        switch(axis_type)
            case 'add' % find the existing axis with the dataname
                set_lim = 0;
                if ~isempty(hA)
                    ax(iG) = hA;
                end
            case 'attach'
                % generate axes for neural data
                pos = get(hA, 'position');
                ax(iG) = axes('position', pos);
                % linke position
                hLP = linkprop([hA, ax(iG)], 'position');
                % assign link position to UserData( necessary to keep linked)
                set(ax(iG), 'UserData', hLP);
                % link x axes
                linkaxes([hA, ax(iG)], 'x'); % don't link y axis
        end
    end
end

data_title = set_mpsth_titles(gnames);

% % plot averaged PSMA from each group
for iG = 1:nG
%     psth = cPSTH{iG};
%     axes(ax(iG));
    % plot peri-stimulus moving average
%     [~,~,hL] = plot_psma(psth, errbar_type, cmap, 'smooth_win', smooth_win,'ax', ax(iG)); 
    
    stPSTH = cStPSTH{iG};
    nPSTHs = numel( fieldnames(stPSTH) );
    plot_mpsths(stPSTH, 'ax', ax(iG), 'plot_type', plot_type, 'individual_psths', individual_psths);
    
    % delete legend
%     if iG ~= 1 && iG ~= nG
%         delete(hL);
%     end
    draw_refs(0, 0, NaN, ax(iG)); if ~isempty(xl), set(ax(iG), 'xlim', xl); end;
    
    % make title of the plot
    sT = gnames{iG};
    dataname = regexprep(gnames{iG}, 'e[0-9]*u[0-9]*', '');
    % set tag as dataname. Tag will be used for superimposed plots.
    set(ax(iG), 'Tag', dataname);
%     if isfield(psth, 'ginfo') && ~isempty(psth.ginfo)
%         ctr_params = sprintf('%s,', psth.ginfo.grp_label{:});
%     else
%         ctr_params = '';
%     end
    
    % remove virmen_def
    %     [pname] = dataname2prot(dataname);
    pname = ''; ctr_params = '';
%     stitle(ax(iG), [dataname ' / ' pname ctr_params]);
    stitle(ax(iG), '%s, n=%d', [data_title{iG} ' / ' pname ctr_params], nPSTHs);
    %     keyboard
end

switch(axis_type)
    case 'attach'
        % make axis transparent
        set(ax,'color','none');
        
        axis_loc = unique(get(parent_ax, 'YAxisLocation'));
        if numel(axis_loc) == 1
            switch(axis_loc{1})
                case 'left', set(ax, 'YAxisLocation', 'right');
                case 'right', set(ax, 'YAxisLocation', 'left');
            end
        end        
end

set(ax(2:end-1), 'xtick', []);
if nG > 30
    set_two_ticks(ax);
end
if ~isempty(p), p.xlabel('Time (s)'); end;