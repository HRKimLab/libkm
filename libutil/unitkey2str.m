function s = unitkey2str(uk)
% convert unitkey to string
% 2017 HRK
s = {};

assert(isstruct(uk) || size(uk, 2) == 4 || size(uk, 2) == 5 || size(uk,2) == 3 || size(uk, 2) == 2);

if isstruct(uk) && isfield(uk, 'mid') % data.id structure
    s = sprintf('m%ds%dr%de%du%d', uk.mid, uk.srd, uk.rid, uk.tid, uk.uid);
else
    for iR = 1:size(uk, 1)
        if size(uk, 2) == 4
%             s{iR, 1} = sprintf('m%ds%d_TT%d_%02d', uk(iR, 1), uk(iR, 2), uk(iR, 3), uk(iR, 4) );
              % modify above 2022/4/24 HRK
              s{iR, 1} = sprintf('m%ds%dr1e%du%d', uk(iR, 1), uk(iR, 2), uk(iR, 3), uk(iR, 4) );
        elseif size(uk, 2) == 5 % 5 columns (m, s, r, 
            if isnan(uk(iR, 4)) && isnan(uk(iR, 5))
                s{iR, 1} = sprintf('m%ds%dr%d', uk(iR, 1), uk(iR, 2), uk(iR, 3));
            else
                s{iR, 1} = sprintf('m%ds%dr%de%du%d', uk(iR, 1), uk(iR, 2), uk(iR, 3), uk(iR, 4), uk(iR, 5) );
            end
        elseif size(uk, 2) == 3 % 3 columns
            s{iR, 1} = sprintf('m%ds%dr%d', uk(iR, 1), uk(iR, 2), uk(iR, 3));
		elseif size(uk, 2) == 2 % 2 columns
			s{iR, 1} = sprintf('m%ds%d', uk(iR, 1), uk(iR, 2));
		else
            error('Unknown key size');
        end
    end
    
    if size(uk, 1) == 1
        s =  s{1};
    end
end

