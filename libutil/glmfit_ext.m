function [bb, dev, stats] = glmfit_ext(x,y,distr,varargin)
% glmfit does not provide some basic stats. This computes some more useful
% statistics and put it in the stats structure a wrapper function
% computing R2 and p value using deviance has several assumption (e.g.,
% it may work for only a subset of dist and link function)
% please double check stats use it at your own risk!
% 2020 HRK

% remove residuals that take large memory
remove_residuals = 0;

leftoverV = process_varargin(varargin);

assert(size(y, 2) == 1, 'y should be a column vector');
% extract linnk function
% iLink = find(cellfun(@(x) regexpi(x, 'link'), leftoverV));
% if isempty(iLink)
%     switch(distr)
%         case 'binomial'
%             linkfun = 'logit';
%         case 'gamma'
%             linkfun = 'reciprocal';
%         case 'inverse gaussian'
%             error('need further implementation');
%         case 'normal'
%             linkfun = 'identity';
%         case 'poisson'
%             linkfun = 'log';
%         otherwise
%             error('cannot find a default link function for %s', distr);
%     end
% else
%     linkfun = leftoverV{iLink+1};
% else

% reset warning
lastwarn('');

% proposed model
[bb,dev,stats] = glmfit(x,y,distr,leftoverV{:});

% check warning
[LASTMSG, LASTID] = lastwarn();

switch(LASTID)
    case {'stats:glmfit:IllConditioned', 'stats:glmfit:IterationLimit'}
        % this makes all additional stats value to be NaN.
        bb = NaN(size(bb)); dev = NaN;
%         stats.RS = NaN; stat.pRS = NaN; stat.AIC = NaN;
%         return;
    case ''
    otherwise
        bb = NaN(size(bb)); dev = NaN;
        
end
% find out 'constant' option and turn it off
iConstant = [];
for iV = 1:numel(varargin)
    if ischar(varargin{iV}) && ~isempty(regexpi(varargin{iV}, 'constant'))
        iConstant = iV;
    end
end

if any(iConstant)
    varargin{iConstant+1} = 'off';
    disp('constant option was turned off for null model');
end

% null model
[bb0,dev0,stats0] = glmfit(ones(size(x,1),1),y,distr,'constant','off', leftoverV{:});

% compute McFadden’s psudo r-square
% ( LL(proposed model) - LL(null model) )  / ( LL(saturated model)-LL(null model) )
stats.RS_pseudo = (dev/-2 - dev0/-2) / (dev0 / 2);
% assert(stats.RS >= 0 && stats.RS <= 1, 'r-square value is not right (%f)', stats.RS);
if ~isnan(stats.RS_pseudo) && ~(stats.RS_pseudo >= 0 && stats.RS_pseudo <= 1)
    keyboard
end

% compute p value for r-square
% chi-square test can test significance of psudo-R
stats.pRS_peudo = 1 - chi2cdf(dev0 - dev, stats0.dfe - stats.dfe);

% dev is residual deviance, 2 * (LL(saturated model) - LL(proposed model) ) 
stats.AIC = dev + 2 * length(bb);

% compute RS in a conventeional way
stats.RS = 1 - ( sum(stats.resid.^2) / sum(stats0.resid.^2) );
if ~isnan(stats.RS) && ~(stats.RS >= 0 && stats.RS <= 1)
    keyboard
end
stats.pRS = NaN;

% https://stat.ethz.ch/R-manual/R-devel/library/stats/html/anova.glm.html
% For models with known dispersion (e.g., binomial and Poisson fits) the chi-squared test is most appropriate

if remove_residuals
    stats = rmfield(stats, {'resid','residp','residd','resida','wts'});
end


return;
% below is a note that I tried to figure out stuff
%% dig in deviance and log likelihood
% https://www.mathworks.com/matlabcentral/answers/31375-why-deviance-returned-by-glmfit-is-not-2-loglikelihood
x = [2100 2300 2500 2700 2900 3100 3300 3500 3700 3900 4100 4300]';
n = [48 42 31 34 31 21 23 23 21 16 17 21]';
y = [1 2 0 3 8 8 14 17 19 15 17 21]';
[b,dev,stats]= glmfit(x,[y n],'binomial');
yfit= glmval(b, x,'logit','size',n);
% dev/-2 is LL(proposed model) - LL(saturated model)
dev/-2
% logLikelihood= nansum(log( binopdf( y, n, yfit./n)))
sum(log(binopdf(y,n,yfit./n))) - sum(log(binopdf(y,n,y./n)))
dev/-2

[~,dev0,stats0]= glmfit(ones(size(x)), [y n], 'binomial','constant','off');
% dev0/-2 is LL(null model) - LL(saturated model)

% psudo-R = 
% ( LL(proposed model) - LL(null model) )  / ( LL(saturated model)-LL(null model) )
omni_R = (dev/-2 - dev0/-2) / (dev0 / 2)
% chi-square test can test significance of psudo-R
omni_p = 1 - chi2cdf(dev0-dev,stats0.dfe-stats.dfe);

% https://www.youtube.com/watch?v=9T0wlKdew6I (LL is wrong on the video)

%% https://groups.google.com/forum/#!topic/comp.soft-sys.matlab/-7HMv0bNT7s
% Annoyingly the Matlab documentation doesn't give a clear explanation of what the dev output field is from glmfit. I checked this manually by calculating the log-likelihood as explained above for my data, and found that the dev output from glmfit is -2*log-likelihood for that given fit. Therefore, to compute an omnibus p-value for your glmfit vs. a constant model, do something like this:
% omni_p=1-chi2cdf(dev0-dev,stats0.dfe-stats.dfe); % the 0 implies stats and dev from the output of glmfit with a constant model (just a column of ones for the predictors)
% 
% It should be noted that according to the wikipedia entry on deviance, dev
% as used by whomever wrote glmfit is not being used correctly ("the
% quantity {\displaystyle -2\log {\big (}p(y\mid {\hat {\theta }}_{0}){\big )}} -2 \log \big( p(y\mid\hat \theta_0)\big)  is sometimes referred to as a deviance. This is [...] inappropriate, since unlike the deviance used in the context of generalized linear modelling, {\displaystyle -2\log {\big (}p(y\mid {\hat {\theta }}_{0}){\big )}} -2 \log \big( p(y\mid\hat \theta_0)\big) does not measure deviation from a model that is a perfect fit to the data."