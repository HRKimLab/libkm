function [hPS hPL] = plot_sesion_timecourse(aPD, x, tid_uid_filters)

if length(x) == 1
    x_label = evalin('caller', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('caller', ['aPD(:,' num2str(x) ');']);
elseif ~isempty(inputname(1))
    x_label = inputname(1);
end

[session_ids padata mid_list] =  pd2per_animal_sb_session(aPD, x, tid_uid_filters);

% plot as discontinued lines if NaNs exist
% plot_xmyerr(session_ids, padata)

% skip NaNs and connect real values
cmap = hsv(size(padata, 1));
cla;
hold on;
for iM = 1:size(padata, 1)
    bV = ~isnan(padata(iM, :));
    plot(session_ids(bV), padata(iM, bV), '-o', 'color', cmap(iM,:));
end
plot(session_ids, nanmean(padata, 1), 'k-', 'linewidth', 2);
hold off;
ylabel(x_label); xlabel('session #');
legend(num2str(mid_list));