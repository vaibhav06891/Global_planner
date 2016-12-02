%================================ test_g01 ===============================
%
%  script test_g01.m
%
%
%  For testing out the srv1 gui.
%
%================================ test_g01 ===============================

%
%  Name:	test_g01.m
%
%  Author:	Patricio A. Vela, pvela@gatech.edu
%
%
%================================ test_g01 ===============================


if (~exist('opath'))
  if (isunix)
    MATLABPATH = '~/Matlab';
  elseif (ispc)
    MATLABPATH = 'H:\Matlab';
  end

  opath = path;


  addpath([ MATLABPATH '/readers' ]);
  addpath([ MATLABPATH '/figutils' ]);
end


srv1gui(true);
