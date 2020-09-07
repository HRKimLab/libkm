function struct_distinctname = scriptvar2struct(script_name, struct_distinctname, bDebug)
% SCRIPTVAR2STRUCT provides a trick to speed up loading script declaration.
% you can declear a global structure variable, and use scriptvara2struct to
% load defined variables to the global structure.
% global gC; scriptvar2struct('VirMEn_Def',gC); 
% global gC; struct2var(gC); % VirMEn_Def 
% see also STRUCT2VAR, LOADDEFS_EXAMPLE
% 2016 HRK
if ~is_arg('bDebug'), bDebug = 0; end;
% register script to structure
eval(script_name)
% search for all variables in the current workspace
varname = whos;

if ~exist('struct_distinctname') || isempty(struct_distinctname)
    struct_distinctname = struct();
end

for iV = 1:length(varname)
   switch (varname(iV).name)
       % variables that needs to be skipped
       case {'script_name', 'struct_distinctname', 'g_exp', 'bDebug'}
           continue;
       otherwise
           struct_value = eval(varname(iV).name);
           
           if bDebug % check if the structure already has the same variable name
               if isfield(struct_distinctname, varname(iV).name)
                   if iscell(struct_value) || isstruct(struct_value) || istable(struct_value) 
                       % I cannot compare old and new values. just overwrite
                       fprintf(1, 'redundent variable name (%s). value will be overwritten', varname(iV).name);
                   elseif struct_distinctname.(varname(iV).name) == struct_value
                       % old and new values are the same. 
                       fprintf(1, 'redundent variable name (%s). Two values are same (%.2f)\n', varname(iV).name, struct_value);
                   else
                       % old and new values are different. 
                       fprintf(1, 'redundent variable name (%s). Two values are different (%.2f)\n', varname(iV).name, struct_value);
                   end
               end
           end
           % assign (overwrite) value
           struct_distinctname.(varname(iV).name) = struct_value;
   end
end