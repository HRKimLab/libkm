function hT = atitle(ax, sTitle, bFirst)
% append title to the current one
% 2016 HRK
global bOverwriteTitle

MAX_CHAR_LEN = 20;
content_split = ['/'];
    
% ax can be omitted. behave smartly.
if ischar(ax) && nargin == 3
    error('first argument should be axis handle');
elseif ischar(ax) && nargin == 2
    bFirst = sTitle;
    sTitle = ax;
    ax = gca;
elseif (isempty(ax) || ischar(ax)) && nargin == 1
    sTitle = ax;
    ax = gca;
end

if ~is_arg('bFirst')
    bFirst = 1;
end

if isempty(sTitle)
    return;
end

% if bFirst=1, append to the first
prev_title = get(get(ax, 'title'),'string');

% new version of matlab uses cell array of string for multiple lines.
if iscell(prev_title)
    if bFirst
        if numel([prev_title{1} sTitle]) > MAX_CHAR_LEN
            new_title = {sTitle, prev_title{:}};
        else
            new_title = prev_title;
            new_title{1} = [sTitle content_split prev_title{1}];
        end
    else
        if numel([prev_title{end} sTitle]) > MAX_CHAR_LEN
            new_title = {prev_title{:}, sTitle};
        else
            new_title = prev_title;
            new_title{end} = [prev_title{end} content_split sTitle];
        end
    end
    hT = title(ax, new_title, 'interpreter','none');
    return;
end

% lower version of matlab in which multiple lines are char array. 
% implementation is a bit messy.
% do automatic line change below
% sTitle = regexprep(sTitle,'\\n',char(10));
if regexp(sTitle, '\\n')
    sTitle = regexprep(sTitle,'\\n','');
    bMany = 1; 
end

% in case prev_title is two rows
if size(prev_title,1) > 1
    if ischar(prev_title)
        tmp = prev_title'; tmp = tmp(:)'; prev_title = tmp;
    else
        error('Unknown prev_title type');
    end
end

% if prev_title is too long, try to shrink the size
if size(prev_title, 2) > MAX_CHAR_LEN || (is_arg('bMany') && bMany == 1)
    bMany = 1;
else
    bMany = 0;
end

% if bMany
%     prev_title = regexprep(prev_title, ['[ ]*' char(10)], ' ');
%     prev_title = regexprep(prev_title, '[ ]', '');
% else
% end

if is_arg('bFirst') && bFirst
    if bMany
        prev_title = [content_split char(10) prev_title];
    else
        prev_title = [content_split prev_title];
    end
else
    if bMany
        prev_title = [prev_title char(10) content_split];
    else
        prev_title = [prev_title content_split];
    end
    
end

if is_arg('bOverwriteTitle') && bOverwriteTitle
    prev_title = '';
end

if is_arg('bFirst') && bFirst 
    new_title = [sTitle prev_title];
else
    new_title = [prev_title sTitle];
end
hT = title(ax, new_title);