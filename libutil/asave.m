function asave(varargin)
% .mat file with append. save() evokes an error when there is no created file 
% with -append what a stupid behavior..  here is a dirty fix. 
% 2016 HRK

% if file exist, append to the file
if exist(varargin{1}, 'file');
    varargin{end+1} = '-append';
end

func_args = sprintf('''%s'',', varargin{:});
func_args(end) = [];
cmd = ['save(' func_args ');'];

evalin('caller', cmd);