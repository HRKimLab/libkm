% an example declaration script that takes time to load
% see also LOADDEFS_EXAMPLE, SCRIPTVAR2STRUCT, STRUCT2VAR
tLoad = tic; %  measure laoding time

%defines for indexing the different databases; these are potentially protocol-specific
%NOTE: these indices must match the order of the databases defined in the TEMPO protocol!
EYE_DB = 1;		%eye movement samples
SPIKE_DB = 2;	%spike times
EVENT_DB = 3;	%event times
LFP_DB = 4;		%LFP samples

% 
pause(5.0);

% LoadDefs uses pre-loaded struct to declare variables, reduce loading time 20s to 0.1s. 
% if this is called by function other than LoadDefs, give a friendly reminder 
tmp_dbstack=dbstack; s_toc = toc(tLoad);
if ~ismember('LoadDefs', {tmp_dbstack.name}) && s_toc > 3.0
    fprintf(1, 'TEMPO_Def took %.2fs\n', s_toc);
    disp('TEMPO_Def script slows down analysis. consider using LoadDefs'); 
end
