% close all
warning('off', 'all');

%% Maschinenparameter
machine = struct();
machine.E0      = struct('x', 0, 'y', 0, 'z', 0);       % Effektor Position
machine.theta   = struct('a', 0, 'b', 0, 'c', 0);       % Motorwinkel
machine.f       = 500;                                  % Kantenlänge Motorplattform in mm
machine.e       = 140;                                  % Kantenlänge Effektor in mm
machine.rf      = 168;                                  % Oberarmlänge in mm
machine.re      = 264;                                  % Unterarmlänge in mm

machine.fr      = machine.f/2*tan(pi*1/6);              % Motorplattform Radius in mm
machine.er      = machine.e/2*tan(pi*1/6);              % Effektor Radius in mm

machine.angle   = struct();
machine.angle.a = 0;
machine.angle.b = 0;
machine.angle.c = 0;

%% Verbindung zum NXT
COM_CloseNXT('all');
disp('Verbinde zu NXT...');
NXT = COM_OpenNXTEx('Any', '0016531B83BC', 'bluetooth.ini');
COM_SetDefaultNXT(NXT);

%% Motoren
% Motor A
machine.motorA = NXTMotor(MOTOR_A);
machine.motorA.SmoothStart = false;
machine.motorA.SpeedRegulation = false;
machine.motorA.ActionAtTachoLimit = 'Brake';
% Motor B
machine.motorB = machine.motorA;
machine.motorB.Port = MOTOR_B;
% Motor C
machine.motorC = machine.motorA;
machine.motorC.Port = MOTOR_C;

%% SVG einlesen
% svg = readsvg('svg/182316-education/svg/exam.svg');

%% Inverse Kinematik berechnen
move(machine);

%% Motor Testlauf
% testrun(machine, 50, 100, 2);

function testrun(machine, power, distance, n)
    machine.motorA.Power = power;
    machine.motorB.Power = machine.motorA.Power; machine.motorC.Power = machine.motorA.Power;
    machine.motorA.ResetPosition(); machine.motorB.ResetPosition(); machine.motorC.ResetPosition();

    machine.motorA.TachoLimit = distance;
    machine.motorB.TachoLimit = distance;
    machine.motorC.TachoLimit = distance;

    for i=1:2*n
        machine.motorA.SendToNXT();
        machine.motorB.SendToNXT();
        machine.motorC.SendToNXT();
        machine.motorA.WaitFor(); motorB.WaitFor(); motorC.WaitFor();
        machine.motorA.Power = -1*machine.motorA.Power; machine.motorB.Power = machine.motorA.Power; machine.motorC.Power = machine.motorA.Power;
    end

    dataA=machine.motorA.ReadFromNXT();
    dataB=machine.motorB.ReadFromNXT();
    dataC=machine.motorC.ReadFromNXT();
    disp([dataA.Position, dataB.Position, dataC.Position]);
end