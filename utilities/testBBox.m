function testBBox(h,keySet,keyNames)

linespacing = 1.5;
% accomodate old and new versions of h structure
if isfield(h,'theFontSize')
    theFontSize = h.theFontSize;
    theFont     = h.theFont;
    wrapat      = h.wrapat;
else
    theFont     = h.font.name;
    theFontSize = h.font.size2;
    wrapat      = h.font.wrap;
end

Screen('TextSize',h.window,theFontSize);
Screen('TextFont',h.window,theFont);
    
Screen('TextColor',h.window,[255 255 255]);

for iKey = 1:length(keySet),
    instructions = sprintf('Please press %s.',keyNames{iKey});
    DrawFormattedText(h.window,instructions,'center','center',[255 255 255],wrapat,[],[],linespacing);
    Screen('Flip',h.window);
    waitAndCheckKeys(h,inf,keySet(iKey));
    DrawFormattedText(h.window,'Good!','center','center',[255 255 255],wrapat,[],[],linespacing);
    Screen('Flip',h.window);
    WaitSecs(.5);
end
