function psth = refine_psth(psth, varargin)
% refine psth to reduce errors and save memory
% this does not gurantee integrity of psth stucture. use it for last-minute
% error avoidance purpose only.
% 2018 HRK

refine_group = 0;
refine_time = 0;

process_varargin(varargin);

% get number of groups, and length of array in time
nG = size(psth.mean, 1);
nLen = size(psth.mean, 2);
% flag for time and group
bVG = true(nG, 1);
bVT = true(1, nLen);

% refine time
if refine_time
    % TODO; need to correct event table too...
end
% refine group
if refine_group 
    bVG = ~all(isnan(psth.mean), 2);
end

fns = fieldnames(psth); nF = numel(fns);
for iF=1:nF
   fn = fns{iF};
   % variable for time
   if size(psth.(fn), 2) == nLen
       psth.(fn) = psth.(fn)(:, bVT);
   end
   % variable for group
   if size(psth.(fn), 1) == nG 
       psth.(fn) = psth.(fn)(bVG, :);
   end
end