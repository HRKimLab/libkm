function delete_tag(tag)
% delete text with a certain tag
if ~is_arg('tag')
    disp('Possible tags: pval, sigmark, median');
    return
end
delete(findobj(gca, 'tag',tag));