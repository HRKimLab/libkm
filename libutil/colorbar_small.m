function hA = colorbar_small()

pos=get(gca,'position');
hA = colorbar('location','east');
set(hA, 'yaxislocation','right');
% set tick direction outward
set(hA,'tickdir','out');
% increase tick length a bit
set(hA, 'ticklength', [0.01 0.025]);
% erase box outline
box(hA, 'off')

set(hA,'position', [pos(1)+pos(3)+pos(3)*0.05 pos(2)+pos(4)*0.2 pos(3)*0.07 pos(4)*0.6]);
