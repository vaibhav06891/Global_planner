function [angle ] = compute_angles(first_pos , second_pos )

% first position is that of centroid of bot always
% second position is that of marker or goal 


ay = second_pos(1) - first_pos(1);
ax = second_pos(2) - first_pos(2);

angle = atan2(ax,ay)*180/pi;
if(angle < 0)
    angle = 360 + angle;
end   

end
