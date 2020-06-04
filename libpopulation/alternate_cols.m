function data = alternate_cols(varargin)
% merge different size of column data to make a big data matrix
% each parameters can have multiples columns
nMaxLen = 0;
nCol = 0;
ColIdx = [];    % start offset of nth varargin in the data array
nColEach=[];
% find array size
for iA=1:nargin
    nMaxLen = max([nMaxLen size(varargin{iA},1)]);
    
    ColIdx(iA) = nCol+1;
    nCol = nCol + size(varargin{iA},2);
    nColEach(iA)= size(varargin{iA},2);
end

% check if all arrays have the same column
assert(length(unique(nColEach)) == 1, 'all arrray should have the same column #')

data = NaN(nMaxLen, nCol);


for iA=1:nargin 
    %data(1:size(varargin{iA},1), ColIdx(iA):ColIdx(iA)+size(varargin{iA},2)-1 ) = varargin{iA};
    data(1:size(varargin{iA},1), iA:nargin:end) = varargin{iA};
end
