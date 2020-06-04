function [varargout]= tpsth2psthst(T, fn)
% convert table-psth to struct of psths
% 2020 HRK

if ~is_arg('fn')
    fn = {};
    for iR = 1:size(T,1)
        for iC = 1:size(T,2)
            fn{iR,iC} = sprintf('r%dc%d', iR, iC);
        end
    end
end

psths = struct;

assert(size(T, 1) == size(fn, 1), '# of rows in the T and fn should match');
assert(size(T, 2) == size(fn, 2), '# of columns in the T and fn should match');
assert(size(T, 2) >= nargout, 'nargout is larger than # of columns in table');

for iC = 1:size(T, 2)
    varargout{iC} = struct();
    for iR = 1:size(T,1)
        if ~isempty(T{iR, iC})
            varargout{iC}.(fn{iR, iC}) = T{iR, iC};
        end
    end
end