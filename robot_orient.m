function [ pos ] = robot_orient(bot_pos,marker_pos,goal_pos,robo,my_freenect)
robot_inclination = compute_angles(bot_pos ,marker_pos);
goal_inclination = compute_angles(bot_pos, goal_pos);
og_difference = abs(robot_inclination - goal_inclination);

difference = abs(og_difference);
%%-----correctly orient the bot
flag = 0;
first_move =1;
pos=1;
while~(difference < 10) 
    disp(' i am here')
    if(first_move || flag == 1)
        robo.driveFor([50 -50],50)
        pause(1);
    else 
        robo.driveFor([-50 50],50);
    end
    
    [my_rgb_img, my_depth_img] = my_freenect.getFrame();
    all_pos = centroid_marking(my_rgb_img);
    bot_pos =[all_pos(1) all_pos(2)];
    marker_pos = marker_positioning(my_rgb_img,bot_pos);
    
    robot_inclination = compute_angles(bot_pos ,marker_pos);
    goal_inclination = compute_angles(bot_pos, goal_pos);
    difference = abs(robot_inclination - goal_inclination);       

    if(first_move)
        if(difference>og_difference)    
            flag=0;
        else
            flag =1;
        end
    end
    first_move=0;
    
pos = 1;

end

