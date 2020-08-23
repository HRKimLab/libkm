function save_psth(key, psth, varargin)
% SAVE_PATH is an old way to save psth. use asave_psth instead
% save data based on key - data pair. data with the same key will be
% overwritten.
% key: 1 * n array of keys
% data: one entity, either value or struct or cell
% 'save_raw' : save individual trial and grp data
% 'append'   : append it or overwrite it
% using append and save_raw can make file size very big, and result in slow
% saving operation since it load all the data every time it saves (not
% DB-like operation).

warning('save_psth is an old way to save psth. use asave_psth instead');
bSaveRaw = 0;
bAppend = 0;

if isempty(psth) || isempty(psth.mean), return; end;

assert(mod(length(varargin), 2) == 0, '# of arg shoud be even');
nF = length(varargin)/2;

% process options first
iOptions = [];
for iF = 1:nF
    opt_name = varargin{iF*2-1};
    opt_value = varargin{iF*2};
    switch(opt_name)
        case {'save_raw'}
            bSaveRaw = opt_value;
            iOptions = [iF*2-1 iF*2];
        case {'append'}
            bAppend = opt_value;
            iOptions = [iF*2-1 iF*2];
        otherwise
    end
end
varargin(iOptions) = [];

nF = length(varargin)/2;
for iF = 1:nF
    grp_name = varargin{iF*2-1};
    filepath = varargin{iF*2};
    
    % find the gname
    bVGrp = psth.gname == grp_name;
    bVTrial = psth.grp == grp_name;

    % if filter is NaN, then include all trials
    if isnan(grp_name)
        bVGrp = true(size(psth.gname));
        bVTrial = true(size(psth.grp));
    end
    
    % do not save if there is no such group in the psth
    if isempty(bVGrp) || nnz(bVGrp) == 0 
        if isnumeric(grp_name), str_grp_name = num2str(grp_name); 
        elseif char(grp_name), str_grp_name = grp_name;
        else, error('Unkown grp_name type');
        end
        fprintf(1, 'No group %s to save in psth. skip saving\n', str_grp_name);
        continue;
    end
    % gname is empty for some cases.
    if isempty(psth.gname) &&  nF == 1
        bVGrp = true; 
    end;

    psth2 = psth;
    psth2.x = psth.x;
    % select valid group
    psth2.mean = psth.mean(bVGrp,:);
    psth2.sem = psth.sem(bVGrp,:);
    psth2.std = psth.std(bVGrp,:);
    psth2.numel = psth.numel(bVGrp,:);
    psth2.n_grp = psth.n_grp(bVGrp,:);
    psth2.pDiff = psth.pDiff;
    psth2.gname = psth.gname(bVGrp,:);
    psth2.pBaseDiff = psth.pBaseDiff(bVGrp,:);
    [~, psth2.idx_sorted_by_num] = sort(psth.idx_sorted_by_num(bVGrp,:));
    psth2.gnumel = psth.gnumel(bVGrp,:);
    
    psth2.array_rsp = [];
    % save raw trial data. this can make file size big, depending on time
    % window and trial #.
    if bSaveRaw
        % select valid trials
        psth2.rate_rsp = psth.rate_rsp(bVTrial,:);
        psth2.grp = psth.grp(bVTrial,:);
    else
        psth2.rate_rsp = [];
        psth2.grp = [];
    end
    % save
    save_key(filepath, key, psth2, bAppend);
    % for now, also save into the combined file. I will eventually move to this
    % structure 5/17/2018 HRK
    asave_psth(filepath, psth2, key);
end