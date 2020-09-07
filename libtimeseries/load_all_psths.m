function [st dataname_torun bLoaded] = load_all_psths(cD, fname, varargin)
% load all psths based on repo, dataname, neuronname
% see load_psth_files for previous version
% cD = {'HyungGoo_m123s34r1e4u1', 'Aleeza_m20s5r1e1u2', ...}
% 2020 HRK
VirMEn_Path_Def;

repo = '';

process_varargin(varargin);

st = struct();
prev_psth_fpath = '';
dataname_torun = {};
bLoaded = false(size(cD));

if is_arg('repo')
    cD = add_repo(repo, cD)
end

n_file_loaded = 0;
% iterate cell array of datanames or unitnames
for iD = 1:numel(cD)
    repo_dname = cD{iD};
    
    % parse repo id, mid, dataname
    [repo_curr dname] = strtok(repo_dname, '_');
    if isempty(repo_curr) || isempty(dname)
        warning('Cannot process repo_dname %s', cD{iD});
        continue;
    end
    
    fprintf(1, '[%s] ', repo_dname);
    
    if is_arg('repo')
        repo_curr = repo;
    end
    dname = dname(2:end);
    uk = str2unitkey5(dname);
    mid = uk(1);
    
    % check if repo_curr is valid
    if ~EXP_ROOT.isKey(repo_curr)
        error('%s is not a valid repo_curr id', repo_curr);
    end
    
    % load file
    psth_fpath = [EXP_ROOT(repo_curr) 'Analysis' filesep num2str(mid) filesep fname];
    if ~exist(psth_fpath, 'file')
        fprintf(1, 'cannot find %s. skip loading psths\n', psth_fpath);
        continue;
    end
    
    % load only if the psth path is different from previous load
    if ~strcmp(psth_fpath, prev_psth_fpath)
        fprintf(1, 'load  %s  ', psth_fpath);
        d = load(psth_fpath, '-mat');
        n_file_loaded = n_file_loaded + 1;
    else
        fprintf(1, 'reuse %s  ', psth_fpath);
    end
    
    % filter in based on string match with dataname
    cF = fieldnames(d);
    bV = cellfun(@(x) ~isempty(x), regexp(cF, dname));
    iVs = find(bV);

    if isempty(iVs)
        fprintf(1, 'cannot find %s\n', dname);
        dataname_torun{end+1} = dname;
        continue;
    else
        found_names = cF(bV);
        fprintf(1, 'found %d psths ( %s)\n', numel(iVs), sprintf('%s ', found_names{:}) );
    end
        
    % TODO I need to use across-repository unitname
    % e.g., R1m193s1r3e4u1
    for iV = iVs(:)'
        if isfield(st, cF{iV})
            error('%s already exists in the combined psths', cF{iV});
        end
        st.(cF{iV}) = d.(cF{iV});
    end
    
    bLoaded(iD) = true;
    prev_psth_fpath = psth_fpath;
end

fprintf(1, 'total %d psths loaded from %d files\n', nfields(st), n_file_loaded);
