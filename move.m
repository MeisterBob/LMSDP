function move(machine, x, y, z)
    [a,b,c] = inverseKin(machine, x, y, z);
    a = round(a * machine.gearRatio);
    b = round(b * machine.gearRatio);
    c = round(c * machine.gearRatio);

%     disp('abc'); disp([a,b,c]);

    dataA = machine.motorA.ReadFromNXT();
    dataB = machine.motorB.ReadFromNXT();
    dataC = machine.motorC.ReadFromNXT();

%     disp('pos'); disp([dataA.Position, dataB.Position, dataC.Position]);

    if(dataA.Position < a); machine.motorA.Power = machine.Power;
    else; machine.motorA.Power = -machine.Power; end

    if(dataB.Position < b); machine.motorB.Power = machine.Power;
    else; machine.motorB.Power = -machine.Power; end

    if(dataC.Position < c); machine.motorC.Power = machine.Power;
    else; machine.motorC.Power = -machine.Power; end

    machine.motorA.TachoLimit = abs(diff([a,dataA.Position]));
    machine.motorB.TachoLimit = abs(diff([b,dataB.Position]));
    machine.motorC.TachoLimit = abs(diff([c,dataC.Position]));

% disp('TL'); disp([machine.motorA.TachoLimit, machine.motorB.TachoLimit, machine.motorC.TachoLimit]);
% disp('Po'); disp([machine.motorA.Power, machine.motorB.Power, machine.motorC.Power]);

    if machine.motorA.TachoLimit <= 0 || machine.motorA.TachoLimit > 360; machine.motorA.Power = 0; end;
    if machine.motorB.TachoLimit <= 0 || machine.motorB.TachoLimit > 360; machine.motorB.Power = 0; end;
    if machine.motorC.TachoLimit <= 0 || machine.motorC.TachoLimit > 360; machine.motorC.Power = 0; end;

    machine.motorA.SendToNXT(); machine.motorB.SendToNXT(); machine.motorC.SendToNXT();
%    machine.motorA.WaitFor(); machine.motorB.WaitFor(); machine.motorC.WaitFor();
end
