function change_title_fontsize(sz)
% CHANGE_TITLE_FONTSIZE changes font size of the titles in the current
% figure
%
% 2023 HRK
set( arrayfun(@(x) get(x, 'title'), findobj(gcf,'type','axes') ), 'fontsize', sz)