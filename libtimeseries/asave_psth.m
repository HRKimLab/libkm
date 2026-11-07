function asave_psth(fpath, psth, unitname, save_raw)
% ASAVE_PSTH saves psth structure into a file.
%  ASAVE_PSTH(fpath, psth) saves psth (the return value of plot_timecourse)
%  into a file path (fpath). Because psth is saved under the given
%  unitname, you can save results from different sessions (or different
%  neurons within the same session) into a single file.
% 
% asave_psth(fpath, psth, unitname)
%  specifies unitname used to save the data. If not given, it uses unitname
%  of the currently loaded neuron.
% 
% asave_psth(fpath, psth, unitname, save_raw)
%  if save_raw == 1, it saves trial-to-trial data in psth. Use this option
%  only necessary (e.g., you want to combine trial-to-trial data at the
%  population level) because it makes file size quite big. 
%
%  Note that asave_psth is mainly used for saving psth result, 
%  it is a general routine that saves variables and can be used for other
%  purpose.
%
% See also plot_mpsths, combine_psth_trials, ASAVE
%
% derived from save_psth, which was a bit complicated. simple is good. 
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
        disp(['Save PSTH (' unitname ') to ' fpath]);
    else
        disp(['Save PSTH with trial-by-trial data (' unitname ') to ' fpath]);
    end
else % not psth structure
    
end
% assign the psth to the designated name
eval( [unitname ' = psth;'] );
% save it to file
asave(fpath, unitname); 
