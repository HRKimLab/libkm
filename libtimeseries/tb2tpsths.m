function [tpsth tpsth_names cMissing]= tb2tpsths(tb, neuron_LocOnV_fr, varargin)
% load cell arrya of psths based on cell array of unitnames
% first row is header
% 2019 HRK

header = 1;

process_varargin(varargin);

table_type = class(tb);
switch(table_type)
    case 'cell'
        
    case 'table'
        header = 0;
        orig_tb = tb;
        tb = table2cell(tb);
    otherwise
        error('unknown table type: %s', table_type);
end

tpsth = cell(size(tb));
tpsth_names = cell(size(tb));
cMissing = {};
nAssigned = 0;
% iterate rows
if header, start_row  = header + 1;
else, start_row = 1;
end
for iR = start_row:size(tb,1)
    % iterate columns
    for iC = 1:size(tb, 2)
        if isempty(tb{iR, iC}) || ismember(tb{iR, iC}(1), {'%','-'}) , continue; end
        
            if isfield(neuron_LocOnV_fr, tb{iR, iC})
                try
                    tpsth{iR, iC} = neuron_LocOnV_fr.(tb{iR, iC});
                    tpsth_names{iR, iC} = tb{iR, iC};
                    nAssigned = nAssigned + 1;
                catch ME
                    fprintf(1, 'error while assigning psth for tb(%d, %d): %s\n', iR, iC, tb{iR, iC})
                    ME
                end
%                 fprintf(1, 'assigned psth for tb(%d, %d): %s\n', iR, iC, tb{iR, iC})
            else
                fprintf(1, 'cannot find fieldname for tb(%d, %d): %s\n', iR, iC, tb{iR, iC})
                cMissing = {cMissing{:}, tb{iR, iC}};
            end
    end
end

% delete header rows
tpsth(1:header,:) = [];
tpsth_names(1:header,:) = [];

switch(table_type)
    case 'cell'
        % convert it to table
        if header
            tpsth = cell2table(tpsth, 'VariableNames', cellfun(@strtok, tb(1, :),'un',false));
            tpsth_names = cell2table(tpsth_names, 'VariableNames', cellfun(@strtok, tb(1, :),'un',false));
        else
            tpsth = cell2table(tpsth);
            tpsth_names = cell2table(tpsth_names);
        end
    case 'table'
        tpsth = cell2table(tpsth);
        tpsth_names = cell2table(tpsth_names);
        tpsth.Properties.VariableNames = orig_tb.Properties.VariableNames;
        tpsth.Properties.RowNames = orig_tb.Properties.RowNames;
end



% print info
fprintf(1, 'tb2tpsths: [%d * %d] assigned %d entities from %s. %d entities are missing\n', ...
    size(tpsth,1), size(tpsth, 2), nAssigned, inputname(2), numel(cMissing) );