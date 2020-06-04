A = dataset('File','Z:\Users\HyungGoo\sim\mle_final_varying_amp\mAnalysis\bias_by_tunings.dat','ReadVarNames','on'); %,'ReadObsNames',true)
B = dataset('File','Z:\Users\HyungGoo\sim\mle_final_varying_amp\mAnalysis\cell_pop_prop.dat','ReadVarNames','on')
C = dataset('File','Z:\Users\HyungGoo\sim\mle_final_varying_amp\mAnalysis\file_mapping.m','ReadVarNames','on')
D = dataset('File','Z:\Users\HyungGoo\sim\mle_final_varying_amp\mAnalysis\population_properties.dat','ReadVarNames','on')
D.PrefType = nominal(D.PrefType,{'EqualStep','Uniform','Bimodal'}, [1 2 3]);
D.VestType = nominal(D.VestType,{'Full','Half'}, [1 2]);
D.AmpType = nominal(D.AmpType ,{'Constant','Varying'}, [1 2]);

A.CELL = cellfun(@(x) x(1:findstr(x,'r')-1), A.CELL,'uniformoutput',false); A = unique(A,'CELL','last');
B.CELL = cellfun(@(x) x(1:findstr(x,'r')-1), B.CELL,'uniformoutput',false); B = unique(B,'CELL','last');
D.CELL = cellfun(@(x) x(1:findstr(x,'r')-1), D.CELL,'uniformoutput',false); D = unique(D,'CELL','last');

bComment = cellfun(@(x) x(1) == '%', C.CELL )
C = C(~bComment,:);
C = unique(C,'CELL','last');

maineffectsplot(T.TotalwObj, {T.PrefType, T.VestType, T.AmpType})
interactionplot(T.TotalwObj, {T.PrefType, T.VestType, T.AmpType})
T = join(A,B,'Keys','CELL');
T = join(T,C,'Keys','CELL');
T = join(T,D,'Keys','CELL');

% check missing variables
any(any(ismissing(T)))
