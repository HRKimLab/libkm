function s = struct2strings(st)
% convert struct to string
% 2025 HRK
s = '';

if isempty(st)
	return
end

cF = fieldnames(st);
NL = char(10);

for iF = 1:numel(cF)
	switch(class( st.(cF{iF}) ) )
		case 'double'
			v = st.(cF{iF});
			if max(abs(v)) < 0.01 % small number
				s = [s sprintf('%s: %s', cF{iF}, sprintf('%f ', st.(cF{iF})) ) NL ];
			elseif round(v) == v  % no decimal number
				s = [s sprintf('%s: %s', cF{iF}, sprintf('%.0f ', st.(cF{iF})) ) NL ];
			else % other cases
				s = [s sprintf('%s: %s', cF{iF}, sprintf('%.4f ', st.(cF{iF})) ) NL ];
			end
			
		case 'string'
			s = [s sprintf('%s: %s', cF{iF}, st.(cF{iF})) NL ];
	end
end