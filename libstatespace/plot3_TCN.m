function plot3_TCN(pc_score, varargin)
% plot state space dynamics

grp_label = ''
animation = 1;
sampling_rate = 100;
view_info = [];
traj_cmap = [];

process_varargin(varargin)

nTime = size(pc_score, 1);
nCond = size(pc_score, 2);
nNeuron = size(pc_score, 3);

% set trajector colormap
if isempty(traj_cmap)
    traj_cmap = cool(nCond);
else
    assert(size(traj_cmap, 1) == nCond, 'size of traj_camp(%d) should be same as nCond(%d)', ...
        size(traj_cmap, 1), nCond);
end

set(gca,'colororder', traj_cmap); 
set(gca,'nextplot','replacechild')

plot3(pc_score(:, :, 1), pc_score(:, :, 2), pc_score(:, :, 3) )
hold on
% mark start
plot3(pc_score(1, :, 1), pc_score(1, :, 2), pc_score(1, :, 3),'ko')
% mark end
plot3(pc_score(end, :, 1), pc_score(end, :, 2), pc_score(end, :, 3),'kx')
legend(grp_label);
if ~isempty(view_info)
    view(view_info);
end

% mark traveler 
hTraveler3 = plot3(pc_score(end, :, 1), pc_score(end, :, 2), pc_score(end, :, 3),'kv');
set(hTraveler3,'tag','traveler3D');
hTitle = title('0s');
if animation 
    h_button3D = uicontrol(gcf,'style','pushbutton')
%     h_buttonSave = uicontrol(gcf,'style','pushbutton')
    % h_edit_pause_period = uicontrol(gcf,'style','pushbutton') edit 
    % save data for reply
    dt.ax = gca;
    dt.nTime = nTime;
    dt.pc_score = pc_score;
%     dt.iTime
    set(h_button3D,'string','Travel', 'callback',@travel_3D,'UserData', dt);
%     set(h_button3D,'string','Travel', 'callback',@pause_travel_3D,'UserData', dt);
%     set(h_buttonSave,'string','Travel', 'callback',@travel_save,'UserData', dt);
    travel_3D(h_button3D);
end


function travel_3D(src,event)
    % temp. to save video
    global g_travel
    
    hTraveler3 = findobj(gcf,'tag','traveler3D');
    % retrieve saved data
    dt = get(src,'UserData');
    hTitle = title(dt.ax,'');
    inc = nTime/500;
    if inc < 1, inc = 1; end
    for iTime = 1:inc:nTime
%         if ~g_travel.b_go
%             break;
%         end
        set(hTraveler3,'XData', dt.pc_score(iTime, :, 1), 'YData', dt.pc_score(iTime, :, 2), 'ZData',  dt.pc_score(iTime, :, 3));
        set(hTitle, 'string', sprintf('%.1fs', iTime/sampling_rate) );
        drawnow;
        pause(0.1);
        
        if ~isempty(g_travel) && isfield(g_travel, 'save_output') && g_travel.save_output
           if iTime == 1
               g_travel.ar_cdata = [];
           end
           
           g_travel.c_gf{iTime} = getframe(); 
        end
    end 
end

end


%% temporary function. need to implement more (maybe make a 'save' button
function save_output()
global g_travel
wo = VideoWriter('travel_output.mp4');
wo.set('FrameRate', 30);
wo.open();
for iF = 1:numel(g_travel.c_gf)
    writeVideo(wo, g_travel.c_gf{iF} );
end
wo.close();
end