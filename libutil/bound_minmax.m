function y = bound_minmax(x, min_val, max_val)

x = max(x, min_val);
y = min(x, max_val);