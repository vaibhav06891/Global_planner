% NOTE(s): 
% 05/26/2016:
% When running this script, execution may hang on capture of first image 
% frame (ie. Freenect::Freenect() initial getFrame() call when veryfing
% existence of provided camera ID)
% To resolve (hopefully), move parent application (ie. MATLAB) to the
% background

% Script usage parameter(s):
MAX_TIME = 5;      % stream duration (sec.)
FPS = 30;           % frame rate
DELAY_SCALING = 1;  % scale delay to accomodate frame processing time 
                    %   (tune this param. to reach desired fps)
                    
CAM_TILT = 0;       % degrees (+/- 28 deg.)

% Kinect camera ID
cam_id = 0;

if ( ~exist('my_freenect', 'var') )
    my_freenect = Freenect(cam_id);
end

input('Press <Enter> to tilt camera ...\n');
my_freenect.setTiltDeg(CAM_TILT);
% return;
% Congfigure figure tex interpreters
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');

% Grab & display current color & depth frame
[my_rgb_img, my_depth_img] = my_freenect.getFrame();
figure(15001);
subplot(1, 2, 1);
rgb_disp = imagesc(my_rgb_img);     % 8-bit, 640x480x3
title('RGB Camera')
subplot(1, 2, 2);
depth_disp = imagesc(my_depth_img);   % 11-bit, 640x480
title('Depth Camera (11-bit)');

input('Press <Enter> to begin video streaming ...\n');

fps_rec = zeros(MAX_TIME*FPS, 1);
for i = 1:MAX_TIME*FPS
    tic;
    
    % Grab next color/depth frames from kinect
    [my_rgb_img, my_depth_img] = my_freenect.getFrame();
    
    % Update figure display of color & depth
    rgb_disp.CData = my_rgb_img;
    depth_disp.CData = my_depth_img;
    
    pause((1/FPS)*DELAY_SCALING);
    fps_rec(i) = 1/toc;
end

figure(15003);
hist(fps_rec);
title('Measured FPS');
xlabel('FPS');
ylabel('Count');

% my_freenect.shutdown();