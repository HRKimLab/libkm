function [pstrs] = p2s(pvals, delimeter)
% change use case when needed
USE_CASE = 'paper_report';
% USE_CASE = 'abbr_view';

if ~is_arg('delimeter')
    delimeter = ' ';
end

pstrs = [];
for iP = 1:length(pvals)
    pval = pvals(iP);
% print p value smartly
if pval > .1
    pstr = sprintf('%.2f', pval);
% elseif pval > .01
%     pstr = sprintf('%.2f', pval);
elseif pval > .001
    pstr = sprintf('%.3f', pval);
elseif pval > .0001
    switch(USE_CASE)
        case 'abbr_view'
            pstr = sprintf('<1e-3', pval);
        case 'paper_report'
            pstr = sprintf('%.4f', pval);
    end
else
    switch(USE_CASE)
        case 'abbr_view'
            % casual use
            pstr = sprintf('<1e-4', pval);
        case 'paper_report'
            % for reporting in the paper
            pstr = sprintf('%.1e', pval);
    end
end

    pstrs = [pstrs delimeter pstr];
end

% remove the first delimeter
pstrs = pstrs((length(delimeter)+1):end);