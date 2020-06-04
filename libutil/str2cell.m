function cS = str2cell(s, delim)
% split string into cell array 
% 2020 HRK

cS = {};
[token, remain] = strtok(s, delim);
iS = 1;
while(token)
    cS{iS} = token;
    [token remain] = strtok(remain, delim);
    iS = iS + 1;
end