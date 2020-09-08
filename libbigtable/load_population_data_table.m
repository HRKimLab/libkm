function tPD = load_population_data_table()
% LOAD_POPULATION_TABLE_TABLE load population data using table() function
%  This is a working version, and will potentially replace 
%  LoadPopulationDataKey functions in the future. It makes use of Matlab table
%  and inner join to create a big 2D table.
%
% 2020 HRK

tSummary = readtable([fit_dir 'BehData_summary_ext3.dat'],'delimiter','\t', 'ReadVariableNames',1);
tBeta = readtable([fit_dir 'fits_beta3_SignedMag_o' num2str(nObj) '.dat'],'delimiter','\t','ReadVariableNames',1);
tBetaP = readtable([fit_dir 'fits_pval3_SignedMag_o' num2str(nObj) '.dat'],'delimiter','\t','ReadVariableNames',1);
% tBeta = readtable([fit_dir 'fits_beta2_SignedMag_o' num2str(nObj) '.dat'],'delimiter','\t','ReadVariableNames',1);
% tBetaP = readtable([fit_dir 'fits_pval2_SignedMag_o' num2str(nObj) '.dat'],'delimiter','\t','ReadVariableNames',1);

tAll = innerjoin(innerjoin(tBeta, tBetaP, 'Keys', 'CELL'), tSummary, 'LeftKeys', 'CELL', 'RightKeys', 'FILE');