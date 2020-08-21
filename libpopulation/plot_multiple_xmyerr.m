function plot_multiple_xmyerr(x, data, grp, varargin)
% PLOT_MULTIPLE_XMYERR plot a errorbar line plot for each group
%  For each group, it calls plot_xmyerr to draw line a plot.
%  data can be one of the two forms.
%  1) 2D array of [observation * timepoint] and grp [observation * 1]
%  2) a 3D array of [observation * timepoint * group].
%  For 2), it assumes that data for each observation and timepoint is paired.
%  (e.g., timecourse of responses between randomely interleaved conditions)
%
% 2020 HRK
%
cmap = [];
ebtype = 'bar';
data_pairing = 'paired';

process_varargin(varargin);

% get # of plots
nG = size(data, 3);

if nG > 1
    data_pairing = 'paired';
    if ~is_arg('grp')
        grp = 1:nG;
    end
    % for 3D array, group should be same as the # of groups.
    assert(nG == numel(grp));
    % convert 3D array to 2D array with grp info
    for iG = 1:nG
        
    end
else
    data_pairing = 'unpaired';
end

if isempty(cmap)
    cmap = get_cmap(nG);
end
hold on;
for iP = 1:nG
    plot_xmyerr(x, data(:,:,iP) ,'color', cmap(iP, :), 'ebtype', ebtype);
end
hold off;