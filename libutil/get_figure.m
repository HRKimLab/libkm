function fid = get_figure(tag, orient_flag)
% get existing figure or create one with a given tag
% 2019 HRK
global gP

if ~isfield(gP, 'remote')
    gP.remote = 0;
end

hF = findobj(0, 'type','figure', 'tag', tag);
if ~isempty(hF)
    fid = hF;
    % focus on this figure
    figure(fid);
    return
end

fid = create_figure([], orient_flag);
set(fid, 'tag', tag);