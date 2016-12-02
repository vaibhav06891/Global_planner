function [ path ] = path_smoothner( path, im )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


i=1;
while(i<size(path,1)-1)
    x_check = [path(i,1) path(i+2,1)];
    y_check = [path(i,2) path(i+2,2)];
    [x_check_inter, y_check_inter] = interpolate_xy(x_check, y_check);
    flag = 0;
    for k=1:1:size(x_check_inter,2)
        if(im(y_check_inter(1,k),x_check_inter(1,k)) == 0)
            flag=1;
            break;
        end
    end
    if(flag==0)
        path(i+1,:)=[];
    end 
    
    i=i+1;
end


end

