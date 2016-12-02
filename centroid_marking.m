function [bot_pos] = centroid_marking(my_rgb_img)

%% Detecting the bot position && finding goal
[m , n ,z ] = size(my_rgb_img);
for i=1:m
    for j=1:n
        if(my_rgb_img(i,j,1)>180 ...
             && my_rgb_img(i,j,2)>180 ...
            && my_rgb_img(i,j,3)>180)
            obs2(i,j)=1;
        else
            obs2(i,j)=0;
        end
    end
end
obs2 = bwareaopen(obs2, 5);
[a,b] = bwlabel(obs2);


s = regionprops(a,'centroid');
s1 = regionprops(a,'area');
if(s1(1).Area > s1(2).Area)
    y_bot = ceil(s(2).Centroid(1));
    x_bot = ceil(s(2).Centroid(2));
    y_goal = ceil(s(1).Centroid(1));
    x_goal= ceil(s(1).Centroid(2));
else
    y_bot = ceil(s(1).Centroid(1));
    x_bot = ceil(s(1).Centroid(2));
    y_goal = ceil(s(2).Centroid(1));
    x_goal= ceil(s(2).Centroid(2));
end
figure, imshow(obs2);
bot_pos =[y_bot x_bot y_goal x_goal];

end