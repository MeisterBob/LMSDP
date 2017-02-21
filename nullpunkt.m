function nullppunkt(machine)
    disp('bitte den Nullpunkt mit dem Joypad anfahren');
    
    joy = jst;
    while joy(5)==0
        joy=jst;
        machine.motorA.Power = round(30 * joy(1));
        machine.motorB.Power = round(30 * joy(2));
        machine.motorC.Power = round(30 * joy(3));
    
        machine.motorA.SendToNXT();
        machine.motorB.SendToNXT();
        machine.motorC.SendToNXT();

        dataA=machine.motorA.ReadFromNXT();
        dataB=machine.motorB.ReadFromNXT();
        dataC=machine.motorC.ReadFromNXT();
%         disp([dataA.Position, dataB.Position, dataC.Position]);

        drawnow;
    end
    machine.motorA.Stop();
    machine.motorB.Stop();
    machine.motorC.Stop();

    machine.motorA.ResetPosition(); machine.motorB.ResetPosition(); machine.motorC.ResetPosition();
end