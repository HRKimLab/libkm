function [tb] = quantify_psth_trials(psth, start_wins, end_wins, varargin)
% quantify trials based on psth and make table data structure
% call stream2rate or ts2rate and make table structure
% start_wins, end_wins : # of trials X # of quantities
%
% Not like quantify_trials, start_wins and end_wins are relative to psth.x = 0
% 
% It shows up time window. So good for cross-checking. However, 
% For timestamp, this is less accurate than quantify_trials. also for stream data, 
% psth is subsampled. It's not as flexible as quantify_trials. 
% Use it for prelimnary purpose.
%
% 2019 HRK

func = @nanmean
header = {};
ax = [];

process_varargin(varargin)

if isstr(header), header = {header}; end;

assert(size(start_wins, 2) == size(end_wins, 2), '# of quntities should be same');
% # of quantities
nQ = size(start_wins, 2);
nT = size(psth.rate_rsp, 1);
% output array
dt = NaN(nT, nQ);

for iQ = 1:nQ
    bV = psth.x >= start_wins(1, iQ) & psth.x < end_wins(1, iQ);
    dt(:, iQ) = func( psth.rate_rsp(:, bV), 2);
    
    % shade the time window
    if ~isempty(ax) && ishandle(ax)
        shade_plot(ax, [start_wins(1, iQ) end_wins(1, iQ)] );
    end
end

tb = array2table(dt);
if ~isempty(header)
   tb.Properties.VariableNames = header;
end