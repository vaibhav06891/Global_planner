%================================== srv1 =================================
%
%  srvh = srv1(ipaddr, port)
%
%
%  Interface object for controlling the Surveyor SRV-1 robot.  Replaces
%  the Java interface programmed by ZZZZ using Java classes with one
%  purely based on Matlab code.  Uses Matlab's built in Java-based TCP/IP
%  interface, which should ultimately be scrapped since it may be the
%  source of the packet drops.
%
%  NOTES:
%    Requires for java to be enabled in Matlab (cannot use -nojvm option).
%
%================================== srv1 =================================

%
%  Name:	srv1.m
%
%  Author:	Patricio A. Vela, pvela@gatech.edu
%
%		using codebase from ...
%
%
%  Created:	2008/10/09
%  Modified:	2008/10/09
%
%  v0.2
%
%================================== srv1 =================================
function srvh = srv1(ipaddr, port)

if ((nargin == 0) || isempty(ipaddr))
  ipaddr = 'tank1';
end

if ((nargin < 2) || isempty(port))
  port = 10001;
end
  
robot = [];
srv_connect(ipaddr, port);


srvh.set = @srv_set;
srvh.get = @srv_get;
srvh.sendRawCommand = @srv_sendRawCommand;
srvh.getImage = @srv_getImage;
srvh.drive    = @srv_drive;
srvh.driveFor = @srv_driveFor;
srvh.free = @srv_free;
srvh.scan = @srv_scan;
srvh.read = @srv_read;
srvh.flush= @srv_flush;


RawCommands = ['01234567890.' 'abcdA' 'lL' 'M' 'oO'];
expbyteTable = {80*64*3, 160*128*3, 320*256*3, 640*512*3, 1280*1024*3};
expsizeTable = {[80 64 3], [160 128 3], [320 256 3], [640 512 3], ...
                                                     [1280 1024 3]};

image = [];


%
%======================= Interface Member Functions ======================
%

  %------------------------------ connect ------------------------------
  %
  %  Establishes the connection with the desired robot
  %
  %   Make sure our Java directory is on the dynamic javaclasspath
  %   Note that [clear java] will force classes on the dynamic path 
  %   to be reloaded.
  %
  function srv_connect(robot_ip, port)
  robot = tcpip(robot_ip, port);
  set(robot, 'InputBufferSize', 640*480);
  set(robot, 'TransferDelay', 'off');	% Need for real-time messaging.
  set(robot, 'Timeout', 2);
  fopen(robot);
  get(robot)
  end


  %
  %-------------------------------- set --------------------------------
  %
  %  Set variables/parameters associated with SRV-1 robot.
  %
  function fval = srv_set(fname, fval)
  switch fname
    case 'caption'
      fval = min(1, max(0, fval));
      robot.set_image_caption(fval);
    case 'quality'
      fval = min(8, max(1, fval));
      robot.set_image_quality(fval);
    case 'resolution'
      robot.set_resolution(res);
      outRes=res;
      % res - 0 for 160x128 (80x64 on old model)
      %     - 1 for 320x256 (160x128 on old model)
      %     - 2 for 640x512 (320x240 on old model)
      %     - 3 for 1280x1024 (640x480 on old model)
    case 'lasers'
      if islogical(fval)
        robot.set_lasers(fval);
      else
        robot.set_lasers(fval > 0);
      end
    case 'tcp'
      set(robot, fval{:});
    otherwise
      fval = [];
  end

  end

  %
  %-------------------------------- get --------------------------------
  %
  %  Get variables/parameters associated with SRV-1 robot.
  %
  function fval = srv_get(fname)
  switch(fname)
    case 'tcp'
      get(robot)
  end
  end

  %
  %----- sendRawCommand -----
  %
  %  Send a low-level command directly to the surveyor without any
  %  pre-processing.  If it is not a recognized command, then it gets
  %  rejected.  Only single character commands are recognized.  Any
  %  command requiring more than a single character should have its
  %  own interface function.
  %
  function ack=srv_sendRawCommand(comstr, argstr)
%   if isempty(strfind(RawCommands, comstr(1)))
%     return;
%   end

  if (nargin == 1)
    fprintf(robot,comstr(1));
  else
    fprintf(robot, [comstr(1) argstr]);
  end
  ack = fread(robot, .5, 'uint8');	
  end

  %
  %----- read -----
  %
  %
  %
  function rdata = srv_scan(readstr, nbytes)
  rdata = [];
  if (nargin == 2)
    if (isempty(readstr))
      readstr = '%c';
    end
    while (get(robot,'BytesAvailable') > 0) && (nbytes > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      if (nbytes > robot.BytesAvailable)
        nbytes = nbytes - robot.BytesAvailable;
	readbytes = robot.BytesAvailable;
      else
	readbytes = nbytes;
        nbytes = 0;
      end
      rdata = fscanf(robot, readstr, readbytes);
    end
  elseif (nargin == 1)  
    while(get(robot,'BytesAvailable') > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      rdata = fscanf(robot, readstr);
    end
  else
    while(get(robot,'BytesAvailable') > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      rdata = fscanf(robot);
    end
  end
  disp(rdata);
  end

  function rdata = srv_read(readstr, nbytes)
  rdata = [];
  if (nargin == 2)
    if (isempty(readstr))
      readstr = 'char';
    end
    while (get(robot,'BytesAvailable') > 0) && (nbytes > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      if (nbytes >= robot.BytesAvailable)
        nbytes = nbytes - robot.BytesAvailable;
	readBytes = robot.BytesAvailable;
      else
	readBytes = nbytes;
        nbytes = 0;
      end
      rdata = [rdata ; fread(robot, readBytes, readstr)];
    end
  elseif (nargin == 1)  
    while(get(robot,'BytesAvailable') > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      rdata = [rdata ; fread(robot, [], readstr)];
    end
  else
    while(get(robot,'BytesAvailable') > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      rdata = [rdata ; fread(robot)];
    end
  end
  end

  function rdata = srv_forceread(readstr, nbytes)
  rdata = [];
  if (nargin == 2)
    if (isempty(readstr))
      readstr = 'char';
    end
    while (nbytes > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      if (nbytes >= robot.BytesAvailable)
        nbytes = nbytes - robot.BytesAvailable;
	readBytes = robot.BytesAvailable;
      else
	readBytes = nbytes;
        nbytes = 0;
      end
      if (readBytes)
        rdata = [rdata ; fread(robot, readBytes, readstr)];
      end
    end
  elseif (nargin == 1)  
    while(get(robot,'BytesAvailable') > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      rdata = [rdata ; fread(robot, [], readstr)];
    end
  else
    while(get(robot,'BytesAvailable') > 0)
      disp(['Bytes available: ' num2str(robot.BytesAvailable,'%d') ]);
      rdata = [rdata ; fread(robot)];
    end
  end
  end

  %
  %------------------------------ getImage -----------------------------
  %
  %  Grab an image using the surveyor's camera.
  %
  function [img rdata] = srv_getImage


  %==(1) Flush the read buffer.
  while(get(robot,'BytesAvailable') > 0)
    disp(['Flushing socket: ' num2str(robot.BytesAvailable,'%d') ]);
    rdata = fread(robot, robot.BytesAvailable, 'uint8');
  end

  %==(2) Send command to retreive image.
  %disp('Sending image grab');
  fprintf(robot,'I');

  %==(3) Reply available, process.
  %disp('Waiting for image grab reply');
  rdata = fread(robot, 10 ,'uint8');	% Process reply header.
  if (length(rdata) ~= 10)
    size(rdata)
    img = [];
    return;
  end
  %cmdecho = char(rdata(1:5))'		% Command echo.
  fsize = str2num(char(rdata(6)));	% Image size spec.
  fbyte = rdata(7:10);			% JPEG size in bytes per SRV-1.
  %disp(['Supposed s0 s1 s2 s3 sequence: ' num2str(fbyte')]);
  sentbytes = sum(fbyte.*(256.^[0;1;2;3]));
  %disp(['Supposed number of bytes: ' num2str(sentbytes)]);
  if ( (sentbytes < 100) || (sentbytes > 3932160) )
    disp('Something is wrong.  Flush the buffer');
    srv_read('uint8',sentbytes);
    img = [];
    return;
  end

  jpeg = uint8(fread(robot, sentbytes, 'uint8'));
  if (length(jpeg) == sentbytes)
    img = jpeg2img(jpeg);
  else
    img = [];
    disp('Incomplete image: rejected.');
  end
  %disp(['Sent versus expected: ' num2str([prod(size(jpeg)) sentbytes],'%d ')]);

  end

  %
  %------------------------------- drive -------------------------------
  %
  %  Send the surveyor a drive command, specifying the velocity of the
  %  tank treads.  Tank will drive indefinitely.
  %
  function ack=srv_drive(motorcmd)
  ack=srv_driveFor(motorcmd, 0);
  end

  %
  %------------------------------ driveFor -----------------------------
  %
  %  Send the surveyor a drive command.  For now agrees with Java class.
  %  The longest amount of time that can be passed is 2.55 seconds. 
  %  If no time is passed, then the robot ignores the command.
  %
  function ack = srv_driveFor(motorcmd, duration)

  if ( (nargin == 1) )
    return;
  end

  motorcmd = int8(max(-127, min(127, motorcmd)));	% Clip to legal values.
  duration = int8(max(   0, min(255, duration)));

  fwrite(robot, 'M', 'char');				% Send command.
  fwrite(robot, [motorcmd], 'int8');
  fwrite(robot, [duration], 'uint8');

  ack = fread(robot, 2, 'uint8');				% Expect reply.
  breakhere = ack;
  end

  %
  %----------------------------- disconnect ----------------------------
  %
  %  Terminates the connection with the robot.
  %
  function srv_disconnect
  fclose(robot);
  delete(robot);
  robot = [];
  end

  %
  %-------------------------------- free -------------------------------
  %
  %  Closes out the robot.
  %
  function srv_free
  srv_disconnect();
  end

   %
   %-------------------------------- flush -------------------------------
   %
   %  Try to send a few commands to de-lock the robot... get it to flush
   %
   function [img1 img2 ack1 ack2] = srv_flush
     ack1 = srv_sendRawCommand('l'); pause(.5);
     ack2 = srv_sendRawCommand('L'); pause(.5);
     img1 = srv_getImage(); pause(1);
     img2 = srv_getImage(); pause(1);
     
   end
   

end

%============================ Helper Functions ===========================

%
%================================== srv1 =================================
