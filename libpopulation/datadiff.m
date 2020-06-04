function datadiff(colidx1, colidx2)
% find missing data = first column - second column
data1 = evalin('caller', ['aPD(:,' num2str(colidx1) ');']);
data2 = evalin('caller', ['aPD(:,' num2str(colidx2) ');']);

bV =  ~isnan(data1) & isnan(data2);
ids = evalin('caller', ['PCD(:,1:2);']);
ids(bV,:)

monkids = unique(ids(bV,1));
monkids=monkids(:)';
for mid=monkids
    evalin('caller', ['opendata(' num2str(mid) ', ' num2str(colidx2) ');']);
end