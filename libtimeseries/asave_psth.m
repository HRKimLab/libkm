function asave_psth(fpath, psth, unitname, save_raw)
% save_psth saves variables including but not limited to psth structure 
% save_psth is a bit complicated. simple is good. 
% See also plot_multiple_psths
% 5/16/2018 HRK

global data

if ~is_arg('save_raw'), save_raw = 0; end
if ~is_arg('unitname') && ~isempty(data) && isfield(data, 'id')
    if isfield(data.id, 'unitname') % neuron is loaded
        unitname = data.id.unitname; 
    else                            % behavior
        unitname = sprintf('%se0u0', data.dataname);
    end
elseif isnumeric(unitname) % if it is unitkey
    unitname = unitkey2str(unitname);
end

% double check that unitname is not weird
if isempty(regexp(unitname,'m[0-9].*s[0-9].*r[0-9].*') ) && ...
        isempty(regexp(unitname,'m[0-9].*s[0-9].*r[0-9].*e[0-9].*u[0-9].*') ) && ...
        isempty(regexp(unitname,'m[0-9].*c[0-9].*r[0-9]') ) && isempty(regexp(unitname,'m[0-9].*c[0-9].*') ) 
    error('unitname is not right: %s', unitname);
end

% remove rate_rsp if it is a valid psth
if ~isempty(psth) && isstruct(psth) && isfield(psth, 'mean')  % psth structure
    % assign unitname
    psth.name = unitname;
    % let's not use psth.array_rsp itself. Will be deprecated.
    psth.array_rsp = [];
    % save_raw
    if ~save_raw
        psth.rate_rsp = [];
    else
        disp(['Save trial-by-trial data (' unitname ')']);
    end
else % not psth structure
    
end
% assign the psth to the designated name
eval( [unitname ' = psth;'] );
% save it to file
asave(fpath, unitname); 
