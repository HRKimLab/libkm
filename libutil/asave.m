function asave(varargin)
% ASAVE save .mat file with append. 
% save( ,'-append') is usuful for saving data, but it evokes an error 
% if there is no existing file. What a stupid behavior.  here is a dirty fix.

% 2016 HRK

% if file exist, append to the file
if exist(varargin{1}, 'file');
    varargin{end+1} = '-append';
end

func_args = sprintf('''%s'',', varargin{:});
func_args(end) = [];
cmd = ['save(' func_args ');'];

evalin('caller', cmd);