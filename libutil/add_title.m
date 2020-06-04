function hT = add_title(sTitle, bFirst)
warning('Use atitle instead of add_title');

global bOverwriteTitle

prev_title = get(get(gca, 'title'),'string');

if (sTitle(end) == '/' || strcmp(sTitle(end-1:end), '\n'))
    bFirst = 'first';
end
sTitle = regexprep(sTitle,'\\n',char(10));

% in case prev_title is two rows
if size(prev_title,1) > 1
    tmp = prev_title'; tmp = tmp(:)'; prev_title = tmp;
end

% if prev_title is too long, try to shrink the size
if size(prev_title, 2) > 20
    prev_title = regexprep(prev_title, '[ ]*', ' ');
end
if size(prev_title, 2) > 20
    prev_title = regexprep(prev_title, '[ ]', '');
end
    
if is_arg('bFirst')   
    prev_title = [' / '  prev_title];
else
    prev_title = [prev_title ' / '  ];
end

if is_arg('bOverwriteTitle') && bOverwriteTitle
    prev_title = '';
end

if is_arg('bFirst')
    new_title = [sTitle prev_title];
else
    new_title = [prev_title sTitle];
end
hT = title(new_title);