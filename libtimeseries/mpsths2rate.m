function [rate cF] = mpsths2rate(stPSTH, sTrigger, sWin, func)
% MPSTHS2RATE quantify responses from loaded PSTHs using given time windows.
% [rate cF] = mpsths2rate(stPSTH, sTrigger, sWin, func) returns 2D array of
% rate [# of psths, # of groups]. cF is cell array of psth names.
%
% sTrigger:  either numeric value (seconds from the time 0 of the psths) 
% or event header (e.g., 'RewOn'). You can only use the event header 
% that were saved to the psth file. To save the event information, 
% you use plot_timecourse() with 'event' and 'event_header' options, 
% and save the returned psth using asave(). 
% 
% sWin: [1, 2] array or [# of group, 2] array. For [1, 2] array, it applies
% the same time window for quantification across all conditions. 
% For [# of group, 2] array, it applies different time window for each
% condition. Note that the order should match with ginfo.grp_idx.
%
% Example: 
% mpsths2rate(loaded_psths, 0, [-1 0])
%  - compute average responses, from 0s, use [-1 0] time window for all
%  conditions and all PSTHs.
% 
% mpsths2rate(loaded_psths, 0, [-1 0], @nanmin)
% - compute average responses, from 0s, but compute minimum instead of mean
% (default is @nanmean)
%
% mpsths2rate(loaded_psths, 'RewOn', [1 3])
% - compute average response using time window [1s 3s], aligned by reward
% onset, assuming that RewOn event was saved to the PSTH structure.
% 
% Note that the event header usable in mpsth2rate() is nothing related to 
% the predefined global variables (e.g., what's defined in VirMEn_Def.m). 
%
% see also PSTH2RATE, PSTH2PDCOL, PSTH2PDIDX
%
% 2018 HRK

assert(isstruct(stPSTH), 'stPSTH should be structure with psths');
assert(all(size(sWin) == [1 2]), 'sWin should be 1 X 2 vector');
if ~is_arg('func'), func = @(x) nanmean(x, 2); end;

% iterate fields
cF = fieldnames(stPSTH);
nF = numel(cF);
% use the most frequent group #
for iF = 1:nF
    assert( isfield(stPSTH.(cF{iF}), 'x') );
    n_grps(iF) = size(stPSTH.(cF{iF}).mean, 1);
end
nG = mode(n_grps);
if nG > 1, fprintf(1, 'psthstruct: use most frequent number of groups : %d groups\n', nG); end

rate = NaN(nF, nG);
% iterate psths and compute rate
for iF = 1:nF
    % otherwise I will get infinite resursive loop
    if n_grps(iF) ~= nG, 
        fprintf(1, 'psthstruct2rate: skip %s because # of group (%d) ~= (%d)\n', cF{iF}, n_grps(iF), nG);
        continue; 
    end;
    % iterate group  within a single psth
    rate(iF, :) = psth2rate( stPSTH.(cF{iF}), sTrigger, sWin, func )';
end
return;