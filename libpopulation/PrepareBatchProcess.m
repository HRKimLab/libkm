function PrepareBatchProcess()
% HRK 2/16/2013
global gSave
% check machine and assign machine id
[tmp hname] = system('hostname');
% trim last space characters
hname = strtok(hname);
switch(hname)
    case 'hgkim',           host_id = 1;
    case 'DeAng_Chianti2',  host_id = 2
    case 'DeAngelisBRock2', host_id = 3;
    otherwise
        error('Cannot recognize hostname. Please register machine %s', hname);
end

gSave.host_id = host_id;
return;