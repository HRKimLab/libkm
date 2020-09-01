function ret_psth = modify_psth(psth, op, sTrigger, sWin, p1)
% modify psth structure based on operation
% start_time, end_time is single variable, vector of time (s), or column
% name in event table
% new_psth = modify_psth(psth, sMax);
% 2018 HRK

if ~is_arg('p1'), p1 = []; end;

psth_type = class(psth)
switch(psth_type)
    case 'struct'
        if ~isfield(psth, 'x')
            fn = fieldnames(psth);
            for iF = 1:numel(fn)
                ret_psth.(fn{iF}) = modify_psth(psth.(fn{iF}), op, sTrigger, sWin, p1);
            end
            return;
        end
    case 'cell'
        ret_psth = cellfun(@(x) modify_psth(x, op, sTrigger, sWin, p1), psth, 'un', false)
        return;
    case 'double'
        if isempty(psth)
            ret_psth = [];
            return;
        end
    otherwise
        error('Unknown psth type: %s', psth_type)
end

% check # of groups in psth
nG = size(psth.mean, 1);

% notiong to realign for an empty psth
if isempty(psth.mean), 
    ret_psth = psth;
    return;
end

% check array size and time bin
nLen = size(psth.mean, 2);
sTimeBin = psth.x(2)-psth.x(1);

% convert sTrigger and sWin
[sTrigger sWin] = psth2time(psth, sTrigger, sWin);
% 
% % find array indice that corredpond to elements of sTrigger
% if isstr(sTrigger)                              % per-group time window
%     sTrigger = psth.event{:, sTrigger};
%     sWin = bsxfun(@plus,sTrigger, sWin);
% elseif isnumeric(sTrigger) && numel(sTrigger) == 1 % single time window
%     sWin = bsxfun(@plus, ones(nG,1) * sTrigger, sWin);
% else                                            % per-group time window
%    assert(isnumeric(sTrigger));
%    sWin = bsxfun(@plus,sTrigger, sWin);
% end

ret_psth = struct();
fns = fieldnames(psth); nF = numel(fns);
% modify row vector and return 
for iF = 1:nF
    fn = fns{iF};
   
    switch(op)
        % methods that does or should go through 'otherwise' 
        case {'adjust_x','trimright'} 
        otherwise
            % field that needs special processing
            switch (fn)
                case 'x' % no need to change
                    ret_psth.x = psth.x;
                case 'pDiff'  % variables that becomes invalid. just fill NaN.
                    ret_psth.(fn) = NaN(size(psth.(fn)));
                otherwise     
            end
    end
    
   % skip if the variable is already copied above
   if isfield(ret_psth, fn), continue; end;
   
    % if field is not a time-series variable, just copy
   if size(psth.(fn), 2) ~= nLen 
       ret_psth.(fn) = psth.(fn);
       continue;
   end
   
   % operation-specific modification
   switch(op)
       case 'nullify'
           ret_psth.(fn) = psth.(fn);
           if size(ret_psth.(fn), 1) == nG
               for iG = 1:nG
                   bVT = sWin(iG,1) <= ret_psth.x & ret_psth.x < sWin(iG, 2);
                   ret_psth.(fn)(iG, bVT) = NaN;
               end
           end
       case 'trimright' % trim right part, including x
           bVX = psth.x < max(psth.x) - p1;
           
           if size(psth.(fn), 2) == numel(bVX) % time course variable
               ret_psth.(fn) = psth.(fn)(:, bVX);
           else % non-time course variable
               ret_psth.(fn) = psth.(fn);
           end
           
       case 'cropleft'
            ret_psth.(fn) = psth.(fn);
            % only apply to the grouped variable (not x for now)
            if size(ret_psth.(fn), 1) == nG
               for iG = 1:nG
                   bVT = sWin(iG,1) <= ret_psth.x & ret_psth.x < sWin(iG, 2);
                   % skip if there is no valid x
                   if all(~bVT), continue; end
                   iVT = find(bVT, 1, 'first'); 
                   nVT = nnz(bVT); nRest = nLen - iVT - nVT;
                   % shift to the right
                   ret_psth.(fn)(iG, iVT:(iVT+nRest)) = ret_psth.(fn)(iG, (iVT+nVT):(iVT+nVT+nRest));
                   % fill NaNs in the shifted time points
                   ret_psth.(fn)(iG, (iVT+nRest):end) = NaN;
               end
            end
            
       case 'cropright'
            ret_psth.(fn) = psth.(fn);
            % only apply to the grouped variable (not x for now)
            if size(ret_psth.(fn), 1) == nG
               for iG = 1:nG
                   bVT = sWin(iG,1) <= ret_psth.x & ret_psth.x < sWin(iG, 2);
                   % skip if there is no valid x
                   if all(~bVT), continue; end
                   iVT = find(bVT, 1, 'first'); 
                   nVT = nnz(bVT); nRest = nLen - iVT - nVT;
                   % shift to the left
%                    ret_psth.(fn)(iG, iVT:(iVT+nRest)) = ret_psth.(fn)(iG, (iVT+nVT):(iVT+nVT+nRest));
                    ret_psth.(fn)(iG, (nVT+1):(iVT+nVT)) = ret_psth.(fn)(iG, 1:(iVT-1));
                    % (11)   4 (11-14) (100)
                    % 5:100
                   ret_psth.(fn)(iG, (iVT+nRest):end) = NaN;
               end
            end
           
       case 'homogenize'  % make time-series array same as grpidx p1.
            ret_psth.(fn) = psth.(fn);
            assert(p1 >= 1 && p1 <= nG, ['p1 should be between 1 - ' num2str(nG)] );
           if size(ret_psth.(fn), 1) == nG
               for iG = 1:nG
                   bVT = sWin(iG,1) <= ret_psth.x & ret_psth.x < sWin(iG, 2);
                   iVT = find(bVT, 1, 'first'); 
                   nVT = nnz(bVT); nRest = nLen - iVT - nVT;
                   % make it the same as p1
                   ret_psth.(fn)(iG, bVT) = ret_psth.(fn)(p1, bVT);
               end
           end
       case 'subtract_mean'   % subtract mean from rate_rsp 
            ret_psth.(fn) = psth.(fn);
            if strcmp(fn, 'rate_rsp')
                rate_rsp = psth.(fn);
                for iG = 1:nG
                    bVG = psth.grp == iG;
                    rate_rsp(bVG,:) = bsxfun(@minus, rate_rsp(bVG,:), psth.mean(iG,:) );
                end
                % re-compute psth based on the mean-subtracted rate_rsp
                ret_psth = compute_avggrp(psth.x, rate_rsp, psth.grp);
                % return to avoid values being overwritten.
                return;
            end
            
       case 'subtract_argmax_gnumel'   % subtract mean from rate_rsp 
            ret_psth.(fn) = psth.(fn);
            [~, iMaxGrp] = max(psth.gnumel);
            if size(ret_psth.(fn), 1) == nG
                switch(fn)
                    case 'mean'
                        ret_psth.(fn) = ret_psth.(fn);
                        ret_psth.(fn) = bsxfun(@minus, ret_psth.(fn), ret_psth.(fn)(iMaxGrp,:) );
                    otherwise
                end
            end
       case 'subtract_baseline'   % subtract mean from rate_rsp 
            ret_psth.(fn) = psth.(fn);
            [~, iMaxGrp] = max(psth.gnumel);
            if size(ret_psth.(fn), 1) == nG
                switch(fn)
                    case 'mean'
                        ret_psth.(fn) = ret_psth.(fn);
                        for iG = 1:nG
                            bVT = psth.x >= sWin(iG, 1) & psth.x < sWin(iG, 2);
                            % baseline subtraction
                            ret_psth.(fn)(iG, :) = ret_psth.(fn)(iG, :) - nanmean( ret_psth.(fn)(iG, bVT) );
                        end
                    otherwise
                end
           end
       case 'assignleft'
           ret_psth.(fn) = psth.(fn);
           if size(ret_psth.(fn), 1) == nG
               for iG = 1:nG
                   bVT = sWin(iG,1) <= ret_psth.x & ret_psth.x < sWin(iG, 2);
                   if all(~bVT), continue; end
                   ret_psth.(fn)(iG, bVT) = ret_psth.(fn)(iG, find(bVT,1,'first'));
               end
           end
       case 'shift2right' % shift to the right and fill the blank with leftmost value
           ret_psth.(fn) = psth.(fn);
           if size(ret_psth.(fn), 1) == nG
               for iG = 1:nG
                   bVT = sWin(iG,1) <= ret_psth.x & ret_psth.x < sWin(iG, 2);
                   sDur = sWin(iG,2) - sWin(iG,1);
                   bTarg = sWin(iG,1)+sDur <= ret_psth.x & ret_psth.x < sWin(iG, 2)+sDur;
                   if all(~bVT) , continue; end
                    nVT = nnz(bVT); nTarg = nnz(bTarg);
                    iLeft = find(bVT,1,'first');
                    iTLeft = find(bTarg,1,'first');
                    %assert(iTLeft + nVT <= length(bVT) );
                    if iTLeft + nVT <= length(bVT) 
                        nCopy = nVT;
                    else
                        nCopy = length(bVT) - iTLeft;
                        warning('shift2right: trim the shifted points, %d -> %d', nVT, nCopy);
                    end
                   const_val = ret_psth.(fn)(iG, iLeft);
                   % shift
                   ret_psth.(fn)(iG, iTLeft:iTLeft+nCopy-1) = ret_psth.(fn)(iG, iLeft:(iLeft+nCopy-1));
                   % assign left
                   ret_psth.(fn)(iG, bVT) = const_val;
               end
           end
       case 'cumsum'
           ret_psth.(fn) = psth.(fn);
           switch(fn)
               case 'mean'
                   ret_psth.(fn) = cumsum( psth.(fn), 2 );
%                otherwise
%                    ret_psth.(fn) = NaN( size( ret_psth.(fn) ) );
           end
       case 'adjust_x'
            [b_new_psth, i_psth] = ismember(p1, psth.x);
            nNewLen = numel( b_new_psth );
            ret_psth.(fn) = psth.(fn);
            if size(ret_psth.(fn), 2) == nLen
                nG = size(psth.(fn), 1);
                ret_psth.(fn) = NaN( nG, nNewLen);
                ret_psth.(fn)(:, b_new_psth) = psth.(fn)(:, i_psth (i_psth > 0) );
            end
            if strcmp(fn, 'x')
                ret_psth.(fn) = p1;
            end
       otherwise
           error('Unknown operation: %s', op);
   end
   
end