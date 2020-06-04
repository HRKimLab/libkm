function print_psths_loading_info(cD, fname)
% print dataname such that I can re-load it later
% 2020 HRK

if ~is_arg('fname'), fname = ''; end

if isstruct(cD)
    cD = fieldnames(cD);
end

tmp = cD;
tmp = sprintf('''%s'', ', tmp{:});
sDataname = ['cDataname = {' tmp(1:end-1) '};'];
disp(sDataname);
disp(['psths = load_all_psths(cDataname, ''' fname ''');']);
