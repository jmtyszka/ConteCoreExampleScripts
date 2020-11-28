function prepare_fixationCross(window, color,CrossWidth,W,H)

Screen(window,'FillRect', color,[(W - CrossWidth - CrossWidth / 2) (H - CrossWidth / 2.7) (W + CrossWidth + CrossWidth / 2) (H+ CrossWidth / 2.7)]);
Screen(window,'FillRect', color, [(W - CrossWidth / 2.7) (H - CrossWidth - CrossWidth / 2) (W + CrossWidth / 2.7) (H + CrossWidth + CrossWidth / 2)]); 