function font = getLabelFont(app, type)
%GETLABELFONT get struct font depending on label type 
%   Detailed explanation goes here
switch type
    case 'Title'
        font.Size = app.LabelFontSize_title;
        font.Weight = app.LabelFontWeight_title;
    case 'Text'
        font.Size = app.LabelFontSize_text;
        font.Weight = app.LabelFontWeight_text;
end
end

