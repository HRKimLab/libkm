function resizefig(fid, szFont, h, v)
% resize figure to a square size that is suuitable for publishing
% use sv() for save and open
% 4/17/2017 HRK
DEF_SIZE = 3.0;

if ~is_arg('fid'), fid = gcf; end
if ~is_arg('ratio'), ratio = 1; end
if ~is_arg('szFont'), szFont = 9; end
if ~is_arg('h'), h = 1; end;
if ~is_arg('v'), v = 1; end;

for iF = 1:length(fid)
    figure(fid(iF));
    p = get(fid(iF), 'position');
    if p(2) < 0, p(2) = 100; end; % remote desktop often makes it negative
    set(fid(iF), 'position', [50+50*iF p(2) 400*h 400*v]);
    % Importing it to Adobe Illustrator letter, paper size deteremines the graph size.
    % I work on letter paper which is 8.5 by 11.0 inches. If I want to put
    % two figures in a row, a bit less than 4 inch is optimal. 
    % I used 4 inch and 10-15% margins on each side in Origin. 
    % Here, since I don't use Origin, let's do 3.5 instead.
    set(fid(iF), 'papersize', [DEF_SIZE*h DEF_SIZE*v], 'paperposition', [0 0 DEF_SIZE*h DEF_SIZE*v], 'PaperUnits', 'inches');
    %set(gca,'ytickmode','auto','yticklabelmode','auto');
    szFont = szFont * (1 + 0.3 * (mean([h v])-1) );
    % shrink axis when h or v is shrunken
    if h < 1, ax_ratio_h = (1 + 0.2 * (h-1) ); else, ax_ratio_h = 1; end;
    if v < 1, ax_ratio_v = (1 + 0.2 * (v-1) ); else, ax_ratio_v = 1; end;
    shrink_plots(ax_ratio_h, ax_ratio_v);
    % format figure
    formatfig(szFont, fid(iF), 0);
end