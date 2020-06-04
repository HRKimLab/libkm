function h_psth = draw_errorbar(x, mean_rsp, sem_rsp, cmap, errbar_type, ax)

if isempty(mean_rsp)
    h_psth = []; 
    return; 
end;

if ~is_arg('ax'); ax = gca; end
assert(all(size(x) == size(mean_rsp)));
assert(~is_arg('sem_rsp') || all(max(size(x)) == max(size(sem_rsp)) ) );
cmap = color2num(cmap);

if ~is_arg('errbar_type'), errbar_type = 'line'; end;

switch(errbar_type)
    case 'bar'
        h_psth = errorbar(ax, x, mean_rsp, sem_rsp);
        set(h_psth, 'color', cmap);
      case 'none'  % draw just line for mean, no sem
        h_psth = plot(ax, x, mean_rsp, 'color', cmap);
      case 'patch'
        % draw patch for sem. 
        h_psth = errorbar_patch_opaque(x, mean_rsp, sem_rsp, cmap, ax);
        set(h_psth(1), 'tag','eb'); set(h_psth(2), 'tag','m');
      case 'patch_tp' % transparent
        % draw patch for sem. 
        h_psth = errorbar_patch_transparent(x, mean_rsp, sem_rsp, cmap, ax);
        set(h_psth(1), 'tag','eb'); set(h_psth(2), 'tag','m');
      case 'line'
            % draw lines for sem. zbuffer for pdf saving doesn't suppor transparent patch. use dotted
            if size(mean_rsp,1) <= 3 % plot errorbar only if # of groups are small
                h_psth = errorbar_line(x, mean_rsp, sem_rsp, 'color', cmap);
            else
                h_psth = errorbar_line(x, mean_rsp, NaN(size(sem_rsp)), 'color', cmap);
            end
      otherwise
          error('Unknown errorbar type : %s', errbar_type);
  end