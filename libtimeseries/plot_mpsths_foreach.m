function [p, ax, flist] = plot_mpsth_foreach(psths, foreach, varargin)
% split psths into subsets, and call plot_mpsths for each subset
% 2020 HRK

global gP

n_row = [];
n_col = [];

leftover_varargin = process_varargin(varargin);

if isempty(psths), return; end;

% get datanames from psth structure
[flist cPSTH] = sort_psth_structs(psths);
n_psth = numel(flist);
ukey = str2unitkey5(flist);

% create cell array of psths according to the foreach 
c_psths = {}; c_title = {};
switch(foreach)
    case {'subject','mid'}  % make cell array of psths for each subject
        unq_mids = unique(ukey(:,1));
        for iS = 1:numel(unq_mids)
            bV = ukey(:,1) == unq_mids(iS) ;
            c_psths{iS} = cell2psths( cPSTH(bV), flist(bV) );
            c_title{iS} = sprintf('m%d', unq_mids(iS) );
        end
    case {'session','sid'} % make cell array of psths for each session
        unq_sids = unique(ukey(:,2));
        for iS = 1:numel(unq_sids)
            bV = ukey(:,2) == unq_sids(iS) ;
            c_psths{iS} = cell2psths( cPSTH(bV), flist(bV) );
            c_title{iS} = sprintf('s%d', unq_sids(iS) );
        end
    otherwise
        error('Unknown foreach option: %s', foreach);
end

nF = numel(c_psths);
if isempty(n_row) && isempty(n_col)
    n_row = nF;
end

p = setpanel(n_row, n_col, ['mpsths for each ' foreach]); 
p.margin = 12;
for iF = 1:nF
    pp = gnp;
    ax(iF, 1) = pp.select();
end

% plot PSMAs (peri-stimulus moving average)
for iF = 1:nF
    psths = c_psths{iF};
    plot_mpsths(psths, 'ax', ax(iF), leftover_varargin{:})
    
    atitle(ax(iF), c_title{iF});
end