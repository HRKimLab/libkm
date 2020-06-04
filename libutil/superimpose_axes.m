function ax = superimpose_axes(ax)
% superimpose axes 
% 2018 HRK
if ~is_arg('ax'), ax = gca; end;
xl = get(ax,'xlim');
pos = get(ax, 'position');
set(ax, 'YAxisLocation','left');
box(ax, 'off');

ax(2) = axes('Position', pos);
% 
set(ax(2), 'YAxisLocation','right', 'color','none', 'xticklabel', []);
box(ax(2), 'off');
% don't change axes property set above
set(ax(2), 'nextplot', 'replacechildren'); 
linkaxes_ext(ax, 'x'); set(ax, 'xlim', xl);
linkprop(ax, 'position');
