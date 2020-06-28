function [b rstats] = fit_path(y_psth, x_psths, varargin)
% fit y_psth using x_psths
% 2020 HRK

method = {};
serialize = 0;
borders = [];
n_input_disp = 20; % number of sample input psths to show for display purpose

process_varargin(varargin);

sBorder = borders;

% check homogenity by size
nSizes = structfun(@(x) numel(x.mean), x_psths);
assert(nunique(nSizes) == 1);
% combine x psths
tmp_means = cellfun(@(x) x.mean, struct2cell(x_psths),'un',false);
conv_spikes = cat(1, tmp_means{:});
% prepare X and Y
X = conv_spikes';
Y = y_psth.mean';

nM = numel(method);

for iM = 1:nM
    switch(method{iM})
        case 'lsqlin_positive' % betas except for offset should be positive
%             [X,resnorm,residual,exitflag,output,lambda] = lsqlin(...)
            b(:, iM) = lsqlin([ones(size(Y)) X], Y, [],[], [],[], [-inf zeros(1, size(X, 2))], [inf inf(1, size(X, 2))] );
        case 'regress'
%             [b,bint,r,rint,stats] = regress(Y, [ones(size(Y)) X]);
            b(:, iM) = regress(Y, [ones(size(Y)) X]);
        case 'lasso' % somehow prediction has offset. need to be fixed.
            % [b_lasso,stats_lasso] = lasso([ones(size(Y)) X], Y);
            b_tmp = lasso([ones(size(Y)) X], Y);
            % take the first column
            b(:, iM) = b_tmp(:, 1);
            error('need to be fixed');
        otherwise
            error('Unknown fitting method: %s', method{iM});
    end
    % compute prediction
    predY(:, iM) = [ones(size(Y)) X] * b(:, iM);
end

% compute r-square and some basic goodness-of-fit stats
rstats = compute_gof(Y, [predY]);

%% plot results
% find borders and put NaN to cut the line component. somtimes I want to
% stack plots
iB = find_closest(sBorder, y_psth.x);
setfig(4,1, 'Fit psth using psths');
gna; % plot Xs 
X(iB,:) = NaN;
n_input_disp = min([n_input_disp size(X, 2)]) ;
iSample = randsample(size(X, 2), n_input_disp);
plot(y_psth.x, X(:, iSample) );
draw_refs(0, sBorder, NaN);
stitle('X: %d samples / %d psths, ndata = %d (exc. const)', n_input_disp, size(X, 2), size(X, 1) );
gna; % plot Y and prediction of Ys
Y(iB, :) = NaN; predY(iB, :) = NaN;
plot(y_psth.x, [Y predY]);
draw_refs(0, sBorder, NaN);
legend('Data', method{:});

% stitle('R^2 = %.2f, %.2f, %.2f', rstats(1).ss_ratio2 , rstats(2).ss_ratio2, rstats(3).ss_ratio2);
rs = cat(2, rstats.ss_ratio2 );
stitle('R^2 = %s', sprintf('%.2f ', rs) );

% distribution of betas
gna;
b_tmp = [b]';
b_tmp(:,1) = NaN; % do not show offset
plot_barpair(b_tmp,[],[],'show_mc', 0);
xlabel('Input #'); ylabel('\beta');
