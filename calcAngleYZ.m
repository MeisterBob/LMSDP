function [status, theta] = calcAngleYZ(machine, x0, y0, z0)
    status = 0;
    theta = 0;
    y1 = machine.fr;
    y0 = y0 - machine.er;                       % shift center to edge
                                                % z = a + b*y
    a = (x0*x0 + y0*y0 + z0*z0 + machine.rf*machine.rf - machine.re*machine.re - y1*y1)/(2*z0);
    b = (y1-y0)/z0;
                                                % discriminant
    d = -(a+b*y1)*(a+b*y1)+machine.rf*(b*b*machine.rf+machine.rf);
    if (d < 0); status = -1; return; end        % non-existing point
    yj = (y1 - a*b - sqrt(d))/(b*b + 1);        % choosing outer point
    zj = a + b*yj;
    theta = 180.0*atan(-zj/(y1 - yj))/pi;
    if yj>y1; theta = theta + 180.0; end
end