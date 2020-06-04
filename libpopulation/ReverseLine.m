function ReverseLine(fpath)
fid = fopen(fpath,'r');
cLine={};
sline = fgets(fid)
while(sline ~= -1)
    cLine = [cLine {sline}];
    sline = fgets(fid)
end
fclose(fid);
    
fid = fopen([fpath '_rev'],'w');
for iL=length(cLine):-1:1
   fprintf(fid,'%s', cLine{iL}); 
end
fclose(fid);