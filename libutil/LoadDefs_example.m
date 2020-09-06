% LOADDEFS load declaration variables in the script, keep those in the
% global gC struct variable, and assign it back to the workspace when
% needed. This trick reduces 10-20s loading time to 0.1s.
% see also EXAMPLE_DEFS_SCRIPT, SCRIPTVAR2STRUCT, STRUCT2VAR

% Here, detect recursive call and excit if called recursively
tmp_dbstack = dbstack();
if numel(unique( {tmp_dbstack.name} )) < numel({tmp_dbstack.name} ) - 1
    disp('recursive script call. return script');
    return;
end

% use pre-loaded global variable (gC) to load constant values
% instead of running script. it takes too long.
global gC; 

% declaration scripts to check the last modified date
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
    % use pre-loaded values. assign fields in gC to the caller workspace
   struct2var(gC); 
else % file was modified after loaded. re-load the script.
    if ~isempty(gC), fprintf(1, 'reload declaration script(s)...\n'); end;
    gC = []; % to avoid warnings
    for iF = 1:numel(DEF_FILES)
        gC = scriptvar2struct(DEF_FILES{iF}, gC, 0); 
    end
    % update loaded_datenum
    gC.loaded_datenum = datenum(now());
    struct2var(gC); 
end