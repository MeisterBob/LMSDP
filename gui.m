%% GUI Erstellen
function gui
    close all

    % Erstellung des Hauptfensters
    handle.fig = figure(...
        'Units', 'pixel',...
        'Position', [1400 600 500 400],...
        'Name', 'Aufgabe 2',...
        'MenuBar', 'none',...
        'ToolBar', 'none');

    % Kontrollelemente
    handle.axes = axes('Units', 'pixel',...
                       'XTick', [],...
                       'YTick', [],...
                       'Position', [30 30 460 260],...
                       'Parent', handle.fig);
%    uicontrol('String','Motorspannung','Style','text','Units','pixel','Position',[25 150 90 15],'Parent',handle.fig);
%    handle.slider = uicontrol('Style', 'slider','Min',0,'Max',100,'Value',50,'Units','pixel','Position', [115 150 150 15]);
    handle.popup_group = uicontrol('Style','popup','Callback',@popup_group_callback,'String','Ordner auswählen','Position',[30 350 180 20],'Units','pixel','Parent',handle.fig);
    handle.popup_group.String = {'111564-university', '182316-education', '327741-future-technology', '333190-valentines-day'};
    handle.popup_pic   = uicontrol('Style','popup','Callback',@popup_pic_callback,'String','Grafik auswählen','Position',[30 320 180 20],'Units','pixel','Parent',handle.fig);

    handle.btn = uicontrol('Style','pushbutton','Units','pixel','Position',[395 350 75 20],'Parent',handle.fig,'Callback',@button_callback,'String','Start');

%    handle.status = uicontrol('String','0','Style','text','Position',[115 130 30 15],'Units','pixel','Parent',handle.fig);

    % Sichern der Handle
    guidata(handle.fig, handle);
    popup_group_callback(handle.popup_group, 'init');
end

%% Popup Group Callback
function popup_group_callback(hObject, event)
    handle = guidata(hObject);
    group = handle.popup_group.String(handle.popup_group.Value);
    group = group{1};
    pics = dir(['svg/',group,'/svg/*.svg']);
    handle.popup_pic.String = string();
    handle.popup_pic.Value = 1;
    pn = string();
    for i=1:numel(pics)
        pn(i) = pics(i).name;
    end
    handle.popup_pic.String = cellstr(pn);
    popup_pic_callback(handle.popup_pic, 'init');
end

%% Popup Pic Callback
function popup_pic_callback(hObject, event)
    handle = guidata(hObject);
    group = string(handle.popup_group.String(handle.popup_group.Value));
    pic = string(handle.popup_pic.String(handle.popup_pic.Value));
    pic = char(strcat('svg/', group, '/png/', strrep(pic, 'svg', 'png')));
    axes(handle.axes);
    
    [img, map, transparency] = imread(pic, 'png', 'BackgroundColor', {0,0,0});
    imshow(img);
end

%% Button Callback
function button_callback(hObject, event)
    handle = guidata(hObject);
    group = string(handle.popup_group.String(handle.popup_group.Value));
    pic = string(handle.popup_pic.String(handle.popup_pic.Value));
    pic = char(strcat('svg/', group, '/svg/', pic));
    readsvg(pic);
end
