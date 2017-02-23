%% GUI Erstellen
function gui
    close all
    warning('off', 'all');

    %% GUI
    % Erstellung des Hauptfensters
    handle.fig = figure(...
        'Units', 'pixel',...
        'Position', [1100 600 500 400],...
        'Position', [1200 1600 500 400],... % zweiter Bildschirm (oben)
        'Name', 'Delta Plotter',...
        'MenuBar', 'none',...
        'ToolBar', 'none');

    % Kontrollelemente
    handle.axes = axes('Units', 'pixel',...
                       'XTick', [],...
                       'YTick', [],...
                       'Position', [30 30 355 260],...
                       'Parent', handle.fig);
    handle.popup_group = uicontrol('Style','popup','Callback',@popup_group_callback,'String','Ordner auswählen','Position',[30 350 180 20],'Units','pixel','Parent',handle.fig);
    handle.popup_group.String = {'111564-university', '182316-education', '327741-future-technology', '333190-valentines-day'};
    handle.popup_pic   = uicontrol('Style','popup','Callback',@popup_pic_callback,'String','Grafik auswählen','Position',[30 320 180 20],'Units','pixel','Parent',handle.fig);

    uicontrol('String','Stift unten Position: ','Style','text','Units','pixel','Parent',handle.fig,'Position',[230 350 100 15]);
    handle.pendown_text = uicontrol('String',0,'Style','text','Units','pixel','Parent',handle.fig,'Position',[330 350 25 15]);
    handle.pendown = uicontrol('Style', 'slider','Min',-280,'Max',-170,'SliderStep',[1/110,5/110],'Units','pixel','Position', [230 320 125 20],'Callback',@pendown_callback);
    handle.btn = uicontrol('Style','pushbutton','Units','pixel','Position',[395 350 75 20],'Parent',handle.fig,'Callback',@start_callback,'String','Start');
    handle.btn_nikolaus  = uicontrol('Style','pushbutton','Units','pixel','Position',[395 320 75 20],'Parent',handle.fig,'Callback',@btn_nikolaus_callback,'String','Nikolaus');
    handle.btn_nullpunkt = uicontrol('Style','pushbutton','Units','pixel','Position',[395 30 75 20],'Parent',handle.fig,'Callback',@btn_nullpunkt_callback,'String','Nullpunkt');

    uicontrol('String','Batteriespannung: ','Style','text','Units','pixel','Parent',handle.fig,'Position',[395 350 100 15]);
    handle.pendown_text = uicontrol('String',0,'Style','text','Units','pixel','Parent',handle.fig,'Position',[330 350 25 15]);

%     handle.status = uicontrol('String','0','Style','text','Position',[115 130 30 15],'Units','pixel','Parent',handle.fig);
%     voltage = NXT_GetBatteryLevel();

    %% NXT
    % Verbindung zum NXT
    COM_CloseNXT('all');
    disp('Verbinde zu NXT...');
    NXT = COM_OpenNXTEx('Any', '0016531B83BC', 'bluetooth.ini');
    COM_SetDefaultNXT(NXT);
    disp('...Verbindung hergestellt');

    %% Maschinenparameter
    handle.machine = struct();
    handle.machine.E0        = struct('x', 0, 'y', 0, 'z', 0);       % Effektor Position
    handle.machine.theta     = struct('a', 0, 'b', 0, 'c', 0);       % Motorwinkel
    handle.machine.f         = 500;                                  % Kantenlänge Motorplattform in mm
    handle.machine.e         = 140;                                  % Kantenlänge Effektor in mm
    handle.machine.rf        = 136;                                  % Oberarmlänge in mm
    handle.machine.re        = 264;                                  % Unterarmlänge in mm

    handle.machine.fr        = handle.machine.f/2*tan(pi*1/6);       % Motorplattform Radius in mm
    handle.machine.er        = handle.machine.e/2*tan(pi*1/6);       % Effektor Radius in mm

    handle.machine.Position  = struct('x', 0, 'y', 0, 'z', 0);

    handle.machine.gearRatio = 5;                                    % Getriebe Übersetzung
    handle.machine.Power     = 35;

    handle.machine.zhome     = -110;
    handle.machine.penup     = -230;
    handle.machine.pendown   = handle.machine.penup-20;
    handle.machine.maxauslenkung = 50;

    %% Motoren
    % Motor A
    handle.machine.motorA = NXTMotor(MOTOR_A);
    handle.machine.motorA.SmoothStart = false;
    handle.machine.motorA.SpeedRegulation = false;
    handle.machine.motorA.ActionAtTachoLimit = 'Brake';
    % Motor B
    handle.machine.motorB = handle.machine.motorA;
    handle.machine.motorB.Port = MOTOR_B;
    % Motor C
    handle.machine.motorC = handle.machine.motorA;
    handle.machine.motorC.Port = MOTOR_C;

    handle.pendown_text.String  = handle.machine.pendown;
    handle.pendown.Value        = handle.machine.pendown;

    %% Sichern des Handles
    guidata(handle.fig, handle);
    popup_group_callback(handle.popup_group, 'init');
    handle.popup_pic.Value = 16;
    popup_pic_callback(handle.popup_pic, 'init');
end

%% Popup Group Callback
function popup_group_callback(hObject, event)
    handle = guidata(hObject);
    group = handle.popup_group.String(handle.popup_group.Value);
    group = group{1};
    pics = dir(['svg/',group,'/svg/*.svg']);
    handle.popup_pic.String = '';
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
    
    [img, map, transparency] = imread(pic, 'png', 'BackgroundColor', {1,0,0});
    imshow(abs(1./img));
end

%% Button Start Callback
function start_callback(hObject, event)
    handle = guidata(hObject);
    group = string(handle.popup_group.String(handle.popup_group.Value));
    pic = string(handle.popup_pic.String(handle.popup_pic.Value));
    pic = char(strcat('svg/', group, '/svg/', pic));
    svg = readsvg(pic);
    handle.axes.XTick = [];
    handle.axes.YTick = [];
    drawnow;

%     svg.maxX * ((handle.machine.maxauslenkung*2)/(svg.maxX-svg.minX)) - handle.machine.maxauslenkung
%     svg.minX * ((handle.machine.maxauslenkung*2)/(svg.maxX-svg.minX)) - handle.machine.maxauslenkung
%     svg.maxY * ((handle.machine.maxauslenkung*2)/(svg.maxY-svg.minY)) - handle.machine.maxauslenkung
%     svg.minY * ((handle.machine.maxauslenkung*2)/(svg.maxY-svg.minY)) - handle.machine.maxauslenkung
    scaleX = ((handle.machine.maxauslenkung*2)/(svg.maxX-svg.minX));
    scaleY = ((handle.machine.maxauslenkung*2)/(svg.maxY-svg.minY));

    for i=1:numel(svg.path)
        move(handle.machine, ...
             svg.path{i}{1}(1) * scaleX - handle.machine.maxauslenkung,...
             svg.path{i}{2}(1) * scaleY - handle.machine.maxauslenkung,...
             handle.machine.penup);
        for j=1:numel(svg.path{i}{1})
            move(handle.machine, ...
                 svg.path{i}{1}(j) * scaleX - handle.machine.maxauslenkung,...
                 svg.path{i}{2}(j) * scaleY - handle.machine.maxauslenkung,...
                 handle.machine.pendown);
        end
        move(handle.machine, ...
             svg.path{i}{1}(j) * scaleX - handle.machine.maxauslenkung,...
             svg.path{i}{2}(j) * scaleY - handle.machine.maxauslenkung,...
             handle.machine.penup);
    end
    move(handle.machine,0,0,handle.machine.zhome);
end

%% Button Nikolaus Callback
function btn_nikolaus_callback(hObject, event)
    handle = guidata(hObject);
    d=handle.machine.maxauslenkung; % Kantenlänge in mm / 2
% handle.machine.pendown
    move(handle.machine, -d,-d,handle.machine.penup);
    move(handle.machine, -d,-d,handle.machine.pendown);
    move(handle.machine, -d,+d,handle.machine.pendown);
    move(handle.machine, +d,-d,handle.machine.pendown);
    move(handle.machine, -d,-d,handle.machine.pendown);
    move(handle.machine, +d,+d,handle.machine.pendown);
    move(handle.machine, 0,2*d,handle.machine.pendown);
    move(handle.machine, -d,+d,handle.machine.pendown);
    move(handle.machine, +d,+d,handle.machine.pendown);
    move(handle.machine, +d,-d,handle.machine.pendown);
    move(handle.machine, +d,-d,handle.machine.penup);
    move(handle.machine, 0,0,handle.machine.zhome);
end

%% Button Nullpunkt Callback
function btn_nullpunkt_callback(hObject, event)
    % Motor von Hand zum Nullpunkt fahren und Motorpositionen auf 0 setzten
    nullpunkt(hObject);
end

%% Button pendown slider Callback
function pendown_callback(hObject, event)
    handle = guidata(hObject);
    handle.machine.pendown = handle.pendown.Value;
    handle.machine.penup = handle.pendown.Value + 20;
    handle.pendown_text.String = handle.pendown.Value;
    drawnow;
    move(handle.machine, 0,0,handle.machine.penup);
    move(handle.machine, 0,0,handle.machine.pendown);
    move(handle.machine, 0,0,handle.machine.zhome);
    guidata(handle.fig, handle);
end