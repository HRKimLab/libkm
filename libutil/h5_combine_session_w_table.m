function h5_combine_session_w_table(h5_dest_fpath, data_root, unitnames)
% combine .h5 data files with table information
% - unitname is a cell array containing unitname
% - table row index becomes cell id 
% - some table rows can have empty values. in that case, cell id will keep
%   increasing and there will be missing cell ids.
%
% table version of h5_combine_session_w_table
%
% 2023 HRK

d = [];
nRow = size(unitnames, 1);
nCol = size(unitnames, 2);

% delete destination file if exists
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

n_valid_unit = 0;
for iR = 1:nRow
    % assign cell id
    cell_id = iR;
    
    for iC = 1:nCol
        % skip empty cell
        if isempty( unitnames{iR, iC} )
            continue;
        end
            
        mid = sscanf(unitnames{iR, iC}, 'm%d')
        
        h5_fpath = sprintf('Z:/UchidaLab_repos/HyungGoo2/public/Kim2020Cell_individual_session/%s_public.h5', unitnames{iR, iC} );
        
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
        d.metainfo.unitname = unitnames{iR, iC};
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
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/event', cell_id, iC), d.event);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/grp_idx', cell_id, iC), d.grp_idx);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/lick', cell_id, iC), d.lick);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/loc', cell_id, iC), d.loc);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/pos', cell_id, iC), d.pos);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/fl', cell_id, iC), d.fl);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/spike', cell_id, iC), d.spike);
        
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/metainfo/mid', cell_id, iC), d.metainfo.mid);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/metainfo/unitname', cell_id, iC), int8(d.metainfo.unitname));
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/metainfo/session_date', cell_id, iC), d.metainfo.session_date);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/metainfo/session_time', cell_id, iC), d.metainfo.session_time);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/metainfo/session_datetime', cell_id, iC), d.metainfo.session_datetime);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/metainfo/implant_ML', cell_id, iC), d.metainfo.implant_ML);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/metainfo/grp_label', cell_id, iC), d.metainfo.grp_label);
        save_h5_array(h5_dest_fpath, sprintf('/%d/%d/metainfo/event_label', cell_id, iC), d.metainfo.event_label);
        
        n_valid_unit = n_valid_unit + 1;
    end
end

fprintf(1, 'combined %d rows, %d columns, total valid %d h5 sessions\n', ...
    nRow, nCol, n_valid_unit);
