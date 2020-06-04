function [ax avg_psths pop_psths] = plot_neuron_psths(motor_time, cNeurons, ab, st, ed, grp, varargin)
% plot psths and perform population analysis using a single session dataset
% for example, Neuropixels or 2-photon miciroscopy
% 2020 HRK

unit_name = {};
event = [];
event_header = {};
n_row = 3;
n_col = 4;
save_fpath = '';

process_varargin(varargin);

% assert(~isempty(unit_name), 'unit_name should be given');
% assert( numel(unit_name) == numel(cNeurons), '# of unit_name should match # of neurons');

% make unit name if not given
if isempty(unit_name)
    neuron_ids = 1:numel(cNeurons);
    unit_name = arrayfun(@(x) ['N' num2str(x)], neuron_ids, 'un', false)
end

[pp, ax, tot_h_psth, tot_psth] = plot_mtimecourses(motor_time, ab, st, ed, grp, ...
    cNeurons{:}, 'event', event, 'event_header', event_header, ...
    'n_row', n_row, 'n_col', n_col, 'titles', unit_name, 'large_scale', 1);

pop_psths = struct();
for iN = 1:numel(tot_psth)
    pop_psths.(unit_name{iN}) = tot_psth{iN};
end

avg_psths = plot_mpsths(pop_psths, 'homogenize', 0);

% perform clustering analysis
cluster_psths(avg_psths, 't_sne', 0);

% save psths
if ~isempty(save_fpath)
    [fdir fname] = fileparts( save_fpath );
   for iP = 1:size(ax, 2)
       F_raster = getframe(ax(1, iP));
       F_psth =   getframe(ax(2, iP));
       im_raster = frame2im(F_raster);
       im_psth = frame2im(F_psth);
       im_comb = [im_raster; im_psth];
       imwrite(im_comb, fullfile(fdir, [fname unit_name{iP} '.png']) );
   end
   fprintf(1, 'unlabled psths graphics were saved to %s\n', save_fpath);
end