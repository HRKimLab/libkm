function imdata = shade_image(imdata, msk, target_color)
% shage image area by brightening (or darkening)
% 10/24/2016 HRK
% imdata: RGB 1-255, m*n*3 uint8 array
% msk: m*n logical array
% target_color: RGB 1*3 array
assert(size(imdata,3) == 3);
assert(size(target_color,2) == 3);
assert(size(imdata, 1) == size(msk, 1));
assert(size(imdata, 2) == size(msk, 2));

imdata = uint8(imdata);

% I can make it stronger by taking NaN target_color and allowing darker by
% not using unit8().
for iC = 1:3
    dL = double(msk * target_color(iC))  - double(imdata(:,:,iC));
    dL(dL < 0) = 0;
    imdata(:,:,iC) = imdata(:,:,iC) + uint8(floor(0.3 * dL));
    iOthers = setdiff(1:3, iC);
    % if it's bright, shading does not work. darken other colors a bit
    imdata(:,:,iOthers) = uint8( double(imdata(:,:,iOthers)) - double(imdata(:,:,iOthers)) .* ...
        double(repmat(msk, [1 1 2])) .* 0.15 );
end