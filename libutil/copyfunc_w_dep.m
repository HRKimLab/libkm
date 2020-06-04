function copyfunc_w_dep(func, dest_dir)
% copyfunc_w_dep copy function with dependency while ignoring system files.
% func: function name
% dest_dir: destination directory
% HRK 3/1/2017
disp(func)
if ~isdir(dest_dir), mkdir(dest_dir); end

% find matlab system directory
persistent mroot 
if isempty(mroot)
    mroot = matlabroot
end;

% iterate 1-level dependent files
try
flist = depfun(func, '-toponly', '-quiet');
catch ME
    getReport(ME)
    return;
end
for iF = 1:length(flist)
    % ignore if it is matlab system function
   if ~isempty( findstr(flist{iF}, mroot) )
       continue;
   end
      
   [pathstr, fname, ext] = fileparts( flist{iF} );
   % ignore if it the same file
   if strcmpi(fname, func)
       continue;
   end
   % ignore if it already exists in the destination directory
   if exist(fullfile(dest_dir, [fname ext]), 'file')
       continue;
   end
   % copy file
   copyfile(flist{iF}, dest_dir);
   % call copyfunc_w_dep recursively
   copyfunc_w_dep(fname, dest_dir);
end