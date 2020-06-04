function formatdefaultfig(bRemove)

if is_arg('bRemove') && bRemove == 0
    evalin('caller','figinfo.bNew=0');
    set(0,'defaulttextfontsize','remove');
    set(0,'defaultaxesfontsize','remove');
else
    evalin('caller','figinfo.bNew=1');
    set(0,'defaulttextfontsize',21);
    set(0,'defaultaxesfontsize',15);
end
