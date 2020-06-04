function hT = stitle(varargin)
% sprintf + title 
% HRK
% stitle(format, parameters) 
% stitle(AX, format, parameters) 
% 
if ishandle(varargin{1})  % first argument is axes handle
    
    format = varargin{2};
    % treat control character (e.g., '\Delta'.
    % this is a trick to avoid making \\ to \\\\
    format = regexprep(format, '\\n', char(10));
    format = regexprep(format, '\\\\','_DOUBLE_BS_');
    format = regexprep(format, '\\','\\\\');
    format = regexprep(format, '_DOUBLE_BS_','\\');
    varargin{2} = format;
    
    hT = title(varargin{1}, sprintf(varargin{2:end}));
else % first argument is format
    format = varargin{1};
    % treat control character (e.g., '\Delta'.
    % this is a trick to avoid making \\ to \\\\
    format = regexprep(format, '\\n', char(10));
    format = regexprep(format, '\\\\','_DOUBLE_BS_');
    format = regexprep(format, '\\','\\\\');
    format = regexprep(format, '_DOUBLE_BS_','\\');
    varargin{1} = format;
    
    
    hT = title(sprintf(varargin{:}));
end