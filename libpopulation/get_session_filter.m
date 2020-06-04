function SESSION = get_sesion_filter(cStart, cEnd)
% get session filter for batch_run from a set of start and end datanames
% 2019 HRK
SESSION = {};

% iterate and make start filter
for iS = 1:numel(cStart)
   tmp = sscanf(cStart{iS},'m%ds%dr%d' )
   mid = tmp(1); sid = tmp(2); rid = tmp(3);
   
   SESSION{mid} = sid;
end

% iterate and make end filter
for iS = 1:numel(cEnd)
   tmp = sscanf(cEnd{iS},'m%ds%dr%d' )
   mid = tmp(1); sid = tmp(2); rid = tmp(3);
   
   if isempty(SESSION{mid})
       SESSION{mid} = sid;
   elseif SESSION{mid} < sid,
        SESSION{mid} = SESSION{mid}:sid;
   end
end

% print info
for iS = 1:numel(SESSION)
   if isempty(SESSION{iS}), continue; end;
   
   fprintf('m%d\t: ', iS);
   tmp = SESSION(iS);
   fprintf('[');
   fprintf('%d ', tmp{:});
   fprintf(']\n');
end