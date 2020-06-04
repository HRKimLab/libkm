function [n_row n_col] = get_panel_layout(orient, nPanel)
% get 2D panel layout (# of rows, # of cols) based on the total # of panels
% orient = 0 : letter, landscape
% orient = 1 : letter, portrait
% orient = 2 : based on figures (to make figures square or for screen view)
%
% 2019 HRK
switch(orient)
    case 0 % landsacpe layout
        if      nPanel <= 3,    n_row = nPanel; n_col = 1;
        elseif  nPanel == 4,    n_row = 2;      n_col = 2;
        elseif  nPanel <= 6,    n_row = 2;      n_col = 3;
        elseif  nPanel <= 8,    n_row = 2;      n_col = 4;
        elseif  nPanel <= 12,   n_row = 3;      n_col = 4;
        elseif  nPanel <= 15,   n_row = 3;      n_col = 5;
        elseif  nPanel <= 20,   n_row = 4;      n_col = 5;
        elseif  nPanel <= 24,   n_row = 4;      n_col = 6;
        elseif  nPanel <= 28,   n_row = 4;      n_col = 7;
        elseif  nPanel <= 32,   n_row = 4;      n_col = 8;
        else
            n_row = 4;      n_col = ceil(nPanel/n_row);
        end
        
    case 1 % portrait layout
        if      nPanel <= 3,    n_row = nPanel; n_col = 1;
        elseif  nPanel <= 6,    n_row = 3;      n_col = 2;
        elseif  nPanel <= 8,    n_row = 4;      n_col = 2;
        elseif  nPanel <= 12,   n_row = 4;      n_col = 3;
        elseif  nPanel <= 15,   n_row = 5;      n_col = 3;
        elseif  nPanel <= 20,   n_row = 5;      n_col = 4;
        elseif  nPanel <= 24,   n_row = 6;      n_col = 4;
        elseif  nPanel <= 28,   n_row = 7;      n_col = 4;
        elseif  nPanel <= 32,   n_row = 8;      n_col = 4;
        else
            n_col = 4;      n_row = ceil(nPanel/n_col);
        end
        
    case 3 % for multiple PSTHs, n_row is same or less than 3
        if      nPanel <= 3,    n_row = nPanel; n_col = 1;
        elseif  nPanel == 4,    n_row = 2;      n_col = 2;
        elseif  nPanel <= 6,    n_row = 2;      n_col = 3;
        elseif  nPanel <= 8,    n_row = 2;      n_col = 4;
        elseif  nPanel <= 12,   n_row = 3;      n_col = 4;
        elseif  nPanel <= 15,   n_row = 3;      n_col = 5;
        else
            n_row = 3;      n_col = ceil(nPanel/n_row);
        end
end
