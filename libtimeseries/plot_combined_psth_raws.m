function plot_combined_psth_raws(st, varargin)
% plot combined rate_rsp from multiple PSTHs
% 2019 HRK

combine_raws = 1;  % 1: merge trials and plot 0: plot trials of sessions 
fig_title = [];

process_varargin(varargin);

st = remove_empty(st);

% combine raw data and then plot as a single 2D array
% use a single color map
if combine_raws
    [x comb_rsp borders] = combine_psth_trials(st);
    imagesc(x, [], comb_rsp);
    draw_refs(0, NaN, borders);
    colorbar
else % plot each rate_rsp array individually. 
    % Useful if want to see relative activity within each session
    cF = fieldnames(st);
    nPSTH = numel(cF);
    p = setpanel(1,1, fig_title);
    p1 = p.gnp;
    p1.pack(nPSTH, 1);
    ax=[]
    for iP = 1:nPSTH
       ax(iP) = p1(iP, 1).select();
       image_continuous_array(st.(cF{iP}).x, st.(cF{iP}).rate_rsp, 'bSkipNaN', 1, 'show_colorbar', 1)       
%        imagesc(st.(cF{iP}).x, [], st.(cF{iP}).rate_rsp);
       set(ax(iP), 'xlim', minmax( st.(cF{iP}).x ), 'ylim', [0 size( st.(cF{iP}).rate_rsp, 1)]);
       axis(ax(iP), 'ij')
       colorbar;
       ylabel(cF{iP});
    end
    linkaxes_ext(ax, 'x');
    p.margin = 20;
    p1.margin = 1;
    
end

return;