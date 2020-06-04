function imdata = plot_roi(imdata, msk)
if size(imdata, 3) == 1
    imdata = repmat(imdata, [1 1 3]);
end

cmap = hsv( length(msk));
for iFN = 1:length(msk)
    imdata = shade_image(imdata, msk{iFN}, 255* cmap(iFN,:));
end
imshow(imdata);