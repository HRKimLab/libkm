function ax_h = modify_legend(ax_h, grp_idx, cL)
% assuming that legend has grp_idx, replace it with user-frendly string.
% HRK 8/25/2015
if ischar(cL), cL = {cL}; end;

assert(length(grp_idx) == length(cL), '# of groups should be same as # of legends');

try
    get(gca, 'Location')
    h_type = 'legend';
catch
    h_type = 'axes';
    ax_h = legend(ax_h);
end

sL = get(ax_h, 'String');

% get color info
ch = findobj(get(ax_h, 'children'), 'type','text');
for iC = 1:length(ch)
   cmap(iC,:) = get(ch(iC),'color'); 
end

% if length(sL) ~= length(cL)
%     warning('# of items in the legend (%d) does not match to input(%d)', ...
%         length(sL), length(cL));
% end

for iL = 1:length(sL)
   leg = sL{iL};
   % matlab 2019 attach prefix 'data'
   leg = regexprep(leg, 'data', '')
   % find '(n=34)'
   iP = findstr(leg, '(');
   if isempty(iP), iP = find(leg == ',',1,'first'); end;
   if isempty(iP), iP = length(leg)+1; end;
   %extract grp id - right before '(n=34)'
   data_tag = leg(1:(iP-1));
   gid = str2num(data_tag); 
   if isempty(gid)
       warning('Cannot find grpidx %s', leg(1:(iP-1)) );
   end
   
   idx_match_gid = find(grp_idx == gid);
   if ~isempty(idx_match_gid)
        leg = leg(iP:end);
        leg = [cL{idx_match_gid} leg];
   end
       
    sL{iL} = leg;
end

set(ax_h, 'String', sL);

% get color info
ch = findobj(get(ax_h, 'children'), 'type','text');
for iC = 1:length(ch)
   set(ch(iC),'color', cmap(iC,:)); 
end
