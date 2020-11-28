function triggerDetected = conte_wait_trigger(triggerKey, escKey)
% Simple trigger wait function
%
% RETURNS : true if trigger detected, false if escape key pressed
%
% AUTHOR : Mike Tyszka
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

fprintf('> Waiting for trigger\n');

keep_going = true;
triggerDetected = false;

while keep_going
    
    % Check for key press
    [~, ~, keyCode] = KbCheck;
    
    % Exit on trigger or escape
    if keyCode(escKey)
        fprintf('> Escape key pressed\n');
        triggerDetected = false;
        keep_going = false;
    elseif keyCode(triggerKey)
        fprintf('> Trigger detected\n');
        triggerDetected = true;
        keep_going = false;
    end
    
end