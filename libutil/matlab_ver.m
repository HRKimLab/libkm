function v = matlab_ver()
% check matlab version for compatibility
% e.g.) works in matlab before graphics change (2014b): if matlab_ver() < 8.4 
% 2019 HRK
a=ver('matlab');
v = str2num( a.Version );