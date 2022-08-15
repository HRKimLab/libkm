function plot_h5_combined_session(h5_dest_fpath, show_each_plot)
% create plots for h5 data
% plot_h5_combined_session('Z:\UchidaLab_repos\HyungGoo2\public\Kim2020Cell\DA_SU_VR_OL.h5',1)
% 2021 HRK

% h5_dest_fpath = 'Z:\HyungGoo2\public\Kim2020Cell\DA_DAsensor_VS_VR_SPD.h5';
% h5_dest_fpath = 'Z:\HyungGoo2\public\Kim2020Cell\DA_Ca_VS_VR.h5';

if ~is_arg('show_each_plot')
    show_each_plot = 1;
end

%% load and plot data
d = {};
dname = {};
finfo = h5info(h5_dest_fpath);
for iR = 1:numel(finfo.Groups)
    % metadata
    d{iR}.metainfo.mid = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/metainfo/mid']);
    d{iR}.metainfo.session_date = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/metainfo/session_date']);
    d{iR}.metainfo.session_time = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/metainfo/session_time']);
    d{iR}.metainfo.session_datetime = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/metainfo/session_datetime']);
    d{iR}.metainfo.implant_ML = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/metainfo/implant_ML']);
    d{iR}.metainfo.grp_label = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/metainfo/grp_label']);
    d{iR}.metainfo.event_label = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/metainfo/event_label']);
    
    d{iR}.event = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/event']);
    d{iR}.grp_idx = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/grp_idx']);
    d{iR}.lick = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/lick']);
    d{iR}.loc = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/loc']);
    d{iR}.pos = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/pos']);
    % resample
    d{iR}.loc = resample(d{iR}.loc, 10, 1);
    d{iR}.pos = resample(d{iR}.pos, 10, 1);
    try
        d{iR}.fl = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/fl']);
        d{iR}.fl = resample(d{iR}.fl, 10, 1);
    catch, d{iR}.fl = []; end
    try
        d{iR}.spike = h5read(h5_dest_fpath, [finfo.Groups(iR).Name '/spike']);   
    catch, d{iR}.spike = []; end
    if ~isempty(d{iR}.fl)
        d{iR}.neuron = d{iR}.fl;
    else
        d{iR}.neuron = d{iR}.spike;
    end
    
    dname{iR, 1} = sprintf('m%ds1r1',iR);
end

disp('Loading done');

%% plot test
pop_psths = struct();
tot_psth = {};
for iR = 1:numel(d)
    
 [pp, tot_ax, tot_h_psth, tot_psth(iR, :)] = plot_mtimecourses(1:numel(d{iR}.loc), ...
     d{iR}.event(:,3), -8000, 4000, d{iR}.grp_idx, d{iR}.lick, d{iR}.loc, ...
     d{iR}.neuron, ...
     'n_col', 1, 'n_row', 3, 'titles', {'Lick','Speed','DA'} );
%   figure; 
%     [~, pop_psths.(dname{iR}) ] = ...
%         plot_timecourse('timestamp',d{iR}.lick, d{iR}.event(:,3), -5000, 5000, d{iR}.grp_idx)
    
    stitle(tot_ax(1,1), sprintf('m%d, implantML: %.1f datetime: %s, grp: %s', ...
        d{iR}.metainfo.mid, d{iR}.metainfo.implant_ML, char(d{iR}.metainfo.session_datetime), char(d{iR}.metainfo.grp_label) ) );
    
    if ~show_each_plot
        close
    end

end

%%
[~, fname] = fileparts(h5_dest_fpath)
create_figure(fname, 1)
% plot_mpsths(pop_psths);
subplot(3,1,1); plot_mpsths(cell2psths( tot_psth(:,1), dname ) , 'individual_psths', 1 );
subplot(3,1,2); plot_mpsths(cell2psths( tot_psth(:,2), dname ) , 'individual_psths', 1 );
subplot(3,1,3); plot_mpsths(cell2psths( tot_psth(:,3), dname ) , 'individual_psths', 1);