function [p_opt,fval,exitflag,output,lambda,grad,hessian] = fmincon_repeat(fCost_TI, nRep, p0, A,B,Aeq,Beq, lb, ub, NONLCON, options)
% repeated fmincon with random seed
% use parfor to use parallel processing toolbos if possible
% 2019 HRK

sET = NaN(nRep, 1);
nP = length(p0);
% initliaze p0
p0_rand = NaN(nRep, nP);
for iR = 1:nRep
    for iP = 1:nP
        p0_rand(iR, iP) = randrange_uni(lb(iP), ub(iP), 'uniform');
    end
end
% overwrite first three parameters with the given p0, lower bnd, high bnd
n_p0 = size(p0, 1);
p0_rand(1:n_p0, :) = p0;
p0_rand(n_p0+1, :) = lb;
p0_rand(n_p0+2, :) = ub;

% iterate
% parfor iR = 1:nRep
for iR = 1:nRep
    tstart = tic;
    [p_opt(iR, :) ,fval(iR, 1) ,exitflag(iR, 1), output{iR} ,lambda{iR},grad{iR},hessian{iR}] = fmincon(fCost_TI, p0_rand(iR,:), A,B,Aeq,Beq, lb, ub, NONLCON, options);
%     [p_opt(iR, :) ,fval(iR, 1) ,exitflag(iR, 1), output{iR} ,lambda{iR},grad{iR},hessian{iR}] = ...
%         fmincon(@(x) fCost_TI_noglobal(x, gF), p0_rand(iR,:), A,B,Aeq,Beq, lb, ub, NONLCON, options);
    sET(iR) = toc(tstart);
    % print intermediate result
%     fprintf(1, '%d/%dth in %.1f s (%.1fmins/%.1fmins). p = ', iR, nRep, sET(iR), nansum(sET(1:iR))/60, nanmean(sET) * nRep/60); 
    fprintf(1, '%d/%dth in %.1f s (%.1fmins/%.1fmins). eval = %.2f, p = ', iR, nRep, sET(iR), NaN, NaN * nRep/60, fval(iR, 1)); 
    fprintf(1, '%.4f ', p_opt(iR, :) ); fprintf(1,'\n');
end

% find minimum of all
[~, iR] = min(fval);

% assign return values of the minimum solution
[p_opt,fval,exitflag,output,lambda,grad,hessian] = deal(p_opt(iR, :) ,fval(iR, 1) ,exitflag(iR, 1), output{iR} ,lambda{iR}, grad{iR}, hessian{iR});


% if debug
   fprintf(1, 'took %dth solution: eval = %.2f, p = %s, \n', iR, fval, sprintf('%.4f ', p_opt )); 
% end