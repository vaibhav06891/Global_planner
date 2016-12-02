function [marker_pos] = marker_positioning(my_rgb_img,bot_pos)

[m ,n, z]= size(my_rgb_img);

for i=1:m
    for j=1:n
        if(my_rgb_img(i,j,1)<70 && my_rgb_img(i,j,2)<70 && my_rgb_img(i,j,3)>130)
            img_lol(i,j)=1;
        else
            img_lol(i,j)=0;
        end
    end
end
min_dist = 50;
marker_pos(2)=0;
marker_pos(1)=0;
x = bot_pos(2);
y = bot_pos(1);
for i=1:m
    for j=1:n
        if(img_lol(i,j)==1)
            dist = sqrt((y-j)^2 + (x-i)^2);
            if(dist<min_dist)
%                 min_dist = dist;
%                 marker_pos(1)=j;marker_pos(2)=i;
                img_lol(i,j)=1;
            else
                img_lol(i,j)=0;
            end
        end
 
    end
end
img_lol = bwareaopen(img_lol, 5);
[a,b] = bwlabel(img_lol);
s = regionprops(a,'centroid');
y_bot = ceil(s(1).Centroid(1));
x_bot = ceil(s(1).Centroid(2));
marker_pos = [y_bot x_bot];

end
