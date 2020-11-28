function conte_fixation_cross(windowPtr)
% Draw a central fixation cross in red
% - Requires PTB3 window pointer
%
% AUTHOR : Mike Tyszka
% REFS   : adapted from http://peterscarfe.com/fixationcrossdemo.html
% PLACE  : Caltech
% DATES  : 2018-03-30 JMT Extract from run_rest.m
%
% % Copyright 2018 California Institute of Technology
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

% Screen number
screenNumber = Screen('WindowScreenNumber', windowPtr);

% Set the alpha blending function for line smoothing
Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window
[~, screenYpixels] = Screen('WindowSize', windowPtr);

% Set the window background to black and get rectangle
windowRect = Screen('Rect', windowPtr);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the window background to black
Screen('FillRect', windowPtr, BlackIndex(screenNumber), windowRect);

% Set fixation cross dimensions relative to screen height
crossSize = fix(screenYpixels * 0.02);
crossThick = fix(crossSize * 0.25);

% Now we set the coordinates (these are all relative to zero we will
% let the drawing routine center the cross in the center of our monitor
% for us)
xCoords = [-crossSize crossSize 0 0];
yCoords = [0 0 -crossSize crossSize];
allCoords = [xCoords; yCoords];

% Draw a white fixation cross, set it to the center of our screen
% and set good quality antialiasing
Screen('DrawLines', windowPtr, allCoords, crossThick, ...
    WhiteIndex(screenNumber), [xCenter yCenter], 2);

% Flip to the screen
Screen('Flip', windowPtr);