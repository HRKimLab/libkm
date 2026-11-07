function plot3_TCN(pc_score, varargin)
% PLOT3_TCN plot 3D trajectories in the state space for each condition.
%  plot3_TCN(pc_score, varargin) Plot trajectories for each condition using
%    using different colors.
%
%  PLOT_TCN (2D version) will be deprecated. use this with X-Y view instead.
% 
% See also plot_TCN
%
grp_label = '';
animation = 1;       % to play animation or not
sampling_rate = 100; % to show actual time laps
view_info = [];
traj_cmap = [];
tick_Time = [];
% view_idx = [1 2 3]; % indice used for visualization (by default, first three)

process_varargin(varargin);

% extract dimentions
nTime = size(pc_score, 1);
nCond = size(pc_score, 2);
nNeuron = size(pc_score, 3);

if is_arg('tick_Time')
	assert(numel(tick_Time) == nTime, '# of time ticks (%d) does not match with # of rows (%d) in TCN', ...
		numel(tick_Time) , nTime);
else
	tick_Time = (1:nTime) / sampling_rate;
end

if nNeuron > 3 
    warning('Plot3_TCN: dim (%d) > 3. Use first 3 dims.', nNeuron); 
end

% set colormap used for plotting each condition
if isempty(traj_cmap)
    traj_cmap = cool(nCond);
else
    assert(size(traj_cmap, 1) == nCond, 'size of traj_camp(%d) should be same as nCond(%d)', ...
        size(traj_cmap, 1), nCond);
end

set(gca,'colororder', traj_cmap); 
set(gca,'nextplot','replacechild');


% plot responses using the first 3 dimentions
plot3(pc_score(:, :, 1), pc_score(:, :, 2), pc_score(:, :, 3) );

hold on
% mark start timepoint
plot3(pc_score(1, :, 1), pc_score(1, :, 2), pc_score(1, :, 3),'ko')
% makr zero timepoint
i_zero = find_closest(0, tick_Time);
plot3(pc_score(i_zero, :, 1), pc_score(i_zero, :, 2), pc_score(i_zero, :, 3),'k+')
% mark end timepoint
plot3(pc_score(end, :, 1), pc_score(end, :, 2), pc_score(end, :, 3),'kx');
xlabel('Dim1'); ylabel('Dim2'); zlabel('Dim3');
if is_arg('grp_label')
    legend(grp_label, 'location','east');
else
	legend(arrayfun(@(x) sprintf('G%d',x), 1:3,'un',false));
end
% set the viewpoint
if ~isempty(view_info)
    view(view_info);
end

% mark traveler 
hTraveler3 = plot3(pc_score(1, :, 1), pc_score(1, :, 2), pc_score(1, :, 3),'kv');
set(hTraveler3,'tag','traveler3D');
hTitle = stitle('%.1fs / [%.1fs %.1fs]', tick_Time(1), tick_Time(1), tick_Time(end));

if animation 
    h_button3D = uicontrol(gcf,'style','pushbutton');
    h_button3D_p = uicontrol(gcf,'style','pushbutton','Position',[10 350 100 30]);
    h_button3D_r = uicontrol(gcf,'style','pushbutton','Position',[10 400 100 30]);
%     h_buttonSave = uicontrol(gcf,'style','pushbutton')
    % h_edit_pause_period = uicontrol(gcf,'style','pushbutton') edit 
    % save data for reply
    dt.ax = gca;
    dt.nTime = nTime;
	dt.tick_Time = tick_Time;
    dt.pc_score = pc_score;
%     dt.iTime
    set(h_button3D,'string','Travel', 'callback',@travel_3D,'UserData', dt);
    set(h_button3D_p,'string','Pause', 'callback',@pause_travel_3D);
    set(h_button3D_r,'string','Resume', 'callback',@resume_travel_3D);
%     set(h_button3D,'string','Travel', 'callback',@pause_travel_3D,'UserData', dt);
%     set(h_buttonSave,'string','Travel', 'callback',@travel_save,'UserData', dt);
    
    % run travel
%     travel_3D(h_button3D);
end


function travel_3D(src,event)
    % temp. to save video
    global g_travel
    
    hTraveler3 = findobj(gcf,'tag','traveler3D');
    % retrieve saved data
    dt = get(src,'UserData');
    hTitle = title(dt.ax,'');
    inc = round(nTime/500);
    if inc < 1, inc = 1; end
    for iTime = 1:inc:nTime
%         if ~g_travel.b_go
%             break;
%         end
        set(hTraveler3,'XData', dt.pc_score(iTime, :, 1), 'YData', dt.pc_score(iTime, :, 2), 'ZData',  dt.pc_score(iTime, :, 3));
%         set(hTitle, 'string', sprintf('%.1fs', iTime/sampling_rate) );
		set(hTitle, 'string', sprintf('%.1fs / [%.1fs %.1fs]', dt.tick_Time(iTime), dt.tick_Time(1), dt.tick_Time(end) ) );
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

function pause_travel_3D(varargin)
    uiwait;
end


function resume_travel_3D(varargin);
    uiresume;
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