function [r,p,N,sl,itc,fitdata,hS] = plot_scatter(x,y,grp, varargin)
% regdata: [x y basic_#(N;r;p) fit_params(sl;itc)
% substitute x if given as column idx

xl = []; yl = [];
show_individual = 1;
show_grpmean = 0;
grp_zscore = 0;         % 1: zscore   2: subtract mean, 'ymean': y mean
grp_lim = 25;
show_ci = 0;            % confidence interval for R
show_regress_ci = 0;    % confidence interval for type 2 regression
marker_size = [];
regress_type = 'type2';       % 'none', 'type1' or 'type2' regression

process_varargin(varargin);

r = NaN; p= NaN; N= NaN; sl= NaN; itc= NaN; fitdata= NaN; hS = [];
r_lb = NaN; r_ub = NaN; g_r_lb = NaN; g_r_ub = NaN;
if ~is_arg('grp')
    grp = zeros(size(x)); 
end

if show_ci == 1 % use 0.95 as default
    show_ci = 0.95;
end
% check if actually x,y,grp is one element instead of column index
if (length(x) == 1 || length(y) == 1 || length(grp) == 1) && ...
        ~evalin('base', 'exist(''pcd_colname'',''var'')')
    r = NaN; p = NaN; N = 1; sl = NaN; itc = NaN; fitdata = NaN;
    plot(x,y,'ko');
    return;
end

if length(x) == 1
    x_label = evalin('base', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('base', ['aPD(:,' num2str(x) ');']);
elseif ~isempty(inputname(1))
    x_label = inputname(1);
end
% substitute y if given as column idx
if length(y) == 1
    y_label = evalin('base', ['pcd_colname{' num2str(y) '}']); 
    y = evalin('base', ['aPD(:,' num2str(y) ');']);
elseif ~isempty(inputname(2))
    y_label = inputname(2);
end

% substitute grp if given as column idx
if length(grp) == 1
    grp = evalin('base', ['aPD(:,' num2str(grp) ');']);
end

% why not just filter out all ~bV rows???
bV = all(~isnan([x y grp]),2);
if nnz(bV) == 0
    title('N=0'); return;
end


if grp_zscore ~= 0
    [cmap nColor grp_idx] = grp2coloridx(grp, grp_lim);
    for iG = 1:max(grp_idx)
       bVG = grp_idx == iG;
       switch(grp_zscore)
           case 1  % zscore for each group
            x(bVG) = nanzscore(x(bVG));
            y(bVG) = nanzscore(y(bVG));
           case 2 % subtract mean
            x(bVG) = x(bVG) - nanmean(x(bVG));
            y(bVG) = y(bVG) - nanmean(y(bVG));
           case 'ymean' % y mean only
            y(bVG) = y(bVG) - nanmean(y(bVG));   
       end
    end
end

% set x limits
if ~is_arg('xl'), xl = setlim(x(:)); end
if ~is_arg('yl'), yl = setlim(y(:)); end

if isnumeric(grp_zscore) &&  grp_zscore == 1
   xl = [-3 3]; yl = [-3 3];
end
% compute correlation
[r p N] = corrN(x(bV),y(bV),'type','Spearman','rows','pairwise');
if show_ci > 0
%     RHO = corr(x(bV),y(bV),'Type','Spearman','rows','pairwise');
%     n = numel(a);
    STE = 1/sqrt(N-3);
    % here the input is 95% confidence interval, for 99% use 0.99:
    CI = norminv(show_ci);
    r_ub = tanh(atanh(r)+CI*STE);
    r_lb = tanh(atanh(r)-CI*STE);
end
% see if group variable have two columns (usually, subject x conditions)
grp_names = grpstats(ones([size(grp,1) 1]), grp, 'gname');
grp_numel = grpstats(x + y, grp, 'numel'); % x+y : NaN if either x or y is NaN
nGrpDiv = size(grp_names, 2);
nGrp = numel(grp_names);
if nGrp < 10 && nGrpDiv == 2  % when grp division is 2, assume first is subject marked by shape
    gcolor = []; gshape = [];
    grp_colors='rgbmcykrgb';
    grp_shapes = '.v*xo+sd^<>ph';
    grp_size = [14 6];
    % shape is the index of the first column
    gshape = grp_shapes(grp2idx(grp_names(:,1)));
    % color is the index of the second column
    gcolor = grp_colors(grp2idx(grp_names(:,2)));
    gsize = grp_size(grp2idx(grp_names(:,1)));
elseif nGrp == 1  % when totla grp is one, just do black
    gcolor='k'; gshape=[]; gsize=14;
    if N > 100, gsize = 8; end;
    if N > 1000, gsize = 3; end;
else % multiple groups
    gcolor = get_cmap(nGrp); 
    gsize = 9;
    if nGrp > 3 && nGrp < 12  % if too many, shape doesn't help
        grp_shapes = 'v*xo+sd^<>p';
        % shape is the index of the first column
        gshape = grp_shapes(grp2idx(grp_names(:,1)));
    else
        gshape = '.';
    end
end

if ~isempty(marker_size)
    gsize = marker_size;
end

if show_individual
    % plot scatter
    hS = gscatter(x, y, grp, gcolor, gshape, gsize);
end

% plot group mean and error bar
if nGrp > 1 & show_grpmean
    [mX ebX gname gnumel] = grpstats(x, grp, {'mean','sem','gname','numel'});
    [mY ebY] = grpstats(y, grp, {'mean','sem'});
    
    hold on;
    hSG = gscatter(mX(:,1), mY(:,1), gname, gcolor, [], gsize + 10);
    
    % draw errorbar
    % hE = errorbar(mX, mY, ebY); set(hE,'linestyle','none');
    hE = [];
    for iR = 1:size(mX,1)
        hT1 = line([mX(iR) mX(iR)], [mY(iR) - ebY(iR) mY(iR) + ebY(iR)]);
        hT2 = line([mX(iR) - ebX(iR)  mX(iR) + ebX(iR)], [mY(iR) mY(iR)]);
        set([hT1 hT2], 'color', darker( gcolor(iR,:) ) );
        hE = [hE; hT1; hT2];
    end
    hold off;
    
    [g_r g_p g_N] = corrN(mX, mY, 'type','Spearman','rows','pairwise');
    
    if show_ci > 0
        STE = 1/sqrt(g_N-3);
        % here the input is 95% confidence interval, for 99% use 0.99:
        CI = norminv(show_ci);
        g_r_ub = tanh(atanh(g_r)+CI*STE);
        g_r_lb = tanh(atanh(g_r)-CI*STE);
    end
else
    g_r = NaN; g_p = NaN; g_r_ub = NaN; g_r_lb = NaN;
end

% squarize if plotting zscore
if isnumeric(grp_zscore) && grp_zscore == 1
    axis('square');
end

xlim(xl); ylim(yl); 

% type 2 regression
iV = find(bV);
if nnz(bV) == 0
    title('N=0'); r = NaN; p= NaN; N= NaN; sl= NaN; itc= NaN; fitdata= NaN; return;
end

% can do regression only if more than one values on each axis
if length(unique(x(bV))) <= 1 || length(unique(y(bV))) <= 1
    regress_type = 'none';
end

switch(regress_type)
    case 'none'
        sl=NaN; itc=NaN;
    case 'type1'
        [b1 b1_int] = regress(y(bV), [ones(size(x(bV))) x(bV)]);
        
        sl = b1(2); itc = b1(1);
        itc_ci = b1_int(1,:);
        sl_ci  = b1_int(2,:);
    case 'type2'
        try
            if show_regress_ci % take time.
                [sl, itc, sl_ci, itc_ci] = regress_perp(x(bV),y(bV));
                fprintf(1, 'slope: %.2f [%.2f %.2f], intercept: %.2f [%.2f %.2f]\n', ...
                    sl, sl_ci(1), sl_ci(2), itc, itc_ci(1), itc_ci(2) );
            else
                [sl, itc] = regress_perp(x(bV),y(bV));
            end
        catch ME
            getReport(ME)
            sl=NaN; itc=NaN;
        end
    otherwise
        error('Unknown regress_type: %s', regress_type);
end

% plot global regression line
yfit = xl * sl + itc;
hL = line(xl,yfit,'color','k','linestyle',':');
set(hL,'tag','fit');
% check outliers (data not shown)
nOL = nnz( x(bV) < xl(1) | x(bV) > xl(2) | y(bV) < yl(1) | y(bV) > yl(2) );

% show numbers
if nOL == 0
    if show_ci > 0
        hT = title(sprintf('N=%d,r= %.2f[%0.2f %0.2f](p=%s)', N, r, r_lb, r_ub, p2s(p))); %, x<>y (p=%.2f)', N, r, p));
    else
        hT = title(sprintf('N=%d, r= %.2f (p=%s)', N, r, p2s(p))); %, x<>y (p=%.2f)', N, r, p));
    end
else
    if show_ci > 0
        hT = title(sprintf('N=%d (OL=%d), r= %.2f[%0.2f %0.2f] (p=%s)', N-nOL, nOL, r, r_lb, r_ub, p2s(p))); %, x<>y (p=%.2f)', N-nOL, nOL, r, p));
    else
        hT = title(sprintf('N=%d (OL=%d), r= %.2f (p=%s)', N-nOL, nOL, r, p2s(p))); %, x<>y (p=%.2f)', N-nOL, nOL, r, p));
    end
end

if ~isnan(g_r) 
    if show_ci > 0
        hT = atitle(sprintf('\ngN=%d,gR=%.2f[%0.2f %0.2f](%s)', nGrp,g_r, g_r_lb, g_r_ub, p2s(g_p))); 
    else
        hT = atitle(sprintf('\ngN=%d,gR=%.2f(%s)', nGrp,g_r, p2s(g_p))); 
    end
end

s = get(hT,'string');
if length(s) > 30 && size(s,1) == 1
    s = regexprep(s, ' ', '');
    set(hT, 'fontsize', 8,'string', s);
end

% group legend
cL={}; r2=[]; p2 = [];
for iG=1:length(grp_numel)
%     bG = grp == str2num(grp_names{iG});
    bG = ismember(grp, cellfun(@str2num, grp_names(iG,:) ) , 'rows');
    [r2(iG) p2(iG)] = corr(x(bG), y(bG), 'type','Spearman', 'rows','pairwise');

    
    cL{iG} = [grp_names{iG} ' (N=' num2str(grp_numel(iG)) sprintf(', r=%.2f, p=%s)', r2(iG), p2s(p2(iG)))];
end

if nGrp >= 1 && nGrp < 10 % too many items in the legend is not useful
    % if the correlation is positive, move legend to left top
    if r > 0 && p < .1
        hLeg = legend(hS, cL, 'location','northwest'); legend boxoff
    elseif r < 0 && p < .1
        hLeg = legend(hS, cL, 'location','northeast'); legend boxoff
    else     % no guess about location
        hLeg = legend(hS, cL); legend boxoff;
    end
    if isprop(hLeg, 'AutoUpdate')
        set(hLeg, 'AutoUpdate','off');
    end
else
    legend off;
end

if exist('x_label','var'), xlabel(regexprep(x_label,'_',' ')); end;
if exist('y_label','var'), ylabel(regexprep(y_label,'_',' ')); end;

% set regression line data
fitdata = GenRegLineData(sl, itc,xl,yl); nC = size(fitdata,2);
fitdata(:, nC+1:nC+2) = NaN(size(fitdata,1), 2);
% N r p
fitdata(1:3,nC+1) = [N;r;p];
% slope intercept
fitdata(1:2, nC+2) = [sl; itc];

return;