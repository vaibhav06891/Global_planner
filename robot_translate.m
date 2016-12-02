function [ target_reached ] = robot_translate( bot_pos, goal_pos,robo,my_freenect )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

target_reached = 0;
for i=1:5
    robo.driveFor([100 100],15)
    [my_rgb_img, my_depth_img] = my_freenect.getFrame();
    pos = centroid_marking(my_rgb_img);
    bot_pos =[pos(1) pos(2)];
    if ( (bot_pos(1)<goal_pos(1)+20 && bot_pos(1)>goal_pos(1)-20) && ...
          (bot_pos(2)<goal_pos(2)+20 && bot_pos(2)>goal_pos(2)-20) )  
            
        target_reached =1;
        break;
    end

end
end

