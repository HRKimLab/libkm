function psths = filter_psth_group(psths, filter_grp_func)
% filter specific groups for each psth
% 2019 HRK
psth_type = class(psths);
switch(psth_type)
    case 'struct'
        if ~isfield(psths, 'x')
            fn = fieldnames(psths);
            for iF = 1:numel(fn)
                psths.(fn{iF}) = filter_psth_group(psths.(fn{iF}), filter_grp_func);
            end
            return;
        end
    case 'cell'
            for iR = 1:size(psths,1)
                for iC = 1:size(psths, 2)
                    if isempty(psths{iR, iC})
                        continue;
                    end
                    psths{iR, iC} = filter_psth_group(psths{iR, iC}, filter_grp_func);
                end
            end        
            return
    case 'table' %tpsth
            for iR = 1:size(psths,1)
                for iC = 1:size(psths, 2)
                    if isempty(psths{iR, iC}{1})
                        continue;
                    end
                    psths{iR, iC}{1} = filter_psth_group(psths{iR, iC}{1}, filter_grp_func);
                end
            end
            return;
end

assert(isstruct(psths) && isfield(psths, 'x'), 'psths is not psth struct')

% use psth 
psth = psths;
nG = size(psth.mean, 1);
nT = size(psth.grp, 1);

switch class(filter_grp_func)
    case 'function_handle'
    case 'char'
        switch(filter_grp_func)
            case 'argmax_gnumel'
                filter_grp_func = @argmax_gnumel;
            case 'argmin_gnumel'
                filter_grp_func = @argmin_gnumel;
            otherwise
                error('Unknown filter_grp_func: %s', filter_grp_func);
        end
    case {'double','logical'} % it should be 0 / 1 bitwise vector
        assert(size(filter_grp_func, 1) == nG, 'size of group in psth (%d) should be same as # of rows in argument (%d)', ...
            nG, size(filter_grp_func, 1));
    otherwise
        error('Unknown filter_grp_func type : %s', class(filter_grp_func));
end


% no need to filter groups if group # is one.
if nG == 1
    return;
end

switch class(filter_grp_func)
    case {'double','logical'} % it should be 0 / 1 bitwise vector
        bVG = logical(filter_grp_func);
        bVT = [];
    otherwise
        % decide whether include it or not, baesd on filter function results
        [bVG bVT] = filter_grp_func(psths);
end

assert(size(bVG, 1) == nG, 'filter_grp_func output is not the same as group #');
if nG == 1
    return;
end

cFN = fieldnames(psth);
nF = numel(cFN);
for iF = 1:nF
   nG_F = size(psth.(cFN{iF}) , 1);
   if nG_F == 1
       continue;
   end
   
   if nG_F == nG
        % filter group
        psth.(cFN{iF}) = psth.(cFN{iF})(bVG,:);
   elseif nG_F == nT
       if isempty(bVT)
           psth.(cFN{iF}) = [];
       else
           % filter trials
            psth.(cFN{iF}) = psth.(cFN{iF})(bVT,:);
       end
       
   end
end

% re-process fields it if necessary
for iF = 1:nF
   switch(cFN{iF})
       case 'idx_sorted_by_num'
           [~, psth.(cFN{iF})] = sort(psth.gnumel);
   end
end

switch class(filter_grp_func)
    case {'double','logical'}
        
    otherwise
        % routine-specific part
        switch(func2str(filter_grp_func))
            case {'argmax_gnumel', 'argmin_gnumel'}
                % just make group # to be 1
                psth.gname = 1;
                psth.grp = ones(size(psth.grp));
        end
end




psths = psth;

return;

end

% find group with maximum group #
% I did not modify grp, ginfo accordingly.
function [bVG bVT] = argmax_gnumel(psth)
    nG = size(psth.mean, 1);
    if nG == 1
        bVG = true(1, 1);
        return;
    end
    [~, iM] = max(psth.gnumel);
    bVG = false(size(psth.gnumel));
    bVG(iM) = true;
    
    bVT = false(size(psth.grp));
    bVT( psth.grp == psth.gname(bVG) ) = true;
    
    assert(nnz(bVT) == psth.gnumel(bVG), '# of group (%d) does not match', psth.gname(bVG))
    fprintf(1, '[%s] filter group %s (n=%d) out of %s\n', psth.name, ...
        sprintf('%d', psth.gname(bVG)), psth.gnumel(bVG), sprintf('%d ', psth.gname));
end

% find group with minimum group #
% I did not modify grp, ginfo accordingly.
function [bVG bVT] = argmin_gnumel(psth)
    nG = size(psth.mean, 1);
    if nG == 1
        bVG = true(1, 1);
        return;
    end
    [~, iM] = min(psth.gnumel);
    bVG = false(size(psth.gnumel));
    bVG(iM) = true;
    
    bVT = false(size(psth.grp));
    bVT( psth.grp == psth.gname(bVG) ) = true;
    
    assert(isempty(bVT) || nnz(bVT) == psth.gnumel(bVG), '# of group (%d) does not match', psth.gname(bVG))
    fprintf(1, '[%s] filter group %s (n_trial=%d) out of %s\n', psth.name, ...
        sprintf('%d', psth.gname(bVG)), psth.gnumel(bVG), sprintf('%d ', psth.gname));
end