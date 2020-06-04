function cDir = GetResultFile(analysis_dir, subdir)
cDir = cellfun(@(x) [x subdir], analysis_dir,'UniformOutput',false);
