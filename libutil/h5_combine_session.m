function h5_combine_session(h5_dest_fpath, data_root, unitnames)

d = [];
nUnitname = numel(unitnames);

if exist(h5_dest_fpath, 'file')
    sA = input([h5_dest_fpath ' exists. delete?[y/n]'],'s');
    switch(sA)
        case 'y'
            delete(h5_dest_fpath)
        case 'n'
            return;
        otherwise
            error('Unknown option: %s', sA);
    end
end

for iR = 1:nUnitname
% for iR = 1:10
    mid = sscanf(unitnames{iR}, 'm%d')
%     h5_fpath = sprintf('%s%d/save_data/%s_public.h5', data_root, mid, unitnames{iR} )
    h5_fpath = sprintf('Z:/UchidaLab_repos/HyungGoo2/public/Kim2020Cell_individual_session/%s_public.h5', unitnames{iR} )
    
    if exist(h5_fpath, 'file')
        disp(['found file ' h5_fpath]);
    else
        error('cannot find file %s', h5_fpath);
    end
    
    % load data and test
    d.event = h5read(h5_fpath, '/event');
    % load group index
    d.grp_idx = h5read(h5_fpath, '/grp_idx');
    % load behaviors
    d.lick  = h5read(h5_fpath, '/lick');
    d.loc   = h5read(h5_fpath, '/loc');
    d.pos = h5read(h5_fpath, '/pos');
    
    d.metainfo.mid = h5read(h5_fpath, '/metainfo/mid');
    d.metainfo.session_date = h5read(h5_fpath, '/metainfo/session_date');
    d.metainfo.session_time = h5read(h5_fpath, '/metainfo/session_time');
    d.metainfo.session_datetime = h5read(h5_fpath, '/metainfo/session_datetime');
    d.metainfo.implant_ML = h5read(h5_fpath, '/metainfo/implant_ML');
    d.metainfo.grp_label = h5read(h5_fpath, '/metainfo/grp_label');
    d.metainfo.event_label = h5read(h5_fpath, '/metainfo/event_label');

    % load neural activities
    try
        d.fl    = h5read(h5_fpath, '/fl');
    catch
        d.fl = [];
    end
    try
        d.spike = h5read(h5_fpath, '/spike');
    catch
        d.spike = [];
    end

    % Now, write to the destination hd5 file
    save_h5_array(h5_dest_fpath, sprintf('/%d/event', iR), d.event);
    save_h5_array(h5_dest_fpath, sprintf('/%d/grp_idx', iR), d.grp_idx);
    save_h5_array(h5_dest_fpath, sprintf('/%d/lick', iR), d.lick);
    save_h5_array(h5_dest_fpath, sprintf('/%d/loc', iR), d.loc);
    save_h5_array(h5_dest_fpath, sprintf('/%d/pos', iR), d.pos);
    save_h5_array(h5_dest_fpath, sprintf('/%d/fl', iR), d.fl);
    save_h5_array(h5_dest_fpath, sprintf('/%d/spike', iR), d.spike);

    save_h5_array(h5_dest_fpath, sprintf('/%d/metainfo/mid', iR), d.metainfo.mid);
    save_h5_array(h5_dest_fpath, sprintf('/%d/metainfo/session_date', iR), d.metainfo.session_date);
    save_h5_array(h5_dest_fpath, sprintf('/%d/metainfo/session_time', iR), d.metainfo.session_time);
    save_h5_array(h5_dest_fpath, sprintf('/%d/metainfo/session_datetime', iR), d.metainfo.session_datetime);
    save_h5_array(h5_dest_fpath, sprintf('/%d/metainfo/implant_ML', iR), d.metainfo.implant_ML);
    save_h5_array(h5_dest_fpath, sprintf('/%d/metainfo/grp_label', iR), d.metainfo.grp_label);
    save_h5_array(h5_dest_fpath, sprintf('/%d/metainfo/event_label', iR), d.metainfo.event_label);
end

fprintf(1, 'combined %d h5 sessions\n', nUnitname);
