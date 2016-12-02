close all
cam_id = 0;

% Re-use existing Freenect instance
if ( ~exist('my_freenect', 'var') )
  my_freenect = Freenect(cam_id);
end

pause(2);
[my_rgb_img, my_depth_img] = my_freenect.getFrame();


bot_pos1 = centroid_marking(my_rgb_img);
goal_pos = [bot_pos1(3) bot_pos1(4)];
bot_pos1 = [bot_pos1(1) bot_pos1(2)];
marker_pos1 = marker_positioning(my_rgb_img,bot_pos1);
angle1 = compute_angles(bot_pos1,marker_pos1);  
%angle = atan((marker_pos(1)-bot_pos(1))/(max = marker_pos(2) - bot_pos(2);arker_pos(2)-bot_pos(2))); 

my_rgb_img = insertMarker(my_rgb_img,bot_pos1,'x','color','red','size',2);
my_rgb_img = insertMarker(my_rgb_img,marker_pos1,'x','color','red','size',2);
figure('name','marked world1'),
subplot(1,1,1)
imshow(my_rgb_img)


robo.driveFor([50 -50],100);
pause(5);
[my_rgb_img, my_depth_img] = my_freenect.getFrame();
bot_pos2 = centroid_marking(my_rgb_img);
marker_pos2 = marker_positioning(my_rgb_img,bot_pos2);
ay2 = marker_pos2(1)-bot_pos2(1);
ax2 = marker_pos2(2) - bot_pos2(2);
angle2 = atan2(ax2,ay2)*180/pi;

if(angle2 < 0)
    angle2 = 360 + angle2;
end   

if(angle2 == 0  && angle1>320)
    angle2 = angle2 + 360;
end

%angle1 = atan((marker_pos1(1)-bot_pos1(1))/(marker_pos1(2)-bot_pos1(2)));

 
my_rgb_img = insertMarker(my_rgb_img,bot_pos2,'x','color','red','size',2);
my_rgb_img = insertMarker(my_rgb_img,marker_pos2,'x','color','red','size',2);
%figure('name','marked world2')
subplot(1,2,2)
imshow(my_rgb_img)

rotated_angle = abs(angle1-angle2)


