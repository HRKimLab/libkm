function v = sem(x)
v = nanstd(x) ./  sqrt(sum(~isnan(x)))