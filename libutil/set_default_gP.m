function set_default_gP()
% default setting for gP
% 2019 HRK
global gP
% remote desktop requires smaller plot size
gP.remote = 0; 
% 0: landscape 1: portrait 2: depends on the subplots
gP.orient = 0;
% show label (see formatfig())
gP.show_label = 1;
% show title (see formatfig())
gP.show_title = 0;
% save into pdf
gP.save = 1;
% find-tune for further editing program (see formatfig())
gP.editor = 'Illustrator';