function [p, ax, flist] = plot_mpsth_xsubject(varargin)
% For a given protocol, plot multiple PSTHs for each animal
% example: 
% filt_lick = filter_psth(lick_RewOn, dnames, [NaN NaN NaN 0 1]);
% filt_loc = filter_psth(loc_RewOn, dnames, [NaN NaN NaN 0 1]);
% filt_neuron = filter_psth(neuron_RewOn, dnames, [NaN NaN NaN 0 1]);
% [p, ax, flist] = plot_mpsth_xsubject(filt_lick, filt_loc, filt_neuron, 'ylims', [-1 15; -1 30; -1 3.5], ...
%            'x_ref', 0, 'xlim', [-10 3], 'v_pack', [.2 .2 .6]);
% 2018 HRK
global gP

p = []; ax = []; flist = [];
ylims = [];
xlim = [];
x_ref = [];
v_pack = [];
show_event = [];

% get PSTH structures from varargin
bStr = cellfun(@isstruct, varargin);
cPSTHs = varargin(bStr);
varargin = varargin(~bStr);

process_varargin(varargin);

if isempty(cPSTHs), return; end;

nPlots = numel(cPSTHs);
% get datanames from psth structure
[flist] = sort_psth_structs(cPSTHs{1});
nSubject = numel(flist);
assert(isempty(ylims) || size(ylims, 1) == nPlots, sprintf('# of ylims should be same as # of plots (%s)', nPlots))
if isempty(v_pack), v_pack = ones(1, nPlots) / nPlots; end;
    
% iterate subjects
for iS = 1:nSubject
    p1 = gnp;
    p1.pack('v', v_pack);
    p1.margin = 8;
    % iterate plots
    for iP = 1:nPlots
       ax(iP, iS) = p1(iP).select();
       % plot PSTH
       st_psth = filter_psth( cPSTHs{iP}, flist{iS});
       st_fn = fieldnames(st_psth);
       if ~isempty(st_fn) && numel(st_fn) == 1
           psth = st_psth.(st_fn{1});
%             psth = cPSTHs{iP}.(flist{iS});
            plot_psma(psth, [], [], 'ax', ax(iP, iS),'show_event',show_event);
            if ~isempty(x_ref), hR = draw_refs(0, x_ref, []); end
       end
            
       % remove common x tick lables
       if iP == nPlots
           set(ax(iP, iS),'xminorTick','on', 'TickDir', 'out', 'tickLength', [.04 .04]) 
       else
            set(ax(iP, iS),'xticklabel', [], 'xminorTick','on', 'TickDir', 'out', 'tickLength', [.04 .04]) 
       end
       
       % put title in the first row
       if iP == 1
           stitle(flist{iS});
       end
    end
end

% adjust xlim
if ~isempty(xlim)
    set(ax, 'xlim', xlim);
end

% adjust ylims
if ~isempty(ylims)
    for iP = 1:nPlots
        ylimnan(ax(iP,:), ylims(iP, :))
    end
end

p = gP.panelinfo.panel;

return