close all;
cam_id = 0;

% Re-use existing Freenect instance
if ( ~exist('my_freenect', 'var') )
  my_freenect = Freenect(cam_id);
end
[my_rgb_img, my_depth_img] = my_freenect.getFrame();
[m, n, z] = size(my_rgb_img);

for i=1:m
    for j=1:n
        if(my_rgb_img(i,j,1)>200 ...
             && my_rgb_img(i,j,2)>200 ...
            && my_rgb_img(i,j,3)>200)
            obs1(i,j)=1;
        else
            obs1(i,j)=0;
        end
    end
end
obs1 = bwareaopen(obs1, 5);
figure, imshow(obs1)
[a,b] = bwlabel(obs1);
s = regionprops(a,'centroid');

y_bot = ceil(s(1).Centroid(1));
x_bot = ceil(s(1).Centroid(2));
[rob_pos] = [y_bot x_bot];
my_rgb_img = insertMarker(my_rgb_img,rob_pos,'x','color','red','size',10);


robo.driveFor([100 -100],100);
pause(2)
[my_rgb_img, my_depth_img] = my_freenect.getFrame();

for i=1:m
    for j=1:n
        if(my_rgb_img(i,j,1)>200 ...
             && my_rgb_img(i,j,2)>200 ...
            && my_rgb_img(i,j,3)>200)
            obs2(i,j)=1;
        else
            obs2(i,j)=0;
        end
    end
end
obs2 = bwareaopen(obs2, 5);
figure, imshow(obs2)
[a,b] = bwlabel(obs2);
s = regionprops(a,'centroid');

y_bot1= ceil(s(1).Centroid(1));
x_bot1= ceil(s(1).Centroid(2));
[rob_pos1] = [y_bot1, x_bot1];
my_rgb_img = insertMarker(my_rgb_img,rob_pos1,'x','color','red','size',10);
dist = sqrt((y_bot1-y_bot)^2 + (x_bot-x_bot1)^2)




