function fpaths = get_analysis_fpath(repo_dataname, subdir, postfix)
% get analysis file path
% 2020 HRK
VirMEn_Path_Def;

if ~is_arg('subdir')
    subdir = '';
else
    subdir = [subdir filesep];
end

fpaths = {};
for iD = 1:numel(repo_dataname)
    % parse reponame
    [reponame dataname] = strtok(repo_dataname{iD}, '_')
    dataname = dataname(2:end);
    
    % extract mid
    mid = sscanf(dataname, 'm%d');
    
    % get analysis dir
    fpaths{iD} = [EXP_ROOT(reponame) 'Analysis' filesep num2str(mid) filesep subdir dataname postfix]
end