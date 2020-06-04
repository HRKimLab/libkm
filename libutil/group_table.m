function grp_tbl = group_table(T, group_var, y_var, varargin)
% group table using entities in group_var.
% this can be upgraded to multidimentaionl array
% when there are redundant unitname in a given group, assign the entity
% in the last row (most bottom) in T.
% (group_var, y_var)
% ( G1  , Y; G1 , Y; G2 , Y; G3, Y ) 
% =>
% (G1 , G2  , G3  )
% Y   , Y   , Y
% Y
% to make it easy to do between-group comparisons
% 2020 HRK

debug = 0;

process_varargin(varargin);

%% compile a set of unique unitname
all_unitnames = unique(T(:, {'unitname'}));
nMaxR = numel(all_unitnames);

fprintf(1, 'Found %d basis unitnames: ', numel(all_unitnames));
fprintf(1, '%s ', all_unitnames.unitname{:});
fprintf(1, '\n');
%% get the row # of table
unq_vals = unique(T(:, group_var));
nV = numel(unq_vals);

% find maximum # of rows
nRows = NaN(1, nV);
for iV = 1:nV
    % find rows in a given group 
   bVG = ismember(T(:, group_var), unq_vals(iV,1));
   nVG = nnz(bVG);
   nUnqVG = numel(unique(T(bVG, {'unitname'})));
   nRows(1, iV) = nUnqVG;
   
   % check if this group has redundant unitnames
   if nVG > nUnqVG
       warning('group_var %s has redundant unitnames. # of rows (%d) is greater than unique set(%d)', ...
           unq_vals{iV, 1}{1}, nVG, nUnqVG );
   end
end

fprintf(1, '# of elements for each group: '); fprintf(1, '%d ', nRows); fprintf(1, '\n');

%% generate a target group table
switch(class(T{:, y_var}))
    case 'double'
        grp_tbl = array2table(NaN( nMaxR, nV) );
    case 'cell'
        grp_tbl = table();
        for iR = 1:nMaxR
            for iC = 1:nV
                 tmp = T{1, y_var};
                 assert(numel(tmp) == 1);
                 switch(class(tmp{1}))
                     case 'struct' % GoF
                     case 'double' % optimal fit parameters
                     otherwise
                         error('Unknown cell{1} type: %s', class(tmp{1}));
                 end
%                  && isnumeric( tmp{1} ) );
                tmp_assign{1} = NaN(size(tmp{1}));
                 grp_tbl{iR, iC} = tmp_assign;
                 
            end
        end
    case 'struct'  % add to process shuffled_gof
        grp_tbl = table();
        % for now, take the same approach as cell
        for iR = 1:nMaxR
%             for iC = 1:nV
%                  tmp = T{1, y_var};
%                  % make NaN struct array
%                  nan_struct = arrayfun( @(x) structfun(@(x) NaN, tmp(1), 'un', false), tmp);
%                  aa=cell2table(repmat({nan_struct}, [1 nV]));
%                  grp_tbl{iR, iC} = nan_struct;
%             end
            tmp = T{1, y_var};
            % make NaN struct array
            nan_struct = arrayfun( @(x) structfun(@(x) NaN, tmp(1), 'un', false), tmp);
            aa = cell2table(repmat({nan_struct}, [1 nV]));
            grp_tbl(iR, :) = aa;
        end
end

%% assign unitname as rownames in the group table
grp_tbl.Properties.RowNames = all_unitnames{:,:};
grp_tbl.Properties.VariableNames = unq_vals{:,group_var};

% make debug table that contains # of matches in each eneity
info_tbl = array2table(zeros(size(grp_tbl)), 'VariableNames', grp_tbl.Properties.VariableNames, ...
    'RowNames', grp_tbl.Properties.RowNames);

%% iterate each column and row of the group table and 
% assign each single value individually from T
for iC = 1:nV
    % iterate each row in the group table
    for iR = 1:size(grp_tbl, 1)
        bVG = ismember(T(:, group_var), unq_vals(iC,1));
        bVU  = ismember(T{:, {'unitname'}}, grp_tbl.Properties.RowNames{iR});
        
        % find the eneity in the T with the given group value and unitname
        bV = bVG & bVU;
        
        % assign # of matches it to info table
        info_tbl{iR, unq_vals{iC, 1}} = nnz(bV);
        
        if nnz(bV) == 0
            continue;
        elseif nnz(bV) == 1
             grp_tbl(iR, unq_vals{iC,1}) = T(bV, y_var);
        else
            % print out rows that cause the redundancy problem.
%             T(bV, :)
            iVV = find(bV);
            fprintf(1, 'found %d redundant values in group %s, unitname %s. the last entity will be assigned.\n', ...
                nnz(bV), unq_vals{iC, 1}{1}, grp_tbl.Properties.RowNames{iR} );
            % assign with the last one
             grp_tbl(iR, unq_vals{iC,1}) = T(iVV(end), y_var);
        end
    end
end

if debug
   hT = table2uitable(info_tbl, 'name', sprintf('# of matches for %s. [%d x %d]', y_var, size(info_tbl,1), size(info_tbl,2)), 'mark_zero', 1); 
   % set the window inactive. otherwise results will be plotted here
%    set(hT,'handlevisibility', 'off');
end
return;