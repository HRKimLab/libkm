function bExist = is_arg(arg_name, default_value)
% used inside a function, for checking if the function has the argument
% arg_name.
bExist = evalin('caller', [' exist(''' arg_name ''',''var'') && ~isempty( ' arg_name ')']);
if ~bExist && nargin == 2
    evalin('caller', [arg_name '=' num2str(default_value)]);
end
