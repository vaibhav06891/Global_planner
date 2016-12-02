function [obs_img1] = detect_obstacle(my_depth_img)

[a,b] =size(my_depth_img);

%% detect obstacle
for i =1:a
    for j=1:b
        if(my_depth_img(i,j)>930 && my_depth_img(i,j)<945)
            obs_img(i,j) = 0;
        else 
            obs_img(i,j)=1;
        end
    end
end
figure('name','Detected Obstacle'), imshow(obs_img);


%% offset correction
for i=1:a
    for j=1:b
        if(i<16)
            obs_img1(i,j) =1;
        else
            obs_img1(i,j) = obs_img(i-15,j);
        end
    end
end
figure('name','Corrected Obstacle map'),imshow(obs_img1)

end