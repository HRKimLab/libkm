function ax = split_axes(ax, h, v, pGap)
% split_axes() split existing axis 
% 10/27/2017 HRK
orig_ax = ax;
if ~is_arg('h'), h = 1; end;
if ~is_arg('v'), v = 1; end;
if ~is_arg('pGap'), pGap = 0.1; end;

pAx = get(orig_ax, 'position');

pH = linspace(pAx(1), pAx(1)+pAx(3), h+1);
wH = (pH(2)-pH(1)) * (1-pGap);
pV = linspace(pAx(2), pAx(2)+pAx(4), v+1);
wV = (pV(2)-pV(1)) * (1-pGap);

ax = [];
for iH = 1:length(pH)-1
    for iV = 1:length(pV)-1
        if iH == 1 && iV == 1
            ax(iV, iH) = orig_ax;
        else
            ax(iV, iH) = axes();
        end
        % push up raster and plot PSTH
        set(ax(iV, iH), 'position', [pH(iH), pV(iV), wH, wV]);
    end
end