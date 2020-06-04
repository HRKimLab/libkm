function asave_as(fpath, psth, savename, varargin)
% save a variable (psth) as different name (savename) with an automatic append option.
% 2020 HRK. started 2016

id = '';     % use more general name than savename
save_raw = 0;
check_id = 1;   % check id convention

process_varargin(varargin);

savename = id;
if ~is_arg('save_raw'), save_raw = 0; end
if ~is_arg('savename') && ~isempty(data) && isfield(data, 'id')
    if isfield(data.id, 'savename') % neuron is loaded
        savename = data.id.savename; 
    else                            % behavior
        savename = sprintf('%se0u0', data.dataname);
    end
elseif isnumeric(savename) % if it is unitkey
    savename = unitkey2str(savename);
end

% double check that savename is not weird
if check_id && isempty(regexp(savename,'m[0-9].*s[0-9].*r[0-9].*') ) && ...
        isempty(regexp(savename,'m[0-9].*s[0-9].*r[0-9].*e[0-9].*u[0-9].*') )
    error('savename is not right: %s', savename);
else
    
end

% remove rate_rsp if it is a valid psth
if ~isempty(psth) && isstruct(psth) && isfield(psth, 'mean')  % psth structure
    % assign savename
    psth.name = savename;
    % let's not use psth.array_rsp itself. Will be deprecated.
    psth.array_rsp = [];
    % save_raw
    if ~save_raw
        psth.rate_rsp = [];
    else
        disp(['Save trial-by-trial data (' savename ')']);
    end
else % not psth structure
    
end
% assign the psth to the designated name
eval( [savename ' = psth;'] );
% save it to file
asave(fpath, savename); 
