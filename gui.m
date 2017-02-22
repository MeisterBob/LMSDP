%% GUI Erstellen
function gui
    close all
    warning('off', 'all');

    %% Maschinenparameter
    handle.machine = struct();
    handle.machine.E0        = struct('x', 0, 'y', 0, 'z', 0);       % Effektor Position
    handle.machine.theta     = struct('a', 0, 'b', 0, 'c', 0);       % Motorwinkel
    handle.machine.f         = 500;                                  % Kantenlänge Motorplattform in mm
    handle.machine.e         = 140;                                  % Kantenlänge Effektor in mm
    handle.machine.rf        = 136;                                  % Oberarmlänge in mm
    handle.machine.re        = 264;                                  % Unterarmlänge in mm

    handle.machine.fr        = handle.machine.f/2*tan(pi*1/6);              % Motorplattform Radius in mm
    handle.machine.er        = handle.machine.e/2*tan(pi*1/6);              % Effektor Radius in mm

    handle.machine.angle     = struct();
    handle.machine.angle.a   = 0;
    handle.machine.angle.b   = 0;
    handle.machine.angle.c   = 0;

    handle.machine.gearRatio = 5;                                  % Getriebe Übersetzung
    handle.machine.Power     = 30;

    handle.machine.zhome     = -110;
    handle.machine.penup     = -192;
    handle.machine.pendown   = handle.machine.penup-20;

    %% Verbindung zum NXT
    COM_CloseNXT('all');
    % disp('Verbinde zu NXT...');
    NXT = COM_OpenNXTEx('Any', '0016531B83BC', 'bluetooth.ini');
    % NXT = COM_OpenNXT();
    COM_SetDefaultNXT(NXT);
    disp('...Verbindung hergestellt');

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

    %% Motor von Hand zum Nullpunkt fahren und Motorpositionen auf 0 setzten
    nullpunkt(handle.machine);
    for i=0:2
        dataA=NXT_GetOutputState(i);
        while (dataA.RotationCount ~= 0)
            NXT_ResetMotorPosition(i, false);
            dataA=NXT_GetOutputState(i);
        end
    end
    disp('Nullpunkt gesetzt');

    %% Positionen anfahren
    disp('goto 0,0,penup'); move(handle.machine, 0, 0, handle.machine.penup);

    % Erstellung des Hauptfensters
    handle.fig = figure(...
        'Units', 'pixel',...
        'Position', [1300 600 500 400],...
        'Name', 'Delta Plotter',...
        'MenuBar', 'none',...
        'ToolBar', 'none');

    % Kontrollelemente
    handle.axes = axes('Units', 'pixel',...
                       'XTick', [],...
                       'YTick', [],...
                       'Position', [30 30 460 260],...
                       'Parent', handle.fig);
%    uicontrol('String','Motorspannung','Style','text','Units','pixel','Position',[25 150 90 15],'Parent',handle.fig);
    handle.popup_group = uicontrol('Style','popup','Callback',@popup_group_callback,'String','Ordner auswählen','Position',[30 350 180 20],'Units','pixel','Parent',handle.fig);
    handle.popup_group.String = {'111564-university', '182316-education', '327741-future-technology', '333190-valentines-day'};
    handle.popup_pic   = uicontrol('Style','popup','Callback',@popup_pic_callback,'String','Grafik auswählen','Position',[30 320 180 20],'Units','pixel','Parent',handle.fig);

    handle.pendown = uicontrol('Style', 'slider','Min',-240,'Max',-170,'Value',handle.machine.pendown,'Units','pixel','Position', [365 320 20 50],'Callback',@pendown_callback);
    handle.btn = uicontrol('Style','pushbutton','Units','pixel','Position',[395 350 75 20],'Parent',handle.fig,'Callback',@button_callback,'String','Start');
    handle.btn_nikolaus = uicontrol('Style','pushbutton','Units','pixel','Position',[395 320 75 20],'Parent',handle.fig,'Callback',@btn_nikolaus_callback,'String','Nikolaus');

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
    
    [img, map, transparency] = imread(pic, 'png', 'BackgroundColor', {0,0,0});
    imshow(img);
end

%% Button Start Callback
function button_callback(hObject, event)
    handle = guidata(hObject);
    group = string(handle.popup_group.String(handle.popup_group.Value));
    pic = string(handle.popup_pic.String(handle.popup_pic.Value));
    pic = char(strcat('svg/', group, '/svg/', pic));
    readsvg(pic);
end

%% Button Nikolaus Callback
function btn_nikolaus_callback(hObject, event)
    handle = guidata(hObject);
    d=30;
handle.machine.pendown
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

%% Button pendown slider Callback
function pendown_callback(hObject, event)
    handle = guidata(hObject);
    handle.machine.pendown = handle.pendown.Value;

    guidata(handle.fig, handle);
end