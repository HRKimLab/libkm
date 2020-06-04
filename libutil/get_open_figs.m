function fids = get_open_figs()
% return open figure ids
% 2019 HRK
fids = findobj(0,'type','figure');

% in case of callback, guide-generated figure is also captured
fids_no_interest = findobj(0,'type','figure','name', 'popviewer');

% setdiff can do handle-level set difference.
fids = sort(fig2num(setdiff(fids, fids_no_interest) ));
fids = fids(:)';