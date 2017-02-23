function nullppunkt(hObject)
    handle = guidata(hObject)
    disp('bitte den Nullpunkt mit dem Joypad anfahren');
    mb = msgbox('bitte den Nullpunkt mit dem Joypad anfahren', 'Delta Plotter');
    while isvalid(mb)
        joy=jst;
        handle.machine.motorA.Power = round(handle.machine.Power * joy(1));
        handle.machine.motorB.Power = round(handle.machine.Power * -joy(2));
        handle.machine.motorC.Power = round(handle.machine.Power * joy(3));
    
        handle.machine.motorA.SendToNXT();
        handle.machine.motorB.SendToNXT();
        handle.machine.motorC.SendToNXT();

%         dataA=handle.machine.motorA.ReadFromNXT();
%         dataB=handle.machine.motorB.ReadFromNXT();
%         dataC=handle.machine.motorC.ReadFromNXT();
%         disp([dataA.Position, dataB.Position, dataC.Position]);

        drawnow;
    end
    handle.machine.motorA.Stop();
    handle.machine.motorB.Stop();
    handle.machine.motorC.Stop();

    handle.machine.motorA.ResetPosition(); handle.machine.motorB.ResetPosition(); handle.machine.motorC.ResetPosition();
    for i=0:2
        data=NXT_GetOutputState(i);
        while (data.RotationCount ~= 0)
            NXT_ResetMotorPosition(i, false);
            data=NXT_GetOutputState(i);
        end
    end
    
    % anfahren penup und zhome
    move(handle.machine, 0, 0, handle.machine.penup);
    move(handle.machine, 0, 0, handle.machine.zhome);

    msgbox('Nullpunkt gesetzt', 'Delta Plotter');
end