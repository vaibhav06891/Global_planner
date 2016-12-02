close all;
cam_id = 0;

% Re-use existing Freenect instance
if ( ~exist('my_freenect', 'var') )
  my_freenect = Freenect(cam_id);
end

[my_rgb_img, my_depth_img] = my_freenect.getFrame();
[m n]=size(my_depth_img);

%% detect obstacle
obs_img = detect_obstacle(my_depth_img);  

%% Detecting the bot position && finding goal

all_pos = centroid_marking(my_rgb_img);
bot_pos =[all_pos(1) all_pos(2)];
my_rgb_img = insertMarker(my_rgb_img,bot_pos,'x','color','red','size',5);

goal_pos =[all_pos(3) all_pos(4)];
my_rgb_img = insertMarker(my_rgb_img,goal_pos,'x','color','red','size',20);

%% computes the path
path = find_path(obs_img,bot_pos,goal_pos);

%% find marker position

marker_pos = marker_positioning(my_rgb_img,bot_pos);
my_rgb_img = insertMarker(my_rgb_img,marker_pos,'x','color','red','size',5);
figure('name','marked world'),imshow(my_rgb_img)












