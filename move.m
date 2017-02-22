%% Stift nach x,y,z bewegen
function move(machine, x, y, z)
    [a,b,c] = inverseKin(machine, x, y, z);
    a = round(a * machine.gearRatio);
    b = round(b * machine.gearRatio);
    c = round(c * machine.gearRatio);

% disp('abc'); disp([a,b,c]);

    dataA = machine.motorA.ReadFromNXT(); dataB = machine.motorB.ReadFromNXT(); dataC = machine.motorC.ReadFromNXT();
    if(dataA.Position < a); machine.motorA.Power = machine.Power; else; machine.motorA.Power = -machine.Power; end
    if(dataB.Position < b); machine.motorB.Power = machine.Power; else; machine.motorB.Power = -machine.Power; end
    if(dataC.Position < c); machine.motorC.Power = machine.Power; else; machine.motorC.Power = -machine.Power; end

%     machine.motorA.TachoLimit = abs(diff([a,dataA.Position]));
%     machine.motorB.TachoLimit = abs(diff([b,dataB.Position]));
%     machine.motorC.TachoLimit = abs(diff([c,dataC.Position]));
%     if machine.motorA.TachoLimit <= 0 || machine.motorA.TachoLimit > 360; machine.motorA.Power = 0; end;
%     if machine.motorB.TachoLimit <= 0 || machine.motorB.TachoLimit > 360; machine.motorB.Power = 0; end;
%     if machine.motorC.TachoLimit <= 0 || machine.motorC.TachoLimit > 360; machine.motorC.Power = 0; end;

    tl = [abs(diff([a,dataA.Position])), ...
          abs(diff([b,dataB.Position])), ...
          abs(diff([c,dataC.Position]))];

    if tl(1) <= 0 || tl(1) > 360; machine.motorA.Power = 0; end;
    if tl(2) <= 0 || tl(2) > 360; machine.motorB.Power = 0; end;
    if tl(3) <= 0 || tl(3) > 360; machine.motorC.Power = 0; end;

% disp('TL'); disp([machine.motorA.TachoLimit, machine.motorB.TachoLimit, machine.motorC.TachoLimit]);
% disp('Po'); disp([machine.motorA.Power, machine.motorB.Power, machine.motorC.Power]);

    machine.motorA.SendToNXT(); machine.motorB.SendToNXT(); machine.motorC.SendToNXT();

    while (machine.motorA.ReadFromNXT.IsRunning || machine.motorB.ReadFromNXT.IsRunning || machine.motorC.ReadFromNXT.IsRunning)
        if(machine.motorA.ReadFromNXT.Power>0 && machine.motorA.ReadFromNXT.Position >= a || ...
            machine.motorA.ReadFromNXT.Power<0 && machine.motorA.ReadFromNXT.Position <= a )
            machine.motorA.Stop(); % disp('a');
        end
        if(machine.motorB.ReadFromNXT.Power>0 && machine.motorB.ReadFromNXT.Position >= a || ...
            machine.motorB.ReadFromNXT.Power<0 && machine.motorB.ReadFromNXT.Position <= a )
            machine.motorB.Stop(); % disp('b');
        end
        if(machine.motorC.ReadFromNXT.Power>0 && machine.motorC.ReadFromNXT.Position >= a || ...
            machine.motorC.ReadFromNXT.Power<0 && machine.motorC.ReadFromNXT.Position <= a )
            machine.motorC.Stop(); % disp('c');
        end
    end
    
% dataA = machine.motorA.ReadFromNXT(); dataB = machine.motorB.ReadFromNXT(); dataC = machine.motorC.ReadFromNXT(); disp('pos'); disp([dataA.Position, dataB.Position, dataC.Position]);
end
