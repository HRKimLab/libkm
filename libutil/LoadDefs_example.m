% use pre-loaded global variable (gC) to load constant values
% instead of running script. it takes too long.
global gC; 

% load last modified date of Def files
% ProtocolDefs is included in TEMPO_Defs, but it should be included here
% to check the last modified date
DEF_FILES = {'TEMPO_Defs','ProtocolDefs'}; 

last_modified_datenum = 0;
for iF = 1:numel(DEF_FILES)
    def_fpath = which(DEF_FILES{iF});
    finfo = dir(def_fpath);
    assert(numel(finfo) == 1, ['there should be only one ' DEF_FILES{iF}]);
    last_modified_datenum = max([last_modified_datenum  finfo.datenum]);
end

% compare last loaded time and last modified datetime
if ~isempty(gC) && isfield(gC, 'loaded_datenum') && gC.loaded_datenum > last_modified_datenum
    % use pre-loaded values
   struct2var(gC); 
else % file was modified after loaded. re-load the script.
    if ~isempty(gC), fprintf(1, 'reload declaration script(s)...\n'); end;
    gC = []; % to avoid warnings
    for iF = 1:numel(DEF_FILES)
        gC = scriptvar2struct(DEF_FILES{iF}, gC, 0); 
    end
    gC.loaded_datenum = datenum(now());
end