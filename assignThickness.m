function assignThickness(src)
% Function used for the callback from the UI Thickness selection with
% buttons in this case.
valNum = str2double(strrep(src.String,' nm',''));
assignin('base','hAnchors', valNum);
uiresume(gcbf);
end