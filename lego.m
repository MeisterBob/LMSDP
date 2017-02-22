d=20; % Kantenlänge
for i=1:3
    pause(0.5);
    move(machine, -d,-d,machine.penup);
    move(machine, -d,-d,machine.pendown);
    move(machine, -d,+d,machine.pendown);
    move(machine, +d,-d,machine.pendown);
    move(machine, -d,-d,machine.pendown);
    move(machine, +d,+d,machine.pendown);
    move(machine, 0,2*d,machine.pendown);
    move(machine, -d,+d,machine.pendown);
    move(machine, +d,+d,machine.pendown);
    move(machine, +d,-d,machine.pendown);
    move(machine, +d,-d,machine.penup);
    move(machine, 0,0,machine.zhome);
end
