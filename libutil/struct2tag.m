function tagname = struct2tag(st, abbr_from, abbr_to)
% generate a tag(name) based on fieldname = value pair of a struct.
% used to set a tag based on fit options
% 20202 HRK

if ~is_arg('abbr_from'), abbr_from = []; end
if ~is_arg('abbr_to'), abbr_to = []; end

if numel(st) > 1
    tagname = structfun(@(x) struct2tag(x, abbr_from, abbr_to), st);
    return;
end

if is_arg('abbr_from')
    assert(numel(abbr_from) == numel(abbr_to), '# of abbr_from and abbr_to should match');
end

tagname = '';
cF = fieldnames(st);
for iF = 1:numel(cF)
    v = st.(cF{iF});
    bV = ismember(abbr_from, cF{iF});
    if nnz(bV) == 0
        fn = cF{iF};
    elseif nnz(bV) == 1
        fn = abbr_to{bV};
    else
        error('more than more abbr_from match with %s', cF{iF});
    end
    
   switch(class(v))
       case 'double'
           if numel(v) ~= 1
               fprintf(1, 'struct2tag: ignore non-single value %s\n', cF{iF});
               continue;
           end
%            assert(numel(v) == 1, 'v should be a single value');
           tagname = [tagname  '__' fn '_' num2str(v)];
       case 'char'
           tagname = [tagname '__' fn '_' v];
       case 'struct'
           disp(['struct2tag: structure-typed field ' cF{iF} ' ignored']);
       otherwise
           error('Unknown field value type: %s', class(v));
   end
   
   
end

tagname = tagname(3:end);