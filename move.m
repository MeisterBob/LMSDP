%% Stift nach x,y,z bewegen
function move(machine, x, y, z)
    [a,b,c] = inverseKin(machine, x, y, z);
% disp(['goto ', num2str(x), ' ', num2str(y), ' ', num2str(z)]);
    a = round(a * machine.gearRatio);
    b = round(b * machine.gearRatio);
    c = round(c * machine.gearRatio);

    dataA = machine.motorA.ReadFromNXT(); dataB = machine.motorB.ReadFromNXT(); dataC = machine.motorC.ReadFromNXT();
    if(dataA.Position < a); machine.motorA.Power = machine.Power; else; machine.motorA.Power = -machine.Power; end
    if(dataB.Position < b); machine.motorB.Power = machine.Power; else; machine.motorB.Power = -machine.Power; end
    if(dataC.Position < c); machine.motorC.Power = machine.Power; else; machine.motorC.Power = -machine.Power; end

    tl = [abs(diff([a,dataA.Position])), ...
          abs(diff([b,dataB.Position])), ...
          abs(diff([c,dataC.Position]))];

    motorRun = [1,1,1];
    if tl(1) <= 0 || tl(1) > 360; machine.motorA.Power = 0; motorRun(1)=0; end;
    if tl(2) <= 0 || tl(2) > 360; machine.motorB.Power = 0; motorRun(2)=0; end;
    if tl(3) <= 0 || tl(3) > 360; machine.motorC.Power = 0; motorRun(3)=0; end;

    machine.motorA.SendToNXT(); machine.motorB.SendToNXT(); machine.motorC.SendToNXT();

    while (sum(motorRun)>0)
        dataA = machine.motorA.ReadFromNXT();
        if motorRun(1) && (dataA.Power>0 && dataA.Position >= a || ...
            dataA.Power<0 && dataA.Position <= a )
            machine.motorA.Stop('brake'); % disp('a');
            motorRun(1)=0;
        end
        dataB = machine.motorB.ReadFromNXT();
        if motorRun(2) && (dataB.Power>0 && dataB.Position >= b || ...
            dataB.Power<0 && dataB.Position <= b )
            machine.motorB.Stop('brake'); % disp('b');
            motorRun(2)=0;
        end
        dataC = machine.motorC.ReadFromNXT();
        if motorRun(3) && (dataC.Power>0 && dataC.Position >= c || ...
            dataC.Power<0 && dataC.Position <= c )
            machine.motorC.Stop('brake'); % disp('c');
            motorRun(3)=0;
        end
% disp([dataA.Position-a, dataB.Position-b, dataC.Position-c, dataA.Power, dataB.Power, dataC.Power]);
    end
    
% dataA = machine.motorA.ReadFromNXT(); dataB = machine.motorB.ReadFromNXT(); dataC = machine.motorC.ReadFromNXT(); disp('pos'); disp([dataA.Position, dataB.Position, dataC.Position]);
end
