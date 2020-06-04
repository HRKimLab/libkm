function data_titles = set_mpsth_titles(flist)

nF = numel(flist);
data_titles = flist;

% if m# is same across all flist, omit it
mids = NaN(nF, 1);
for iF = 1:nF
   
   tmp = sscanf(flist{iF}, 'm%d'); 
   if numel(tmp) == 1, mids(iF) = tmp; end;
end
if numel(nonnans(mids)) == nF && numel(unique(mids)) == 1
    data_titles = regexprep( data_titles, 'm[0-9]*','');
end