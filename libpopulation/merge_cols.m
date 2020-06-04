function data = merge_cols(varargin)
% merge different size of column data to make a big data matrix
% each parameters can have multiples columns
nMaxLen = 0;
nCol = 0;
ColIdx = [];    % start offset of nth varargin in the data array
% find array size
for iA=1:nargin
    nMaxLen = max([nMaxLen size(varargin{iA},1)]);
    
    ColIdx(iA) = nCol+1;
    nCol = nCol + size(varargin{iA},2);
end

data = NaN(nMaxLen, nCol);

for iA=1:nargin
    data(1:size(varargin{iA},1), ColIdx(iA):ColIdx(iA)+size(varargin{iA},2)-1 ) = varargin{iA};
end
