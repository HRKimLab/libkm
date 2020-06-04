function flist = dir_fp(p)
flist = dir(p);
[fp fn] = fileparts(p);
if isempty(flist), flist = []; return; end;
    
for iF = 1:length(flist)
   flist(iF).fpath = [fp filesep flist(iF).name];
end