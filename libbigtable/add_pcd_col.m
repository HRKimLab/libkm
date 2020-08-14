function add_pcd_col(cColName, arData)

%nCol = 0; bColumnsLoaded = {}; iColumnsLoaded = {}; nColumnsLoaded=[];


aPD = evalin('base', 'aPD');
pcd_colname = evalin('base', ['pcd_colname']);
pcd_col2res = evalin('base', ['pcd_col2res']);

nRow = size(aPD, 1);
nCol = size(aPD, 2);

assert( length(cColName) == size(arData,2) );
assert(nRow == size(arData,1));

for iC = 1:length(cColName)
    varname = [cColName{iC}];

    % create index number for each variable
    nCol = nCol + 1;
    cmd_str = [varname ' = ' num2str(nCol) ';'];
    % check variable name redundancy, if loaded for the first time
    bSame = cellfun(@(x) strcmp(x, varname), pcd_colname);
    if any( bSame )
        error('adding colunm name %s is redandunt to [%d] column', varname, find(bSame,1,'first'));
    end

    evalin('base',cmd_str);
    pcd_colname{nCol} = varname;
    pcd_col2res(nCol) = 0;
    aPD = [aPD arData(:,iC)];
end

assignin('base','aPD',aPD);
assignin('base','pcd_colname',pcd_colname);
assignin('base','pcd_col2res',pcd_col2res);