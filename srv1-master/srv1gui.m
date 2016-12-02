%================================ srv1gui ================================
%
%  This is a GUI function for interfacing the SRV-1 robot manually.
%
%================================ srv1gui ================================

%
%  Name:	srv1gui.m
%
%  Author:	Patricio A. Vela, pvela@gatech.edu
%
%  Created:	2008/10/14
%  Modified:	2008/10/14
%
%  Version:	0.0.1
%
%================================ srv1gui ================================
function srv1gui(doTest)

if (nargin == 0)
  doTest = false;
end

xsize = 320;
ysize = 240;

pfh = imfigProgram([], [240 320], 1, [0.075 0.05 0.25 0.075], 400, [10, -10]);

pfh.addControl('quit','Style','pushbutton','String','Quit', ...
               'Position',[xsize-40,10,60,20],...
	       'TooltipString','Push to quit.', ...
               'Callback',{@quitCallback});

pfh.addControl('connect','Style','pushbutton','String','Connect', ...
               'Position',[20,10,60,20],...
	       'TooltipString','Push to connect to SRV-1 robot.', ...
               'Callback',{@connectCallback});

pfh.addControl('disconnect','Style','pushbutton','String','Disconnect', ...
               'Enable', 'off', 'Position',[100,10,70,20],...
	       'TooltipString','Push to disconnect from SRV-1 robot.', ...
               'KeyPressFcn',{@keypressCallback}, ...
               'Callback',{@disconnectCallback});

tmr = timer('Period',0.25,'ExecutionMode','fixedrate', ...
            'BusyMode','drop','TimerFcn', {@imageCallback});
I = [];

isConnected = false;
rob = [];
ipaddr = 'tank1';

doQuit = false;
while (~doQuit)
  drawnow();
  pause(0.25);
end

pfh.free();
pfh = [];

%======================== User Interface Functions =======================

  %---------------------------- getSRVImage ----------------------------
  %
  %  Grab an image from the SRV-1.
  %
  function I = getSRVImage
  I = rob.getImage();
  end

  %
  %--------------------------- imageCallback ---------------------------
  %
  %
  %
  function imageCallback(obj, event, varargin)
  I = getSRVImage();
  if (~isempty(I))
    pfh.display(I);
    drawnow();
  end
  end
  %
  %-------------------------- keypressCallback -------------------------
  %
  %  Function to handle keypresses.
  %
  function keypressCallback(source, eventdata)
  switch (eventdata.Key)
    case {'numpad0','numpad1','numpad2','numpad3','numpad4','numpad5', ...
          'numpad6','numpad7','numpad8','numpad9'}
      rob.sendRawCommand(eventdata.Key(end));
    case {'0','1','2','3','4','5','6','7','8','9'}
      rob.sendRawCommand(eventdata.Key(end));
    case {'decimal','.'}
      rob.sendRawCommand('.');
    case {'add','subtract'}
      rob.sendRawCommand(eventdata.Character(1));
    case {'l'}
      rob.sendRawCommand(eventdata.Character(1));
    otherwise
      source
      eventdata
  end
  end

  %-------------------------- connectCallback --------------------------
  %
  %  Function to handle the "connect" button press.
  function connectCallback(source, eventdata)
  rob = srv1(ipaddr, 10001);
  pfh.modControl('disconnect','Enable','on');
  pfh.modControl('connect','Enable','off');
  pfh.modControl('quit','Enable','off');
  pfh.set('KeyPressFcn',{@keypressCallback});
  pfh.focus();
  isConnected = true;
  start(tmr);
  end

  function disconnectCallback(source, eventdata)
  stop(tmr);
  rob.free();
  rob = [];
  pfh.modControl('connect','Enable','on');
  pfh.modControl('quit','Enable','on');
  pfh.modControl('disconnect','Enable','off');
  pfh.set('KeyPressFcn',[]);
  pfh.focus();
  isConnected = false;
  end

  function quitCallback(source, eventdata)
  doQuit = true;
  end


end


%----------------------------- getFakeImage ----------------------------
%
%  For testing when robot is not connected.  Grabs a fake image.
%
function I = getFakeImage
I = zeros([240 320]);
I(10:20,10:20) =  50;
I(110:120,110:120) =  150;
end

