function new_pos = move_axes_to(hL, ax, mode)
% move axes relative to ref
% 2019 HRK
orig_pos = get(hL, 'position');
ref_pos = get(ax, 'position');

% keep adding position
switch(mode)
    case 'right'
        new_pos = orig_pos;
        new_pos(1:2) = [ref_pos(1)+ref_pos(3) + orig_pos(3) * 0.15 ref_pos(2)];
end

% move target to the new position
set(hL, 'position', new_pos);