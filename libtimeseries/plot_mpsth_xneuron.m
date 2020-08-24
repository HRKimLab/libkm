function [p, ax, flist, cPSTH] = plot_mpsth_xneuron(cPSTH, varargin)
parent_panel = [];
parent_ax = [];
% new: generate new axis and arrange vertically,
% add: add plots to existing axis. can be used when scaling is similar
% attach: generate new axis and superimpose it to the existing axis
axis_type = 'new';
errbar_type = 'none';
cmap = [];              % color map
xl = [];                % fixed xlim
smooth_win = [];        % re-smooth origianl mean if necessary (too much jiter to show in a small axis)
event_header = {};
x_ref = 0; y_ref = NaN;
fig_title = '';

process_varargin(varargin);

ax = [];
set_lim = 1;
p = [];

% if function arg is file path, load it
if isstr(cPSTH) && exist(cPSTH, 'file')
    d = load(cPSTH, '-mat');
    [p, ax, flist, cPSTH] = plot_mpsth_xsession(d, varargin{:});
    return;
end

if isstruct(cPSTH)
    % sort PSTHs
    [flist cPSTH] = sort_psth_structs(cPSTH);
elseif iscell(cPSTH)
    flist = arrayfun(@(x) x, 1:cPSTH,'un',false);
else
    error('Unknown data type: cPSTH');
end

nF = length(cPSTH);

% load running history from m_all.m
if exist('load_history','file')
    load_history();
end

% create a panel unless specified
if isempty(parent_ax)
    p = setpanel(nF, [], fig_title); % ['m' num2str(mid) ' / ' fn]);
    p.margin = 12;
    for iF = 1:nF
        ax(iF, 1) = p.gna;
    end
else
end

if is_arg('parent_ax')
    nCol = size(parent_ax, 2);
    for iF = 1:nF
        % find axis with the dataname
        dataname = regexprep( flist{iF}, 'e[0-9]*u[0-9]*','');
        hA = findobj(parent_ax,'tag', dataname);
        assert(numel(hA) == 1); % for now, let's think about only 1. but it could be more.
        
        switch(axis_type)
            case 'add' % find the existing axis with the dataname
                set_lim = 0;
                if ~isempty(hA)
                    ax(iF) = hA;
                end
            case 'attach' % superimpose a new axes
                % generate axes for neural data
                pos = get(hA, 'position');
                ax(iF) = axes('position', pos);
                % linke position
                hLP = linkprop([hA, ax(iF)], 'position');
                % assign link position to UserData( necessary to keep linked)
                set(ax(iF), 'UserData', hLP);
                % link axes
                linkaxes([hA, ax(iF)], 'x'); % don't link y axis
        end
    end
end

data_title = set_mpsth_titles(flist);

% plot PSMAs (peri-stimulus moving average)
for iF = 1:nF
    psth = cPSTH{iF};
%     axes(ax(iF));
    % plot peri-stimulus moving average
    [~,~,hL] = plot_psma(psth, errbar_type, cmap, 'smooth_win', smooth_win,'ax', ax(iF), ...
        'event_header', event_header); 
    % delete legend
    if iF ~= 1 && iF ~= nF
        delete(hL);
    end
    draw_refs(0, x_ref, y_ref, ax(iF)); if ~isempty(xl), set(ax(iF), 'xlim', xl); end;
    
    % make title of the plot
    sT = flist{iF};
    dataname = regexprep(flist{iF}, 'e[0-9]*u[0-9]*', '');
    % set tag as dataname. Tag will be used for superimposed plots.
    set(ax(iF), 'Tag', dataname);
    if isfield(psth, 'ginfo') && ~isempty(psth.ginfo) && isfield(psth.ginfo, 'sParams')
        ctr_params = psth.ginfo.sParams;
    elseif isfield(psth, 'ginfo') && ~isempty(psth.ginfo)
        ctr_params = sprintf('%s,', psth.ginfo.grp_label{:});
    else
        ctr_params = '';
    end
    
    % remove virmen_def
    %     [pname] = dataname2prot(dataname);
    pname = '';
%     stitle(ax(iF), [dataname ' / ' pname ctr_params]);
    if length(ctr_params) > 12
        stitle(ax(iF), [data_title{iF} ' / ' char(10) pname ctr_params]);
    else
        stitle(ax(iF), [data_title{iF} ' / ' pname ctr_params]);
    end
    %     keyboard
end

% plot-plot processing
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
set_two_ticks(ax);
if ~isempty(p), p.xlabel('Time (s)'); end;