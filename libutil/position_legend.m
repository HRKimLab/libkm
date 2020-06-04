function position_legend(hL)

lpos = get(hL, 'position');
apos = get(gca,'position');

set(hL,'position', [apos(1)+apos(3) + apos(3)*0.01 , apos(2), lpos(3), lpos(4)]);