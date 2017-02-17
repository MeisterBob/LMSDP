%% Lego Projekt Start Funktion
function lego()
    % Alte Verbindungen schlieﬂen
    close all
    COM_CloseNXT('all');
    % Erstellung des Hauptfensters
%    handle.fig = figure('Units', 'pixel', 'Position', [1100 600 300 200], 'Name', 'Aufgabe 2', 'MenuBar', 'none', 'ToolBar', 'none');
    % Kontrollelemente
%    uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[25 150 90 15],'String','Motorspannung');
%    handle.slider = uicontrol('Style', 'slider','Min',0,'Max',100,'Value',50,'Units','pixel','Position', [115 150 150 15]);
%    uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[25 130 90 15],'String','Position');
%    uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[25 110 90 15],'String','Drehzahl');
%    handle.positionA = uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[115 130 30 15],'String','0');
%    handle.drehzahlA = uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[115 110 30 15],'String','0');
%    handle.positionC = uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[145 130 30 15],'String','0');
%    handle.drehzahlC = uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[145 110 30 15],'String','0');
%    uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[25 90 90 15],'String','Entfernung');
%    handle.entfernung = uicontrol('Parent',handle.fig,'Style','text','Units','pixel','Position',[115 90 30 15],'String','0');
%    handle.button = uicontrol('Style','pushbutton','Units','pixel','Position',[120 60 75 20],'Parent',handle.fig,'Callback',@button_callback,'String','Start');

    disp('Verbinde zu NXT...');
    COM_SetDefaultNXT(COM_OpenNXT('bluetooth.ini'));
    
    % Sichern der Handle
%    guidata(handle.fig, handle);
    
    motorB = NXTMotor(MOTOR_B);
    motorB.Power = 100;
    motorB.SpeedRegulation = true;
    motorB.TachoLimit = 360;
    motorB.ActionAtTachoLimit = 'Brake';
    motorB.SmoothStart = true;
    motorB.SendToNXT();

end