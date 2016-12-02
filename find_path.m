function [new_path] = find_path(obs_img,bot_pos, goal_pos)
im = obs_img;
im2 = im;
[m n]= size(im);
%% GENERATION OF SAMPLES AND STATE WITH INTIAL STATE SPACE AND GOAL STATE SPACE 
% figure, imshow(im);
hold on;

start_pos = bot_pos   %[y_bot x_bot];
stop_pos = goal_pos   %[y_goal x_goal];

plot(start_pos(1),start_pos(2),'r.','MarkerSize',20)
text(start_pos(1)+2,start_pos(2)+2,'\leftarrow start')

plot(stop_pos(1),stop_pos(2),'g.','MarkerSize',20)
text(stop_pos(1)+2,stop_pos(2)+2,'\leftarrow stop')

plot([start_pos(1) stop_pos(1)],[start_pos(2) stop_pos(2),],'--r');
slope_main = (stop_pos(2)-start_pos(2))/(stop_pos(1)-start_pos(2));
intercept_main = start_pos(2) - slope_main*start_pos(1);

path=[];
vertex(1,:)=[start_pos(1) start_pos(2) 0];
vertex_count=1;

%% path planning
while(1)
    pos_x = randi(n); 
    pos_y = randi(m);  
    if(im(pos_y,pos_x)==0)
%         pos_con=0;
        continue            % lies within blocked region. Ignore it
    end
    pos_con=0;
    d_min=10000;
    for i=1:1:size(vertex,1)
        % find the path to nearest node
        x_coeff = [vertex(i,1) pos_x];
        y_coeff = [vertex(i,2) pos_y];
        [inter_x , inter_y] = interpolate_xy(x_coeff,y_coeff);
        flag = 0;
        
        for k=1:1:size(inter_x,2)
            if(im(inter_y(1,k),inter_x(1,k)) == 0)
                flag=1;
                break;
            end
        end
        
        % connect to nearest vertex
        if(flag==0)
            pos = [vertex(i,1) vertex(i,2);pos_x  pos_y];        
            d = pdist(pos,'euclidean');
            if(d<d_min)
                d_min = d;
                poss_vertex_pos=i;
                pos_con = 1;
            end
        end        
    end
    if (pos_con==1)
        plot([pos_x vertex(poss_vertex_pos,1)], [pos_y vertex(poss_vertex_pos,2)])
        vertex_count=vertex_count+1;
        vertex(vertex_count,1) = pos_x;
        vertex(vertex_count,2) = pos_y;
        vertex(vertex_count,3) = poss_vertex_pos;
        
        goal_pos = [stop_pos(1) stop_pos(2);pos_x  pos_y];        
        goal_d = pdist(goal_pos,'euclidean');
        if(goal_d<50)
            break;
        end
    end
     
end


%% path selector
path(1,:)=[vertex(vertex_count,1) vertex(vertex_count,2)];
current_state = vertex(vertex_count,3);
inside=2;
while(1)
    path(inside,:)=[vertex(current_state,1) vertex(current_state,2)];
    current_state = vertex(current_state,3);
    if(current_state==0)
        break;
    end
    inside=inside+1;
end
path = flipud(path);
path(inside+1,:)=[stop_pos(1) stop_pos(2)];


%% path plotter
% figure, imshow(im2);
hold on;
plot(start_pos(1),start_pos(2),'r.','MarkerSize',20)
text(start_pos(1)+2,start_pos(2)+2,'\leftarrow start')

plot(stop_pos(1),stop_pos(2),'g.','MarkerSize',20)
text(stop_pos(1)+2,stop_pos(2)+2,'\leftarrow stop')

% % for i=1:1:size(vertex,1)
% %     plot(vertex(i,1),vertex(i,2),'x', 'MarkerSize', 10);
% % end 
for i=1:1:size(path,1)-1
    plot([path(i,1) path(i+1,1)],[path(i,2) path(i+1,2)]);
end
display('before smoothing=')
disp(size(path,1))
new_path = path;
% path = path_smoothner(path, im);


%% path smoother
count=1;
while(1)
    count;
    t = size(new_path,1);
    new_path = path_smoothner(new_path, im);
    if(t == size(new_path,1))
        break
    end
    count= count+1;
end
display('after smoothing =')
disp(size(new_path,1))

figure, imshow(im);
hold on;
for i=1:1:size(new_path,1)-1
    plot([new_path(i,1) new_path(i+1,1)],[new_path(i,2) new_path(i+1,2)])    
end