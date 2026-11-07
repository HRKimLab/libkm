function imdata = plot_roi(imdata, msk)
% PLOT_ROI plot ROIs of an image 
% 2017 HRK
if size(imdata, 3) == 1
    imdata = repmat(imdata, [1 1 3]);
end


% if needed, convert struct (new roi format) to cell array (old roi format)
if isstruct(msk)
	c_msk = {};
	fn = fieldnames(msk);
	for iF = 1:nfields(msk)
		c_msk{iF} = msk.(fn{iF});
	end
	msk = c_msk;
end


cmap = hsv( length(msk));
% make it brighter
cmap = brighter(cmap, 2);

for iFN = 1:length(msk)
    if ~is_arg('imdata')
        imdata = zeros( [size( msk{iFN}, 1), size( msk{iFN}, 2) 3] );
    end
    imdata = shade_image(imdata, msk{iFN}, 255 * cmap(iFN,:));
end
imshow(imdata);
end