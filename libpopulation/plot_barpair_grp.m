function [grp_means grp_sem bar_res] = plot_barpair_grp(x, grp, varargin)
% PLOT_BARPAIR_GRP create a bar plot for each group.
%   plot_barpair_grp(x, grp) 
%    x:     measurement [n_obs * n_features]
%    grp:   [n_obs * 1] indiciating groups.
%    Derived from plot_barpair, this creates n_features bars for each group. 
%    Paired elements are connected with lines.
%
% See also PLOT_TRIAL_DATA
% 
% 10/6/2022 HRK

% from PMC153434: As a rule, nonparametric methods, particularly when used in small samples,
% have rather less power (i.e. less chance of detecting a true effect where one exists) than
% their parametric equivalents, and this is particularly true of the sign test (see Siegel and Castellan [3]
% for further details).

yl = [];
show_individual = 1;
use_star = 0;
show_mc = 3; % 1: horiznotal bar 2: stars, 3: start, only sig.
bar_x = 1;      % bar start position. can be a vector (same size as size(x,2))
test_type = 'nonpar';  % 'nonpar', 'par', 'par_cond'
test_mode = 'allpairs'; % 'allpairs', 'withingrp'
color_bars = 0;			% color bars

process_varargin(varargin);

if ~is_arg('c'), c = [.5 .5 .5];    end;
if ~is_arg('y_ref'), y_ref = []; end;
if ~is_arg('is_sig'), is_sig = true(size(x)); end;
if numel(bar_x) == 0
    bar_x = 1:size(x, 2);
elseif (numel(bar_x) == 1 && size(x, 2) > 1)
    bar_x = bar_x:(bar_x+size(x, 2)-1);
end

assert(size(x, 1) == size(grp, 1), 'size(x, 1) should match with size(grp, 1)');
grp_idx = grp2idx(grp);

switch(test_mode)
    case 'withingrp'
        nG = max(grp_idx);
        cmap = get_cmap(nG);
        
        if nG  == 1
            bar_xs = 0;
            bar_width = 0.5;
        else
            bar_xs = linspace(-0.3, 0.3, nG);
            bar_width = diff(bar_xs(1:2)) * 0.8;
        end
        
        for iG = 1:nG
            bV = grp_idx == iG;
            x_subgrp = x(bV, :);
            
            % bar plot seems to reset the axis to be replaced. hold on every time
            hold on;
            
            % show_mc should be 0. multiple comparison only support
            % standard bar x positions for now (see plot_barpair)
            [grp_means grp_sem pRef pDiff pPair bar_res(iG)]  = plot_barpair(x_subgrp, [], [], ...
                'bar_x', 1 + bar_xs(iG), 'bar_color', cmap(iG, :), ...
                'show_mc', 0, 'show_individual', show_individual);
     
			if color_bars 
				set(bar_res(iG).hB,'barwidth', 0.1,'facecolor', cmap(iG, :) );
				if isfield(bar_res(iG), 'hScatter1')
					set(bar_res(iG).hScatter1,'markerfacecolor', cmap(iG, :) );
				end
				if isfield(bar_res(iG), 'hScatter2')
					set(bar_res(iG).hScatter2,'markerfacecolor', cmap(iG, :) );
				end
			end
        end
        
        % % color bars
        hB = findobj(gca,'type','bar');
        for iG = 1:nG
            set(hB(iG),'barwidth', bar_width);
        end
        
        % clear title
        stitle('nWin = %d, nG = %d', size(x, 2), nG );
        draw_refs(0, 1.5:1:size(x, 2));
        set(gca,'xtick', 1:size(x,2) );
        
        xlim([0.3 size(x, 2)+0.6]);
    case 'allpairs'
        % create window indice and grp indice
        [mesh_time mesh_grp] = meshgrid(1:size(x, 2), grp_idx);
        
        % give high priority to time (time first, group follows)
        g = mesh_time * 100 + mesh_grp;
        [grp_means grp_sem pRef pDiff mc_sig gR gP bar_res] = plot_bargrp(x(:), g(:), 'show_mc', 3);
        nG = max(grp_idx);
        
        % I tried to filter-out comparisons that are not meaningful and
        % only left between same group / within same time window.
        % complicated.. let's do it later... 
%         pPair = bar_res.pPair;
%         
%         nCond = size(pPair, 1);
%         ss_grps = {}; iSSG = 0;
%         ss_stats = [];
%         for iR = 1:nCond
%             for iC = iR+1:nCond
%                 if show_mc == 2 || (show_mc == 3 && pPair(iR, iC) < 0.05)
%                     ss_grps = { ss_grps{:}, [iR iC]};
%                     ss_stats = [ss_stats pPair(iR, iC)];
%                 end
%             end
%         end
%         % draw significant star
%         sigstar(ss_grps, ss_stats);

        draw_refs(0, max(grp_idx)+0.5:max(grp_idx):nunique(g(:)));
        stitle('nWin = %d, nG = %d', size(x, 2), nG );
        iL = 1;
        for iW = 1:size(x, 2)
            for iG = 1:nG
                cL{iL} = sprintf('W%dG%d', iW, iG);
                iL = iL + 1;
            end
        end
        set(gca, 'xtick', 1:size(grp_means,1), 'xticklabel', cL,'fontsize', 9);
%         xticklabel_rotate(1:size(grp_means,1), 90, cL) % ,'Fontsize',11
        xlim([0.3 size(grp_means,1)+0.6]);
    otherwise
        error('Unknown test mode: %s', test_mode);
end


return;
